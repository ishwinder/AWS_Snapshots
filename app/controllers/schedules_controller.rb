class SchedulesController < ApplicationController

  respond_to :js, :html

  def index
    @schedules = current_user.schedules
    respond_with @schedules
  end

  def create
    @schedule = current_user.schedules.new(schedule_params)
    if @schedule.save
      flash[:notice] = "Schedule Successfully Created!!"
      redirect_to root_path
    else
      flash[:alert] = "There was some problem in creating schedule - #{@schedule.errors.full_messages.join(', ')}"
      redirect_to root_path
    end
  end

  def show
    @schedule = current_user.schedules.find(params[:id])
  end

private
  def schedule_params
    params.require(:schedule).permit(:name, :instances => [], :events_attributes => [:action, :frequency, :event_time, :day_of_week, :day_of_month], :instances_attributes => [:instance, :region])
  end
end
