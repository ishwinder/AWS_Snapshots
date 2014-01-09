class Event < ActiveRecord::Base
  belongs_to :schedule

  REPEAT_TYPE = {"Daily" => 0, "Weekly" => 1, "Monthly" => 2}
  ACTIONS = {"Start Instance" => 0, "Stop Instance" => 1, "Reboot Instance" => 2}
  DAY_OF_WEEK = {"Monday" => 1, "Tuesday" => 2, "Wednesday" => 3, "Thursday" => 4, "Friday" => 5, "Saturday" => 2,"Sunday" => 0}

  def frequency=(freq)
    self[:frequency] = REPEAT_TYPE[freq]
  end

  def action=(act)
    self[:action] = ACTIONS[act]
  end

  def frequency
    REPEAT_TYPE.key(self[:frequency])
  end

  def action
    ACTIONS.key(self[:action])
  end

  def day_of_week=(day)
    self[:day_of_week] = DAY_OF_WEEK[day]
  end

  def day_of_week
    DAY_OF_WEEK.key(self[:day_of_week])
  end

end
