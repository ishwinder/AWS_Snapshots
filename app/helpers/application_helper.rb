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
end
