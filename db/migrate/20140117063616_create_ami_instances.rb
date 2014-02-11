class CreateAmiInstances < ActiveRecord::Migration
  def change
    create_table :ami_instances do |t|
      t.string :instance_id
      t.string :region
      t.references :scheduled_ami, index: true

      t.timestamps
    end
  end
end
