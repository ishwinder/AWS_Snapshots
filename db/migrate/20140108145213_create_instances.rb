class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :instance
      t.string :region
      t.references :schedule, index: true

      t.timestamps
    end
  end
end
