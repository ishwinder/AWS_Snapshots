class AddAutoDeleteOnToSnapshotSummary < ActiveRecord::Migration
  def change
    add_column :snapshot_summaries, :auto_delete_on, :date
  end
end
