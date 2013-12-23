class DashboardController < ApplicationController

  respond_to :js, :html
  layout false, except: [:index]

  def index
  end

  def load_instances_summary
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token, region: current_user.default_region)
    filters = {max_results: 5}
    response = ec2.client.describe_instances filters
    @instances_summary = response.reservation_set.map(&:instances_set).flatten!
    respond_with @instances_summary
  end

end
