class ScheduledSnapshotsController < ApplicationController

  respond_to :js, :html

  def index
    respond_with @scheduled_snapshots = current_user.scheduled_snapshots
  end

  def create
    @scheduled_snapshot = current_user.scheduled_snapshots.new(snapshot_params)
    if @scheduled_snapshot.save
      flash[:notice] = "Snapshot Scheduled Successfully!!"
      redirect_to @scheduled_snapshot
    else
      flash[:alert] = "There was some problem in scheduling snapshot - #{@scheduled_snapshot.errors.full_messages.join(', ')}"
      redirect_to root_path
    end
  end

  def show
    @snapshot = ScheduledSnapshot.find(params[:id])
    @snapshot_summary = @snapshot.snapshot_summaries
    respond_with @snapshot, @snapshot_summary
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
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [])
      when "Hourly"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [], :time_of_day => [])
      when "Daily"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [], :day_of_week => [])
      when "Weekly"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [])
      when "Monthly"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_times, :retention_period, :volume_id => [], :month_of_year => [])
      end
  end
end
