require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class TXT < Bound::RecordType

      self.type_name = "TXT"
      self.type_description = "Text information associated with a name"

      def validate(value, errors)
        if value.starts_with?('"') && value.ends_with?('"')
          errors << "Data does not need be enclosed in quotes - these are added when exported"
        end
      end

      def prepare_for_bind(value)
        '"' + value.to_s + '"'
      end

    end
  end
end
