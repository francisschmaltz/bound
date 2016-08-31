require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class MX < Bound::RecordType

      self.type_name = "MX"
      self.color = '805dd3'

      def fields
        [
          {:name => 'host',     :label => 'Hostname'},
          {:name => 'priority', :label => 'Priority'}
        ]
      end

      def validate(vaule, errors)
        if vaule['host'].blank?
          errors << "A hostname must be entered for an MX"
        end

        unless vaule['priority'].to_s =~ /\A\d+\z/
          errors << "A priority must be a number"
        end
      end

      def serialize(hash)
        [hash['priority'].to_i, hash['host']].join(' ')
      end

      def deserialize(string)
        priority, host = string.split(/ /, 2)
        {
          'priority' => priority,
          'host' => host
        }
      end

    end
  end
end
