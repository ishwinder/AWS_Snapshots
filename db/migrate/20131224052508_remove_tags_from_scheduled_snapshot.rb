class RemoveTagsFromScheduledSnapshot < ActiveRecord::Migration
  def change
    remove_column :scheduled_snapshots, :tags, :text
  end
end
