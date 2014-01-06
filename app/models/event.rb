class Event < ActiveRecord::Base
  belongs_to :schedule

  REPEAT_TYPE = {"Daily" => 0, "Weekly" => 1, "Monthly" => 2}
  ACTIONS = {"Start Instance" => 0, "Stop Instance" => 1, "Reboot Instance" => 2}

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
end
