require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class SRV < Bound::RecordType

      self.type_name = "SRV"
      self.color = 'df2b6b'

      def fields
        [
          {:name => 'priority', :label => 'Priority'},
          {:name => 'weight', :label => 'Weight'},
          {:name => 'port', :label => 'Port'},
          {:name => 'target', :label => 'Target'}
        ]
      end

      def validate(vaule, errors)
        if vaule['target'].blank?
          errors << "A target must be entered"
        end

        unless vaule['priority'].to_s =~ /\A\d+\z/
          errors << "A priority must be a number"
        end

        unless vaule['weight'].to_s =~ /\A\d+\z/
          errors << "A weight must be a number"
        end

        unless vaule['port'].to_s =~ /\A\d+\z/
          errors << "A port must be a number"
        end
      end

      def serialize(hash)
        [hash['priority'].to_i, hash['weight'].to_i, hash['port'].to_i, hash['target']].join(' ')
      end

      def deserialize(string)
        priority, weight, port, target = string.split(/ /, 4)
        {
          'priority' => priority,
          'weight' => weight,
          'port' => port,
          'target' => target
        }
      end

    end
  end
end
