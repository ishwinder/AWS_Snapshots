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

end
