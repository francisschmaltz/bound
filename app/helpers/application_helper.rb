module ApplicationHelper

  def record_type_tag(type)
    if type
      content_tag :span, type.type, :class => "recordTypeTag", :style => "background-color:##{type.class.color || '333'};"
    end
  end

  def record_type_field_tag(record, type, field)
    field_name = "record[form_data][#{field[:name]}]"
    value = @record.form_data.is_a?(Hash) ? @record.form_data[field[:name].to_s] : nil
    if field[:type] == 'textarea'
      text_area_tag field_name, value, :class => "textInput textInput--shortArea"
    else
      text_field_tag field_name, value, :class => "textInput"
    end
  end

end
