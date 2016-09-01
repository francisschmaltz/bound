require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class PTR < Bound::RecordType

      self.type_name = "PTR"
      self.color = 'e93535'

      def fields
        [
          {:name => 'name', :label => "Hostname"}
        ]
      end

      def validate(hash, errors)
        if hash['name'].blank?
          errors << "Hostname must be provided"
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
