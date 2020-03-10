
Rails.configuration.to_prepare do
  require 'hooks'
  
  require 'datetime_custom_field_application_helper_patch'
  require 'datetime_custom_field_field_format_patch'
  require 'datetime_custom_field_custom_fields_helper_patch'

  require 'datetime_custom_field_query_patch'
  Query.send(:prepend, DatetimeCustomFieldQueryPatch)
end