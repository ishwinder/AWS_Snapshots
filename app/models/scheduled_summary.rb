class ScheduledSummary < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :user

  ACTIONS = {"Start Instance" => 0, "Stop Instance" => 1, "Reboot Instance" => 2}
  STATUS = {"Success" => true, "Failed" => false}
  
  def action
    ACTIONS.key(self[:action])
  end
  
  def status
    STATUS.key(self[:status])
  end
end
