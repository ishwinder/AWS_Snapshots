class AddTagsToScheduledSnapshots < ActiveRecord::Migration
  def change
    add_column :scheduled_snapshots, :tags, :text
  end
end
