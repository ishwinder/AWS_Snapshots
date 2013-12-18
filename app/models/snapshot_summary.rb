class SnapshotSummary < ActiveRecord::Base
  belongs_to :scheduled_snapshot
  belongs_to :user
end
