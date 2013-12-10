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
end
