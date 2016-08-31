require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class A < Bound::RecordType

      self.type_name = "A"
      self.color = '2b82df'

      def fields
        [
          {:name => 'ip', :label => "IPv4 Address"}
        ]
      end

      def validate(hash, errors)
        if hash['ip'].blank? || !(hash['ip'].to_s =~ /\A\d+\.\d+\.\d+\.\d+\z/)
          errors << "Address is not a valid IPv4 address"
        end
      end

      def serialize(hash)
        hash['ip']
      end

      def deserialize(string)
        {'ip' => string}
      end

    end
  end
end
