class UsersController < ApplicationController

  skip_before_filter :fill_aws_creds
  layout 'logout'

  def add_aws_creds
    @user = current_user
  end
  
  def update_aws_creds
    @user = current_user
    ec2 = AWS::EC2.new(access_key_id: aws_params["access_key"], secret_access_key: aws_params["secret_token"])
    begin
      unless ec2.client.describe_key_pairs.key_set.nil?
        @user.update_attributes(aws_params)
        flash[:notice] = "AWS credentials updated successfully!!"
        redirect_to root_path
      else
        flash[:error] = "Please enter valid AWS creds!!"
        render :add_aws_creds
      end
    rescue
      flash[:error] = "Please enter valid AWS creds!!"
      render :add_aws_creds
    end
  end
  
  private
  
  def aws_params
    params.require(:user).permit(:access_key, :secret_token)
  end
end
