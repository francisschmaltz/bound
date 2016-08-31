require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class CNAME < Bound::RecordType

      self.type_name = "CNAME"
      self.color = 'f1ad3b'

      def fields
        [
          {:name => 'name', :label => "Canonical Name"}
        ]
      end

      def validate(hash, errors)
        if hash['name'].blank?
          errors << "Canonical Name must be provided"
        end
      end

      def serialize(hash)
        hash['name']
      end

      def deserialize(string)
        {'name' => string}
      end

    end
  end
end
