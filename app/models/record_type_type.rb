class RecordTypeType < ActiveModel::Type::Value

  def cast(value)
    if type = Bound::RecordType.all[value]
      type
    else
      value
    end
  end

  def serialize(value)
    if value.is_a?(Bound::RecordType)
      value.class.name
    else
      value
    end
  end

  def deserialize(value)
    value.is_a?(String) ? Bound::RecordType.all[value] : nil
  end

end
