class CreateScheduledSnapshots < ActiveRecord::Migration
  def change
    create_table :scheduled_snapshots do |t|
      t.string :volume_id
      t.string :description
      t.date :start_date
      t.date :end_date
      t.integer :frequency
      t.time :time_of_day
      t.integer :day_of_week
      t.integer :day_of_month

      t.timestamps
    end
  end
end
