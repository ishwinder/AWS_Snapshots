class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.integer :action
      t.integer :frequency
      t.integer :day_of_week
      t.integer :day_of_month 
      t.time :event_time
      t.text :cron
      t.references :schedule, index: true

      t.timestamps
    end
  end
end
