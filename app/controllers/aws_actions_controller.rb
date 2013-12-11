class AwsActionsController < ApplicationController

  respond_to :js, :html
  layout false

  def load_instances
    begin
      ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token)
      response = ec2.client.describe_instances
      @instances = response.reservation_set.map(&:instances_set).flatten!
    rescue
      @instances = []
    end
    respond_with @instances
  end
  
end
