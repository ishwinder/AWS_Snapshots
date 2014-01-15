class ScheduledSnapshotsController < ApplicationController

  respond_to :js, :html

  def index
    respond_with @scheduled_snapshots = current_user.scheduled_snapshots.order('created_at DESC')
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
    @snapshot = current_user.scheduled_snapshots.find(params[:id])
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
  
  def create_csv
    @scheduled_snapshots = current_user.scheduled_snapshots.order('created_at DESC')
    csv_string = CSV.generate do |csv|
      csv << ["volume_id", "description", "frequency","start_date", "end_date", "start_time", "retention_period", "time_of_day", "day_of_week", "month_of_year", "tags"]
      @scheduled_snapshots.each do |ss|
        csv << [ss.volume_id.join(", "), ss.description, ss.frequency, ss.start_date, ss.end_date, ss.start_time.strftime("%H:%M"), ss.retention_period, ss.time_of_day.join(", "), ss.day_of_week.join(", "), ss.month_of_year.join(", "), Hash[ss.tags.map{|cc| [cc.key, cc.value]}]]
      end
    end
  
    send_data csv_string,
    :type => 'text/csv; charset=iso-8859-1; header=present',
    :disposition => "attachment; filename=scheduled_snapshot.csv" 
  end
  
  def import_csv
    begin
      if params[:file]
        if params[:file].content_type == 'text/csv'
          created, error = ScheduledSnapshot.import(params[:file], current_user)
          flash[:notice] = "#{created} snapshot schedules imported and #{error} snapshot schedules not get imported"
        else
          flash[:alert] = "Choose valid csv file"
        end
      end
    rescue
      flash[:alert] = "There is some problem with CSV fields, Please verify the csv format of fields by using Export option"
      redirect_to :back
    end
  end

  private
  def snapshot_params
    case params[:scheduled_snapshot][:frequency]
      when "None"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [], :tags_attributes => [:key, :value])
      when "Hourly"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [], :time_of_day => [], :tags_attributes => [:key, :value])
      when "Daily"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [], :day_of_week => [], :tags_attributes => [:key, :value])
      when "Weekly"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [], :tags_attributes => [:key, :value])
      when "Monthly"
        params.require(:scheduled_snapshot).permit(:description, :frequency, :start_date, :end_date, :start_time, :retention_period, :volume_id => [], :month_of_year => [], :tags_attributes => [:key, :value])
      end
  end
end
