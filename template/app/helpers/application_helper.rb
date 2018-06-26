module ApplicationHelper

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def bootstrap_icon_for flash_type
    { success: "ok-circle", error: "remove-circle", alert: "warning-sign", notice: "exclamation-sign" }[flash_type.to_sym] || "question-sign"
  end

  def bootstrap_messages msg_type,message 
    concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do 
            concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
            concat content_tag(:i, nil, class: "glyphicon glyphicon-#{bootstrap_icon_for(msg_type)}")
            concat " " << message 
          end)
  end

  def bootstrap_devise_error_messages!
    return '' if resource.errors.empty?
    resource.errors.full_messages.each do |message|
      bootstrap_messages :error,message
    end
    nil
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      bootstrap_messages msg_type,message
    end
    nil
  end
  
end
