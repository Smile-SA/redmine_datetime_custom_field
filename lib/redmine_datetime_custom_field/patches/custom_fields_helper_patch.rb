require_dependency 'custom_fields_helper'

module CustomFieldsHelper
  ####################################
  # Plugin specific : method REWRITTEN
  #
  # Return a string used to display a custom value
  def format_value(value, custom_field)
    formatted_value = custom_field.format.formatted_value(self, custom_field, value, false)
    if formatted_value.class == DateTime
      format_time_without_zone(formatted_value, true)
    else
      format_object(formatted_value, false)
    end
  end
end
