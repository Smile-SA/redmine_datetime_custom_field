require_dependency 'application_helper'

module ApplicationHelper
  ###################
  # Plugin new method
  def datetime_for(field_id)
    include_datetime_headers_tags

    a = javascript_tag("var datetimepickerOptions={format: 'Y-m-d H:i', closeOnDateSelect:true };")
    a << "\n".html_safe +
      javascript_tag(
        "$(function() { " +
        "$('##{field_id}').datetimepicker(datetimepickerOptions); " +
        "});"
      )
    a
  end

  ###################
  # Plugin new method
  def include_datetime_headers_tags
    return if @datetime_headers_tags_included

    tags = ''.html_safe
    @datetime_headers_tags_included = true

#    content_for :header_tags do
#      tags = javascript_include_tag(
#          'jquery.datetimepicker.js',
#          plugin: 'redmine_datetime_custom_field'
#        ) +
#        stylesheet_link_tag(
#          'jquery.datetimepicker.css',
#          plugin: 'redmine_datetime_custom_field'
#        )
    start_of_week = Setting.start_of_week
    start_of_week = l(:general_first_day_of_week, :default => '1') if start_of_week.blank?

    # Redmine uses 1..7 (monday..sunday) in settings and locales
    # JQuery uses 0..6 (sunday..saturday), 7 needs to be changed to 0
    start_of_week = start_of_week.to_i % 7

    jquery_locale = l('jquery.locale', :default => current_language.to_s)

    tags << "\n".html_safe +
      javascript_tag(
        "jQuery.datetimepicker.setLocale('#{jquery_locale}');" +
        "var datetimepickerOptions={format: 'Y-m-d H:i', dayOfWeekStart: #{start_of_week}," +
          "closeOnDateSelect:true," +
          "id:'datetimepicker' };" +

         "function datetimepickerCreate(id){" +
            "$(id).after( '<input alt=\"...\" class=\"ui-datepicker-trigger\" data-parent=\"'+id+'\" src=\"" + image_path('calendar.png') + "\" title=\"...\" type=\"image\"/>' );" +
            "$('.ui-datepicker-trigger').click( function(){ $($(this).attr('data-parent')).trigger('focus'); return false; });" +
            "$(id).datetimepicker(datetimepickerOptions).attr('type', 'text');" +
          "}"
      )

    unless jquery_locale == 'en'
      tags << "\n".html_safe + javascript_include_tag("i18n/datepicker-#{jquery_locale}.js")
    end

   tags
#      end
  end
end

# "$('##{field_id}').after('<input class=\"ui-datepicker-trigger\" id=\"'##{field_id}_img'\" src=\"" + image_path('calendar.png') + "\" />');" +
