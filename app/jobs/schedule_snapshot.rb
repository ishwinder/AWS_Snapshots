module ScheduleSnapshot
  @queue = :scheduling_snapshot
  def self.perform(*args)
    user = User.find(args[0])
    snapshot = ScheduledSnapshot.find(args[1])
    ec2 = AWS::EC2.new(access_key_id: user.access_key, secret_access_key: user.secret_token, region: snapshot.region)
    snapshot.volume_id.each do |id|
      response = ec2.client.create_snapshot({volume_id: id, description: snapshot.description})
      if !snapshot.tags.empty?
        snapshot.tags.each do |tag|
          response1 = ec2.client.create_tags({resources: [response.snapshot_id], tags: [key: tag.key, value: tag.value ]})
        end
      end
      SnapshotSummary.create(snapshot_id: response.snapshot_id, volume_id: response.volume_id, 
                             start_time: response.start_time, scheduled_snapshot_id: snapshot.id, 
                             user_id: user.id, auto_delete_on: response.start_time + snapshot.retention_period.days)
    end
  end
end