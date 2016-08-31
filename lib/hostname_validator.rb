class HostnameValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value.is_a?(String) && value.present?
      unless value =~ /\A[A-Za-z0-9\-\.\_]+\z/
        record.errors.add attribute, :invalid
      end
    end
  end

end
