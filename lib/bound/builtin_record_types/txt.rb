require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class TXT < Bound::RecordType

      self.type_name = "TXT"
      self.color = '62d49f'

      def fields
        [
          {:name => 'data', :label => 'Text data', :type => 'textarea'}
        ]
      end

      def validate(hash, errors)
        if hash['data']
          if hash['data'].starts_with?('"') && hash['data'].ends_with?('"')
            errors << "Data does not need be enclosed in quotes - these are added when exported"
          end
        end
      end

      def serialize(hash)
        '"' + hash['data'] + '"'
      end

      def deserialize(string)
        {'data' => string.gsub(/\A\"/, '').gsub(/\"\z/, '')}
      end

    end
  end
end
