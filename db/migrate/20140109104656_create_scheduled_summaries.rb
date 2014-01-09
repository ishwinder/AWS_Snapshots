class CreateScheduledSummaries < ActiveRecord::Migration
  def change
    create_table :scheduled_summaries do |t|
      t.integer :action
      t.string :instance_id
      t.boolean :status
      t.references :schedule, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
