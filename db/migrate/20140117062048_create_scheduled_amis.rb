class CreateScheduledAmis < ActiveRecord::Migration
  def change
    create_table :scheduled_amis do |t|
      t.string :name
      t.string :schedule_name
      t.string :description
      t.boolean :no_reboot
      t.integer :frequency
      t.integer :day_of_week
      t.integer :day_of_month 
      t.time :event_time
      t.text :cron
      t.references :user

      t.timestamps
    end
  end
end
