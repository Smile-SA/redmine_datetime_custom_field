require_dependency 'custom_fields_helper'

module DatetimeCustomField
  module CustomFieldsHelperPatch
    def self.prepended(base)
      base.module_eval do
        ####################################
        # Plugin specific : method REWRITTEN
        #
        # Return a string used to display a custom value
        def format_value_with_datetime_custom_field(value, custom_field)
          formatted_value = custom_field.format.formatted_value(self, custom_field, value, false)
          if custom_field.format.format_name == 'datetime'
            format_time(formatted_value, true)
          else
            format_object(formatted_value, false)
          end
        end

        base.instance_eval do
          alias_method :format_value_without_datetime_custom_field, :format_value
          alias_method :format_value, :format_value_with_datetime_custom_field
        end
      end
    end
  end
end

CustomFieldsHelper.prepend(DatetimeCustomField::CustomFieldsHelperPatch)
