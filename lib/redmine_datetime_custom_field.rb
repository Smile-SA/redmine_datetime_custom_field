
Rails.configuration.to_prepare do
  require_dependency 'redmine_datetime_custom_field/hooks/hooks'
  
  require_dependency 'redmine_datetime_custom_field/patches/application_helper_patch'
  require_dependency 'redmine_datetime_custom_field/patches/field_format_patch'
  require_dependency 'redmine_datetime_custom_field/patches/custom_fields_helper_patch'

  require_dependency 'redmine_datetime_custom_field/patches/query_patch'
  Query.send(:prepend, DatetimeCustomFieldQueryPatch)
end