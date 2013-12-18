module ScheduleCron
  @queue = :scheduling_cron
  def self.perform
    schedules = ScheduledSnapshot.scheduled_today
    if !schedules.empty?
      schedules.each do |schedule|
        Resque.set_schedule("scheduling_snapshot_#{schedule.id}", {
          :cron => schedule.cron,
          :class => "ScheduleSnapshot",
          :args => [schedule.user_id, schedule.id],
          :message => 'Schedule set',
          :persist => true
        })
      end
    end
    ended = ScheduledSnapshot.schedule_ended
    if !ended.empty?
      ended.each do |schedule|
        name = "scheduling_snapshot_#{schedule.id}"
        Resque.remove_schedule(name)
      end
    end
  end
end