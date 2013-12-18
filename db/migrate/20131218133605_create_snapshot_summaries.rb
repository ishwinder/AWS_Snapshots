class CreateSnapshotSummaries < ActiveRecord::Migration
  def change
    create_table :snapshot_summaries do |t|
      t.string :snapshot_id
      t.string :volume_id
      t.datetime :start_time
      t.references :scheduled_snapshot, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
