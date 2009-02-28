class BurndownListener < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    stylesheet_link_tag('burndowns', :plugin => 'redmine_burndown') + "\n"+
    javascript_include_tag('jquery.js', :plugin => 'redmine_burndown') + "\n"+
    javascript_include_tag('jquery.flot.pack.js', :plugin => 'redmine_burndown')+ "\n"+
    javascript_include_tag('excanvas.flot.pack.js', :plugin => 'redmine_burndown')+ "\n"+
    <<EOS
    <script language="JavaScript" type="text/javascript">
      jQuery.noConflict();
    </script>
     <!--[if IE]>
     #{javascript_include_tag "excanvas.pack"}
     <![endif]-->
EOS
  
  end
end