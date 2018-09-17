Redmine::Plugin.register :computed_custom_field do
  name 'Computed custom field'
  author 'Yakov Annikov. Modified by Konstantin Budnikov'
  url 'https://github.com/konst2/redmine_plugin_computed_custom_field'
  description ''
  version '1.0.6'
  settings default: {}
end

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'computed_custom_field/computed_custom_field'
  require_dependency 'computed_custom_field/custom_field_patch'
  require_dependency 'computed_custom_field/custom_fields_helper_patch'
  require_dependency 'computed_custom_field/model_patch'
  require_dependency 'computed_custom_field/issue_patch'
  require_dependency 'computed_custom_field/hooks'
end

RedmineApp::Application.configure do
  config.after_initialize do
    ComputedCustomField.patch_models
  end
end


Rails.application.config.to_prepare do
  CustomFieldsHelper.send(:include, ComputedCustomField::CustomFieldsHelperPatch)
end
