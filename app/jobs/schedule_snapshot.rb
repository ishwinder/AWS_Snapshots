module ScheduleSnapshot
  @queue = :scheduling_snapshot
  def self.perform(*args)
    user = User.find(args[0])
    snapshot = ScheduledSnapshot.find(args[1])
    ec2 = AWS::EC2.new(access_key_id: user.access_key, secret_access_key: user.secret_token)
    ec2.client.create_snapshot({volume_id: snapshot.volume_id})
  end
end