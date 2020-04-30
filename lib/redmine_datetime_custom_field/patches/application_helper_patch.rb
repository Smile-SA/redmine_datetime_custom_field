require_dependency 'application_helper'

module ApplicationHelper

    #** datetime_for
    def datetime_for( field_id, aOptions = {} )
        tag = "\n".html_safe + javascript_tag( datetime_js_code_for( field_id, aOptions ) )
    end
    
    #** datetime_js_code_for
    def datetime_js_code_for( field_id, aOptions = {} )
        options = datetime_options( aOptions )    
        code = "$(function() { $('##{field_id}').datetimepicker(#{options}); });".html_safe
    end
  
    #** datetime_options
    def datetime_options( aOptions = {} )
        return aOptions if aOptions.class.name == 'String' 
        
        start_of_week = Setting.start_of_week
        start_of_week = l(:general_first_day_of_week, :default => '1') if start_of_week.blank?

        # Redmine uses 1..7 (monday..sunday) in settings and locales
        # JQuery uses 0..6 (sunday..saturday), 7 needs to be changed to 0
        start_of_week = start_of_week.to_i % 7

        jquery_locale = l( 'jquery.locale', :default => current_language.to_s )
        options = {
            'format' => 'Y-m-d H:i',
            'dayOfWeekStart' => start_of_week,
            'closeOnDateSelect' => true,
            'lang' => jquery_locale
        }.merge( aOptions )
        
        # puts "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU 0:" + options.inspect
        # Handle events in options. We have to pass it as js-code, not as json-string
        events = []
        [ :onSelectDate, :onSelectTime, :onChangeMonth, :onChangeYear, :onChangeDateTime, :onShow, :onClose, :onGenerate ].each {|e|
            has_symbol = options.has_key?(e)
            has_string = !has_symbol && options.has_key?( e.to_s )
            next unless ( has_symbol || has_string )
            e = e.to_s if has_string
            
            # puts e
            events.push( e.to_s + ':' + options[e] )
            options.delete(e)
        }
        # puts "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU 1: " + events.inspect
        
        options = ActiveSupport::JSON.encode( options )
        if events.count > 0 
            options = options.sub( /}$/, ', ' + events.join( ',' ) + '}' )
        end
        
        # puts options.inspect
        options
    end
  
=begin
  ###################
  # Plugin new method
  def include_datetime_headers_tags
    return '' if @datetime_headers_tags_included

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
        "//console.log( 11111111111111111 );" +
        "//jQuery.datetimepicker.setLocale('#{jquery_locale}');" +
        "var datetimepickerOptions={format: 'Y-m-d H:i', dayOfWeekStart: #{start_of_week}," +
          "closeOnDateSelect:true," +
          "lang:'#{jquery_locale}'," +
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
=end
end

# "$('##{field_id}').after('<input class=\"ui-datepicker-trigger\" id=\"'##{field_id}_img'\" src=\"" + image_path('calendar.png') + "\" />');" +
