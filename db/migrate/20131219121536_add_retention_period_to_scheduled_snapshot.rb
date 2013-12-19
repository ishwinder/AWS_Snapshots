class AddRetentionPeriodToScheduledSnapshot < ActiveRecord::Migration
  def change
    add_column :scheduled_snapshots, :retention_period, :integer
  end
end
