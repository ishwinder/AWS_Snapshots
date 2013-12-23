class AwsActionsController < ApplicationController

  respond_to :js, :html
  layout false, except: [:create_snapshot]
  before_action :set_ec2

  def load_instances
    filter = []
    filter << {name: "availability-zone", values: [params[:zone]]} if params[:zone]!= "all"
    filter << {name: "instance-id", values: [params[:value]]} if params[:filter].present? && params[:filter] == "Instance ID"
    filter << {name: "block-device-mapping.volume-id", values: [params[:value]] } if params[:filter].present? && params[:filter] == "Volume ID"
    filter << {name: "image-id", values:[params[:value]] } if params[:filter].present? && params[:filter] == "AMI"
    filter << {name: "tag:#{params[:key]}", values:[params[:value]] } if params[:filter].present? && params[:filter] == "Tags"
    if filter.empty?
      filters = {max_results: 30} 
      filters.merge!({next_token: params[:next_token]}) if params[:next_token].present?
    else
      filters = {filters: filter}
    end
    response = @ec2.client.describe_instances filters
    @instances = response.reservation_set.map(&:instances_set).flatten!
    @next_token = response[:next_token]
    respond_with @instances
  end

  def load_snapshots
    response = @ec2.client.describe_snapshots({owner_ids:[ "self"]})
    @snapshots = response.snapshot_set
    respond_with @snapshots
  end

  def load_volumes
    response = @ec2.client.describe_volumes
    @volumes = response.volume_set
    respond_with @volumes
  end

  def load_volumes_for_instance
    response = @ec2.client.describe_volumes filters: [{name: 'attachment.instance-id', values: [params[:instance_id]]}]
    @volumes = response.volume_set
    raise ActiveRecord::RecordNotFound if @volumes.empty?
    respond_with @volumes
  end

  def create_snapshot
  end

  def create_instant_snapshot
    response = @ec2.client.create_snapshot({volume_id: params[:volume_id]})
    render text: "Instance Snapshot Successfully created"
  end

  def delete_snapshot
    @ec2.client.delete_snapshot({snapshot_id: params[:snapshot_id]})
    render text: "Deleted Successfully"
  end
  
  def set_ec2
    @ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token, region: current_user.default_region)
  end

end
