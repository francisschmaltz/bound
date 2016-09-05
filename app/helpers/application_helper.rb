module ApplicationHelper

  def breadcrumb(*args)
    @breadcrumbs ||= []
    @breadcrumbs.push(args)
  end

  def breadcrumbs
    @breadcrumbs ||= []
    @breadcrumbs
  end

  def header_action(*args)
    @header_actions ||= []
    @header_actions.push(args)
  end

  def header_actions
    @header_actions ||= []
    @header_actions
  end

  def render_header(title)
    render :locals => {:title => title}, :partial => "shared/header"
  end

  def record_type_tag(type)
    if type.is_a?(Bound::RecordType)
      color = type.class.color || "333333"
      content_tag :span, type.type, :class => "lozenge", :style => "background-color: ##{color}; text-align: center; width: 72px;"
    else
      type
    end
  end

  def record_type_field_tag(record, type, field)
    field_name = "record[form_data][#{field[:name]}]"
    value = @record.form_data.is_a?(Hash) ? @record.form_data[field[:name].to_s] : nil
    if field[:type] == "textarea"
      text_area_tag field_name, value, :class => "formControl formControl--textarea", :rows => 4
    else
      text_field_tag field_name, value, :class => "formControl"
    end
  end

end
