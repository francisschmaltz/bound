require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class AAAA < Bound::RecordType

      self.type_name = "AAAA"
      self.type_description = "An IPv6 address for a host"

      def fields
        [
          {:name => 'ip', :label => "IPv6 Address"}
        ]
      end

      def validate(hash, errors)
        if hash['ip'].blank? || !(hash['ip'] =~ /\A[A-Fa-f0-9\:]+\z/)
          errors << "Address is not a valid IPv6 address"
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
