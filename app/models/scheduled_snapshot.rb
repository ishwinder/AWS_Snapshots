class ScheduledSnapshot < ActiveRecord::Base
  belongs_to :user

  serialize :time_of_day, Array
  serialize :day_of_week, Array
  serialize :month_of_year, Array

  after_save :set_crontab

  REPEAT_TYPE = {"None" => 0, "Hourly" => 1, "Daily" => 2, "Weekly" => 3, "Monthly" => 4 }

  def frequency=(freq)
    self[:frequency] = REPEAT_TYPE[freq]
  end

  def frequency
    REPEAT_TYPE.key(self[:frequency])
  end

  def set_crontab
    cron_array = case frequency
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
end
