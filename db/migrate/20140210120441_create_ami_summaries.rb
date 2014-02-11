class CreateAmiSummaries < ActiveRecord::Migration
  def change
    create_table :ami_summaries do |t|
      t.string :name
      t.string :ami_id
      t.string :instance_id
      t.references :scheduled_ami, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
