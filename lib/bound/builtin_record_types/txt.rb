require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class TXT < Bound::RecordType

      self.type_name = "TXT"
      self.type_description = "Text information associated with a name"

      def fields
        [
          {:name => 'data', :label => 'Text data'}
        ]
      end

      def validate(hash, errors)
        if hash['data']
          if hash['data'].starts_with?('"') && hash['data'].ends_with?('"')
            errors << "Data does not need be enclosed in quotes - these are added when exported"
          end
        end
      end

      def prepare_for_bind(value)
        '"' + value.to_s + '"'
      end

      def serialize(hash)
        hash['data']
      end

      def deserialize(string)
        {'data' => string}
      end

    end
  end
end
