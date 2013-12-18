class ScheduledSnapshotsController < ApplicationController

  respond_to :js, :html

  def index
    respond_with @scheduled_snapshots = current_user.scheduled_snapshots
  end

  def create
    @scheduled_snapshot = current_user.scheduled_snapshots.new(snapshot_params)
    if @scheduled_snapshot.save
      flash[:notice] = "Snapshot Scheduled Successfully!!"
    else
      flash[:alert] = "There was some problem in scheduling snapshot - #{@scheduled_snapshot.errors.full_messages.join(', ')}"
    end
    redirect_to root_path
  end

  def show
    respond_with @snapshot = ScheduledSnapshot.find(params[:id])
  end

  def destroy
    @result = Resque.get_schedule("scheduling_snapshot_#{params[:id]}")
    if @result.present?
      Resque.remove_schedule("scheduling_snapshot_#{params[:id]}")
    end
    @snapshot = ScheduledSnapshot.find(params[:id])
    if @snapshot.destroy
      flash[:notice] = "Snapshot Schedule dropped successfully"
    else
      flash[:alert] = "There was some problem in droping scheduling snapshot"
    end
    redirect_to scheduled_snapshots_path
  end


  private
  def snapshot_params
    case params[:scheduled_snapshot][:frequency]
      when "None"
        params.require(:scheduled_snapshot).permit(:volume_id, :description, :start_date, :end_date, :start_time, :frequency)
      when "Hourly"
        params.require(:scheduled_snapshot).permit(:volume_id, :description, :start_date, :end_date, :start_time, :frequency, :time_of_day => [])
      when "Daily"
        params.require(:scheduled_snapshot).permit(:volume_id, :description, :start_date, :end_date, :start_time, :frequency, :day_of_week => [])
      when "Weekly"
        params.require(:scheduled_snapshot).permit(:volume_id, :description, :start_date, :end_date, :start_time, :frequency)
      when "Monthly"
        params.require(:scheduled_snapshot).permit(:volume_id, :description, :start_date, :end_date, :start_time, :frequency, :month_of_year => [])
      end
  end
end
