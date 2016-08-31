require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class NS < Bound::RecordType

      self.type_name = "NS"
      self.color = '969696'

      def fields
        [
          {:name => 'name', :label => "Nameserver"}
        ]
      end

      def validate(hash, errors)
        if hash['name'].blank?
          errors << "Nameserver must be provided"
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
