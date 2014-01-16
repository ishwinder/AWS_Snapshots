require 'csv'

class ScheduledSnapshot < ActiveRecord::Base
  has_many :snapshot_summaries, dependent: :destroy
  has_many :tags, as: :tagable
  belongs_to :user

  serialize :volume_id, Array
  serialize :time_of_day, Array
  serialize :day_of_week, Array
  serialize :month_of_year, Array

  after_initialize :default_values
  after_save :set_crontab, :check_scheduling_date
  
  scope :scheduled_today, lambda { where(start_date: Date.today)}
  scope :schedule_ended, lambda { where(end_date: Date.today-1)}

  REPEAT_TYPE = {"None" => 0, "Hourly" => 1, "Daily" => 2, "Weekly" => 3, "Monthly" => 4 }

  accepts_nested_attributes_for :tags, reject_if: proc { |attributes| attributes['key'].blank? || attributes['value'].blank?}
  def frequency=(freq)
    self[:frequency] = REPEAT_TYPE[freq]
  end

  def end_date=(end_date)
    if frequency == "None"
      self[:end_date] = start_date
    else
      self[:end_date] = end_date
    end
  end

  def frequency
    REPEAT_TYPE.key(self[:frequency])
  end

  def set_crontab
    cron_array = case frequency
      when "None"
        [start_time.min, start_time.hour, start_date.mday, start_date.month, "*"]
      when "Hourly"
        ["0", time_of_day.join(','), "* * *"]
      when "Daily"
        [start_time.min, start_time.hour, "* *", day_of_week.join(',')]
      when "Weekly"
        [start_time.min, start_time.hour, "* *", start_date.wday]
      when "Monthly"
        [start_time.min, start_time.hour, start_date.mday, month_of_year.join(','), "*"]
    end
    update_column :cron, cron_array.join(" ")
  end
  
  def check_scheduling_date
    scheduled_date = self.start_date
    if (scheduled_date - Date.today) == 0
      Resque.set_schedule("scheduling_snapshot_#{self.id}", {
          :cron => self.cron,
          :class => "ScheduleSnapshot",
          :args => [self.user_id, self.id],
          :message => 'Schedule set',
          :persist => true
        })
    end
  end
  
  def default_values
    self.region = self.user.default_region
  end

  def self.import(file, user)
    created = 0
    error = 0
    headers = CSV.read(file.path).first
    debugger
    if headers.include?("volume_id" && "frequency" && "start_date" && "end_date" && "start_time" && "retention_period")
      CSV.foreach(file.path, headers: true) do |row|
        sch_snap = user.scheduled_snapshots.new
        sch_snap.volume_id = row["volume_id"].split(", ") if row["volume_id"]
        sch_snap.description = row["description"] if row["description"]
        sch_snap.frequency = row["frequency"] if row["frequency"]
        sch_snap.start_date = row["start_date"] if row["start_date"]
        sch_snap.end_date = row["end_date"] if row["end_date"]
        sch_snap.start_time = row["start_time"] if row["start_time"]
        sch_snap.retention_period = row["retention_period"] if row["retention_period"]
        sch_snap.time_of_day = (row["time_of_day"].nil? ? nil : row["time_of_day"].split(", ")) if row["time_of_day"]
        sch_snap.day_of_week = (row["day_of_week"].nil? ? nil : row["day_of_week"].split(", ")) if row["day_of_week"]
        sch_snap.month_of_year = (row["month_of_year"].nil? ? nil : row["month_of_year"].split(", ")) if row["month_of_year"]
        tags =  JSON.parse row["tags"].gsub('=>',':') if row["tags"]
        sch_snap.tags_attributes = tags.map{|cc| ["key" => cc[0], "value" => cc[1]]}.flatten if tags
        if sch_snap.save
          created += 1
        else
          error += 1
        end
      end
    else
      raise "error"
    end
    return created, error
  end

end
