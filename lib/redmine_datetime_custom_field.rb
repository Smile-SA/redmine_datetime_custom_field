
Rails.configuration.to_prepare do
  require 'redmine_datetime_custom_field/hooks/hooks'
  
  require 'redmine_datetime_custom_field/patches/application_helper_patch'
  require 'redmine_datetime_custom_field/patches/field_format_patch'
  require 'redmine_datetime_custom_field/patches/custom_fields_helper_patch'

  require 'datetime_custom_field_query_patch'
  Query.send(:prepend, DatetimeCustomFieldQueryPatch)
end