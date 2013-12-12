class AwsActionsController < ApplicationController

  respond_to :js, :html
  layout false, except: [:create_snapshot]

  def load_instances
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token)
    filters = {max_results: 30}
    filters.merge!({next_token: params[:next_token]}) if params[:next_token].present?
    filters.merge!({filters: [{name: "availability-zone", values: [params[:zone]]}]}) if params[:zone]!= "all"
    response = ec2.client.describe_instances filters
    @instances = response.reservation_set.map(&:instances_set).flatten!
    @next_token = response[:next_token]
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

  def create_snapshot
  end

  def create_instant_snapshot
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token)
    response = ec2.client.create_snapshot({volume_id: params[:volume_id]})
    render text: "Instance Snapshot Successfully created"
  end

  def delete_snapshot
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token)
    ec2.client.delete_snapshot({snapshot_id: params[:snapshot_id]})
    render text: "Deleted Successfully"
  end

end
