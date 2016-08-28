module ApplicationHelper

  def record_type_field_tag(record, type, field)
    field_name = "record[form_data][#{field[:name]}]"
    value = @record.form_data.is_a?(Hash) ? @record.form_data[field[:name].to_s] : nil
    text_field_tag field_name, value
  end

end
