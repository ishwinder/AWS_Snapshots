class SchedulesController < ApplicationController

  respond_to :js, :html
  layout false, only: [:fetch_actions]

  def index
    @schedules = current_user.schedules
    respond_with @schedules
  end

  def create
    if params[:schedule][:type] == 'new_schedule'
      params[:schedule][:instances_attributes] = params[:schedule][:instances_attributes].uniq
      @schedule = current_user.schedules.new(schedule_params)
      if @schedule.save
        flash[:notice] = "Schedule Successfully Created!!"
        redirect_to schedules_path
      else
        flash[:alert] = "There was some problem in creating schedule - #{@schedule.errors.full_messages.join(', ')}"
        redirect_to root_path
      end
    elsif params[:schedule][:type] == 'old_schedule'
      @schedule = current_user.schedules.where(name: params[:schedule][:name]).first
      @instances = @schedule.instances.map(&:instance)
      params[:schedule][:instances_attributes].each do |old_schedule_params|
        unless @instances.include?(old_schedule_params[:instance])
          @schedule.instances.create(old_schedule_params)
        end
      end
      flash[:notice] = "Schedule Successfully Updated!!"
      redirect_to schedules_path
    end
  end

  def show
    @schedule = current_user.schedules.find(params[:id])
  end

  def destroy
    schedule = current_user.schedules.find(params[:id])
    schedule.events.each do |event|
      @result = Resque.get_schedule("schedule_#{params[:id]}_event_#{event.id}")
      if @result.present?
        Resque.remove_schedule("schedule_#{params[:id]}_event_#{event.id}")
      end
    end

    if schedule.destroy
      flash[:notice] = "Schedule dropped successfully"
    else
      flash[:alert] = "There was some problem in droping schedule"
    end
    redirect_to schedules_path
  end

  def fetch_actions
    @schedule = current_user.schedules.where(name: params[:schedule]).first
    respond_with @schedule
  end
  
  def instant_action
    ec2 = AWS::EC2.new(access_key_id: current_user.access_key, secret_access_key: current_user.secret_token, region: current_user.default_region)

      if params[:type] == "Start"
        response = ec2.client.start_instances({instance_ids: [params[:instance_id]]})
        state = response.instances_set.first.current_state.name
        status = (state == "pending" or state == "running")

      elsif params[:type] == "Stop"
        response = ec2.client.stop_instances({instance_ids: [params[:instance_id]]})
        state = response.instances_set.first.current_state.name
        status = (state == "stopping" or state == "stopped")

      elsif params[:type] == "Reboot"
        response = ec2.client.reboot_instances({instance_ids: [params[:instance_id]]})
        status = (response.return == "true")
      end
      
      if status
        flash[:notice] = "Instance #{params[:type]} successfully"
      else
        flash[:alert] = "Some error occur while #{params[:type]} instance"
      end

      redirect_to instances_elements_path
  end

  def export_csv
    @schedules = current_user.schedules
    csv_string = CSV.generate do |csv|
      csv << ["name", "instances", "events"]
      @schedules.each do |sch|
        csv << [sch.name, Hash[sch.instances.map{|cc| [cc.instance, cc.region]}], sch.events.map{|cc| ["action" => cc.action, "frequency" => cc.frequency, "event_time" => cc.event_time.strftime("%H:%M"), "day_of_week" => cc.day_of_week.to_s, "day_of_month" => cc.day_of_month.to_s]}.flatten]
      end
    end
  
    send_data csv_string,
    :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=instance_schedules.csv"
  end

  def import_csv
    begin
      if params[:file]
        if params[:file].content_type == 'text/csv'
          created, error = Schedule.import(params[:file], current_user)
          flash[:notice] = "#{created} instances schedules imported and #{error} instances schedules not get imported"
          redirect_to :back
        else
          flash[:alert] = "Choose valid CSV file";
          redirect_to :back
        end
      end
    rescue
      flash[:alert] = "There is some problem with CSV fields, Please verify the csv format of fields by using Export option"
      redirect_to :back
    end
  end

private
  def schedule_params
    params.require(:schedule).permit(:name, :events_attributes => [:action, :frequency, :event_time, :day_of_week, :day_of_month], :instances_attributes => [:instance, :region])
  end
  
  def old_schedule_params
    params.require(:schedule).(:instances_attributes).permit(:instance, :region)
  end
end
