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
        data = hash['data']
        if data.blank?
          '""'
        else
          total_length = data.size
          parts, remainder = total_length.divmod(255)
          parts = parts + (remainder > 0 ? 1 : 0)
          array = []
          parts.times do |i|
            array << '"' + data[i * 255, 255] + '"'
          end
          array.join(' ')
        end
      end

      def deserialize(string)
        {'data' => string.to_s.scan(/\".*?\"/).map { |s| s.gsub(/\A\"/, '').gsub(/\"\z/, '') }.join}
      end

    end
  end
end
