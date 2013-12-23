class UsersController < ApplicationController

  skip_before_filter :fill_aws_creds
  layout 'logout', except: [:show]
  respond_to :js, :html

  def add_aws_creds
    @user = current_user
  end

  def show
    @user = current_user
    respond_with @user
  end

  def change_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.valid_password?(params[:user][:password])
      if params[:user][:new_password] == params[:user][:password_confirmation]
        if @user.update_attributes(:password => params[:user][:new_password])
          flash[:notice] = "Password Sucessfully Changed"
          sign_in(@user, :bypass => true)
          redirect_to profile_path
        else
          flash[:error] = "Error occured while updating password. Try again"
          redirect_to change_password_path
        end
      else
        flash[:error] = "New Password and Password Confirmation does not match"
        redirect_to change_password_path
      end
    else
      flash[:error] = "Password is not valid"
      redirect_to change_password_path
    end
  end

  def edit_aws_creds
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

  def change_default_region
    @user = current_user
    @user.update_column(:default_region, params[:region])
    render text: "user default region sucessfully changed"
  end

  private

  def aws_params
    params.require(:user).permit(:access_key, :secret_token)
  end
end
