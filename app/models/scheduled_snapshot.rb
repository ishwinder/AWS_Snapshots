class ScheduledSnapshot < ActiveRecord::Base
  belongs_to :user

  serialize :time_of_day, Array
  serialize :day_of_week, Array
  serialize :month_of_year, Array
  
  REPEAT_TYPE = {"None" => 0, "Hourly" => 1, "Daily" => 2, "Weekly" => 3, "Monthly" => 4 }

  def frequency=(freq)
    self[:frequency] = REPEAT_TYPE[freq]
  end
  
  def frequency
    REPEAT_TYPE.key(self[:frequency])
  end
end
