module FormHelper

  def error_messages_for(resource)
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join

    html = <<-HTML
    <div class="alert alert-error">
      <h3>Unfortunately the form could not be saved:</h3>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

end