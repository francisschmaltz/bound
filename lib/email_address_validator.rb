class EmailAddressValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value.is_a?(String) && value.present?
      unless value =~ /\A\b[A-Z0-9\.\_\%\-\+]+@(?:[A-Z0-9\-]+\.)+[A-Z]{2,}\b\z/i
        record.errors.add attribute, :invalid
      end
    end
  end

end
