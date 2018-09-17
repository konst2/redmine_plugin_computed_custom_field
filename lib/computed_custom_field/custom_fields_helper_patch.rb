module ComputedCustomField
  module CustomFieldsHelperPatch

    def self.included(base) #:nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        unloadable
        
        alias_method_chain :custom_field_tag, :computed_custom_field
      end
    end

    module ClassMethods
    end
    
    module InstanceMethods
      def custom_field_tag_with_computed_custom_field(prefix, custom_value)
        rendered_field = custom_value.custom_field.format.edit_tag self,
          custom_field_tag_id(prefix, custom_value.custom_field),
          custom_field_tag_name(prefix, custom_value.custom_field),
          custom_value,
          :class => "#{custom_value.custom_field.field_format}_cf",
          :disabled => custom_value.custom_field.is_computed?
        if custom_value.custom_field.is_computed?
          str_rendered_field = "#{rendered_field}"
          str_rendered_field.gsub! '<input type="radio" ', '<input type="radio" disabled '
          rendered_field = ActiveSupport::SafeBuffer.new(str_rendered_field)
        end
        rendered_field
      end
    end

    def render_computed_custom_fields_select(custom_field)
      fields = CustomField.where(type: custom_field.type)
                          .where('custom_fields.id != ?', custom_field.id || 0)
      options = fields.map do |field|
        is_computed = field.is_computed? ? ", #{l(:field_is_computed)}" : ''
        format = I18n.t(field.format.label)
        title = "#{field.name} (#{format}#{is_computed})"
        html_attributes = {
          value: field.id,
          title: title
        }
        content_tag_string(:option, title, html_attributes)
      end.join("\n").html_safe

      select_tag '', options, size: 5,
                              multiple: true, id: 'available_cfs'
    end
  end

end

unless CustomFieldsHelper.included_modules
                         .include?(ComputedCustomField::CustomFieldsHelperPatch)
  CustomFieldsHelper.send :include, ComputedCustomField::CustomFieldsHelperPatch
end
