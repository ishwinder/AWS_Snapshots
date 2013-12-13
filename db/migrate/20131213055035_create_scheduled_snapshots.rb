class CreateScheduledSnapshots < ActiveRecord::Migration
  def change
    create_table :scheduled_snapshots do |t|
      t.string :volume_id
      t.string :description
      t.date :start_date
      t.date :end_date
      t.integer :frequency
      t.time :start_time
      t.string :time_of_day
      t.string :day_of_week
      t.string :month_of_year
      t.references :user

      t.timestamps
    end
  end
end
