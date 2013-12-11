class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter :fill_aws_creds

  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  private

  def fill_aws_creds
    if current_user && (current_user.access_key.blank? || current_user.secret_token.blank?)
      redirect_to add_aws_creds_user_path(current_user)
    end
  end
end 
