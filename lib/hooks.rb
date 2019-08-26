module RedmineDatetimeCustomField
  class Hooks < Redmine::Hook::ViewListener

    # Add our css/js on each page
    def view_layouts_base_html_head(context)
      stylesheet_link_tag('jquery.datetimepicker.css', plugin: 'redmine_datetime_custom_field') + javascript_include_tag('jquery.datetimepicker.js', plugin: 'redmine_datetime_custom_field')
    end

  end
end
