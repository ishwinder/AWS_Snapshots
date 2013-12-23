class AddRegionToScheduledSnapshots < ActiveRecord::Migration
  def change
    add_column :scheduled_snapshots, :region, :string
  end
end
