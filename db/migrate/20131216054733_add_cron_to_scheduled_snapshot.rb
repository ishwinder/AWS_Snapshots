class AddCronToScheduledSnapshot < ActiveRecord::Migration
  def change
    add_column :scheduled_snapshots, :cron, :text
  end
end
