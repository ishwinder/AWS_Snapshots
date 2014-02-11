module ApplicationHelper
  def flash_class(type)
   case type
     when :alert
       "alert alert-error"
     when :error
       "alert alert-error"
     when :notice
       "alert alert-success"
     else
       ""
     end
  end

  def instance_state_class(state)
    case state
     when 'pending'
       "label"
     when 'running'
       "label label-success"
     when 'shutting-down'
       "label label-warning"
     when 'terminated'
       "label label-inverse"
     when 'stopping'
       "label label-important"
     when 'stopped'
       "label label-important"
     else
       "label"
     end
  end

  def snapshot_state_class(state)
    case state
     when 'pending'
       "label label-warning"
     when 'completed'
       "label label-success"
     when 'error'
       "label label-important"
     else
       "label"
     end
  end

  def volume_state_class(state)
    case state
     when 'creating'
       "label"
     when 'available'
       "label label-warning"
     when 'in-use'
       "label label-success"
     when 'error'
       "label label-inverse"
     when 'deleting'
       "label label-important"
     when 'deleted'
       "label label-important"
     else
       "label"
     end
  end
  
  def event_state_class(state)
    case state
     when 'Success'
       "label label-success"
     when 'Failure'
       "label label-important"
     else
       "label"
     end
  end

  def ami_state_class(state)
    case state
     when 'pending'
       "label label-warning"
     when 'available'
       "label label-success"
     when 'error'
       "label label-important"
     else
       "label"
     end
  end
end
