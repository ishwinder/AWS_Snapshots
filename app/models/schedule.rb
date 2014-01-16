require 'csv'

class Schedule < ActiveRecord::Base
  belongs_to :user
  has_many :events, dependent: :destroy
  has_many :instances, dependent: :destroy
  has_many :scheduled_summaries, dependent: :destroy


  accepts_nested_attributes_for :events
  accepts_nested_attributes_for :instances
  
  after_save :set_event_crontab, :schedule_event
  
  
  def set_event_crontab
    self.events.each do |event|
      cron_array = case event.frequency
        when "Daily"
          [event.event_time.min, event.event_time.hour, "* * *"]
        when "Weekly"
          [event.event_time.min, event.event_time.hour, "* *", event[:day_of_week]]
        when "Monthly"
          [event.event_time.min, event.event_time.hour, event.day_of_month, "* *"]
      end
      event.update_column :cron, cron_array.join(" ")
    end
  end
  
  def schedule_event
    self.events.each do |event|
      Resque.set_schedule("schedule_#{self.id}_event_#{event.id}", {
            :cron => event.cron,
            :class => "ScheduleEvent",
            :args => [self.user_id, self.id, event.id],
            :message => 'Schedule set for event',
            :persist => true
          })
    end
  end

  def self.import(file, user)
    created = 0
    error = 0
    headers = CSV.read(file.path).first
    if headers.include?("name" && "instances" && "events")
      CSV.foreach(file.path, headers: true) do |row|
        sch= user.schedules.new
        sch.name = row["name"] if row["name"]
        instances = JSON.parse row["instances"].gsub('=>', ':') if row["instances"]
        sch.instances_attributes = instances.map{|cc| ["instance" => cc[0], "region" => cc[1]]}.flatten if instances
        sch.events_attributes = JSON.parse row["events"].gsub('=>', ':') if row["events"]
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
