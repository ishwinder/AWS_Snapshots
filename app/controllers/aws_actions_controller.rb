class AwsActionsController < ApplicationController

  respond_to :js, :html
  layout false

  def load_instances
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token)
    response = ec2.client.describe_instances
    @instances = response.reservation_set.map(&:instances_set).flatten!
    respond_with @instances
  end

  def load_snapshots
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token)
    response = ec2.client.describe_snapshots({owner_ids:[ "self"]})
    @snapshots = response.snapshot_set
    respond_with @snapshots
  end

  def load_volumes
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token)
    response = ec2.client.describe_volumes
    @volumes = response.volume_set
    respond_with @volumes
  end

  def delete_snapshot
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token)
    ec2.client.delete_snapshot({snapshot_id: params[:snapshot_id]})
    render text: "Deleted Successfully"
  end

end
