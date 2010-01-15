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

    estimated_hours_hint = "(Estimated <b>#{issue.estimated_hours}</b> hours)." if issue.estimated_hours
    tips = <<HTML
    <div class='flash warning'>
      Before your entry, <b>#{issue.spent_hours}</b> hours have been spent on Issue ##{issue.id} 
      #{estimated_hours_hint}
    </div>    
HTML
    links = issue.children.inject('') do |buffer,child| 
      buffer << "<li><a href='/issues/#{child.id}/time_entries/new'>##{child.id} #{child.subject}</a></li>"
    end
    warnning = <<HTML
    <div class='flash error'>
      The issue your choose for time entry is a parent one. Please entry your time into it's children:
      <ul>
        #{links}
      </ul>
    </div>
    <script>
      jQuery(function(){jQuery("[name='commit']").attr('disabled',true)});
    </script>
HTML
    return ((issue.children.size > 0) ? warnning : tips)
  end

end

