class HostnameValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value.is_a?(String) && value.present?
      unless value =~ /\A[a-z0-9\-\.]+\z/
        record.errors.add attribute, :invalid
      end
    end
  end

end
