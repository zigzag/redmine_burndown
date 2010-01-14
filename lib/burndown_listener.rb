class BurndownListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    flot_graphs_includes + "\n" +
    javascript_include_tag('burndowns', :plugin => 'redmine_burndown') + "\n"
  end

  # <%= call_hook(:view_timelog_edit_form_bottom, { :time_entry => @time_entry, :form => f }) %>
  def view_timelog_edit_form_bottom(context={})
    time_entry = context[:time_entry]
    issue = time_entry.issue
    return unless issue
    debugger
    html = <<HTML_END
    <div class='flash warning'>
      Before your entry, <b>#{issue.spent_hours}</b> hours have been spent on Issue ##{issue.id} 
      (Estimated <b>#{issue.estimated_hours}</b> hours).
    </div>    
HTML_END
  end
end