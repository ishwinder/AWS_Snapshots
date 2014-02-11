class ScheduledAmisController < ApplicationController

  respond_to :js, :html
    layout false, only: [:fetch_ami_schedule]

  def index 
    @scheduled_amis = current_user.scheduled_amis
    respond_with @scheduled_amis
  end

  def show
    @scheduled_ami = current_user.scheduled_amis.find(params[:id])
    respond_with @scheduled_ami
  end

  def create
    if params[:scheduled_ami][:type] == 'new_schedule'
      @scheduled_ami = current_user.scheduled_amis.new(ami_params)
      if @scheduled_ami.save
        flash[:notice] = "AMI Scheduled Successfully!!"
        redirect_to @scheduled_ami
      else
        flash[:alert] = "There was some problem in scheduling ami - #{@scheduled_ami.errors.full_messages.join(', ')}"
        redirect_to root_path
      end
    elsif params[:scheduled_ami][:type] == 'old_schedule'
      @scheduled_ami = current_user.scheduled_amis.find(params[:scheduled_ami][:schedule_name])
      @instances = @scheduled_ami.ami_instances.map(&:instance_id)
      if params[:scheduled_ami][:ami_instances_attributes]
        params[:scheduled_ami][:ami_instances_attributes].each do |old_params|
          unless @instances.include?(old_params[:instance_id])
            @scheduled_ami.ami_instances.create(old_params)
          end
        end
      end
      @scheduled_ami.update_attributes(name: params[:scheduled_ami][:name], frequency: params[:scheduled_ami][:frequency],
                      no_reboot: params[:scheduled_ami][:no_reboot], event_time:params[:scheduled_ami][:event_time],
                      day_of_week: params[:scheduled_ami][:day_of_week], day_of_month: params[:scheduled_ami][:day_of_month])
      flash[:notice] = "AMI Updated Successfully!!"
      redirect_to @scheduled_ami
    end
  end

  def destroy
    schedule = current_user.scheduled_amis.find(params[:id])
    @result = Resque.get_schedule("ami_schedule_#{params[:id]}")
    if @result.present?
      Resque.remove_schedule("ami_schedule_#{params[:id]}")
    end

    if schedule.destroy
      flash[:notice] = "Schedule dropped successfully"
    else
      flash[:alert] = "There was some problem in droping schedule"
    end
    redirect_to scheduled_amis_path
  end

  def fetch_ami_schedule
    @schedule = current_user.scheduled_amis.find(params[:schedule_id])
  end

  private
  def ami_params
    params.require(:scheduled_ami).permit(:name, :description, :schedule_name, :no_reboot, :frequency, :event_time, :day_of_week, :day_of_month, :ami_instances_attributes => [:instance_id, :region])
  end

  def old_params
    params.require(:scheduled_ami).(:ami_instances_attributes).permit(:instance_id, :region)
  end
end
