class BurndownListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    flot_graphs_includes + "\n"
  end
end