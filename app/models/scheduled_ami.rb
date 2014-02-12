class ScheduledAmi < ActiveRecord::Base
  belongs_to :user
  has_many :ami_instances, dependent: :destroy
  has_many :ami_summaries, dependent: :destroy
  
  validates :schedule_name, presence: true
  validates :name, presence: true
  validates :frequency, presence: true
  validates :event_time, presence: true

  accepts_nested_attributes_for :ami_instances

  after_save :set_crontab, :schedule_ami

  REPEAT_TYPE = {"Daily" => 0, "Weekly" => 1, "Monthly" => 2}
  DAY_OF_WEEK = {"Monday" => 1, "Tuesday" => 2, "Wednesday" => 3, "Thursday" => 4, "Friday" => 5, "Saturday" => 2,"Sunday" => 0}

  def no_reboot
    unless self[:no_reboot] == true
      return false
    else
      true
     end
  end

  def frequency=(freq)
    self[:frequency] = REPEAT_TYPE[freq]
  end

  def frequency
    REPEAT_TYPE.key(self[:frequency])
  end

  def day_of_week=(day)
    self[:day_of_week] = DAY_OF_WEEK[day]
  end

  def day_of_week
    DAY_OF_WEEK.key(self[:day_of_week])
  end

  def set_crontab
    cron_array = case frequency
        when "Daily"
          [event_time.min, event_time.hour, "* * *"]
        when "Weekly"
          [event_time.min, event_time.hour, "* *", self[:day_of_week]]
        when "Monthly"
          [event_time.min, event_time.hour, day_of_month, "* *"]
      end
    update_column :cron, cron_array.join(" ")
  end

  def schedule_ami
    Resque.set_schedule("ami_schedule_#{self.id}", {
          :cron => cron,
          :class => "ScheduleAmi",
          :args => [self.user_id, self.id],
          :message => 'Schedule set for ami',
          :persist => true
        })
  end

  def self.import(file, user)
    created = 0
    error = 0
    headers = CSV.read(file.path).first
    if headers.include?("schedule_name" && "description" && "no_reboot" && "frequency" && "day_of_week" && "day_of_month" && "event_time" && "ami_instances")
      CSV.foreach(file.path, headers: true) do |row|
        sch= user.scheduled_amis.new
        sch.schedule_name = row["schedule_name"] if row["schedule_name"]
        sch.name = row["name"] if row["name"]
        sch.description = row["description"] if row["description"]
        sch.no_reboot = row["no_reboot"] if row["no_reboot"]
        sch.frequency = row["frequency"] if row["frequency"]
        sch.day_of_week = row["day_of_week"] if row["day_of_week"]
        sch.day_of_month = row["day_of_month"] if row["day_of_month"]
        sch.event_time = row["event_time"] if row["event_time"]
        instances = JSON.parse row["ami_instances"].gsub('=>', ':') if row["ami_instances"]
        sch.ami_instances_attributes = instances.map{|cc| ["instance_id" => cc[0], "region" => cc[1]]}.flatten if instances
        if sch.save
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
