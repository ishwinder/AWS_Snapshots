class AmiSummary < ActiveRecord::Base
  belongs_to :user
  belongs_to :scheduled_ami
end
