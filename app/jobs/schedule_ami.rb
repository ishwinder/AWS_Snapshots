module ScheduleAmi
  @queue = :scheduling_ami
  def self.perform(*args)
    user = User.find(args[0])
    ami = ScheduledAmi.find(args[1])
    ami.ami_instances.each do |instance|
      ec2 = AWS::EC2.new(access_key_id: user.access_key, secret_access_key: user.secret_token, region: instance.region)
      response = ec2.client.create_image({instance_id: instance.instance_id, name: ami.name + Time.now.strftime(" %H-%M-%S"),
         description: ami.description, no_reboot: ami.no_reboot})
      ami.ami_summaries.create(name: ami.name, ami_id: response.image_id, instance_id: instance.instance_id, user_id: user.id)
    end
  end
end