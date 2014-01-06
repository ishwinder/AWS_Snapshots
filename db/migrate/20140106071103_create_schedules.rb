class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :name
      t.text :instances
      t.string :status
      t.references :user, index: true

      t.timestamps
    end
  end
end
