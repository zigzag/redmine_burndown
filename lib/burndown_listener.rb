class BurndownListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    flot_graphs_includes + "\n" +
    javascript_include_tag('burndowns', :plugin => 'redmine_burndown') + "\n"
  end
end