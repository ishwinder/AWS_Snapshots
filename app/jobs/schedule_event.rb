module ScheduleEvent
  @queue = :scheduling_event
  def self.perform(*args)
    user = User.find(args[0])
    schedule = user.schedules.find(args[1])
    event = schedule.events.find(args[2])
    instances = schedule.instances
    instances.each do |inst|
      ec2 = AWS::EC2.new(access_key_id: user.access_key, secret_access_key: user.secret_token, region: inst.region)

      if event.action == "Start Instance"
        response = ec2.client.start_instances({instance_ids: [inst.instance]})
        state = response.instances_set.first.current_state.name
        status = (state == "pending" or state == "running")

      elsif event.action == "Stop Instance"
        response = ec2.client.stop_instances({instance_ids: [inst.instance]})
        state = response.instances_set.first.current_state.name
        status = (state == "stopping" or state == "stopped")

      elsif event.action == "Reboot Instance"
        response = ec2.client.reboot_instances({instance_ids: [inst.instance]})
        status = (response.return == "true")
      end

      schedule.scheduled_summaries.create(action: event[:action], instance_id: inst.instance, 
                                          status: status, user_id: user.id)
    end
  end
end