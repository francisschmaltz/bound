require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class SSHFP < Bound::RecordType

      self.type_name = "SSHFP"
      self.color = '857357'

      def fields
        [
          {:name => 'algorithm', :label => 'Algorithm'},
          {:name => 'fingerprint_type', :label => 'Fingerprint Type'},
          {:name => 'fingerprint', :label => 'Fingerprint'}
        ]
      end

      def validate(vaule, errors)
        if vaule['fingerprint'].blank?
          errors << "A fingerprint must be entered"
        end

        unless vaule['algorithm'].to_s =~ /\A\d+\z/
          errors << "A algorithm must be a number"
        end

        unless vaule['fingerprint_type'].to_s =~ /\A\d+\z/
          errors << "A fingerprint type must be a number"
        end
      end

      def serialize(hash)
        [hash['algorithm'].to_i, hash['fingerprint_type'].to_i, hash['fingerprint']].join(' ')
      end

      def deserialize(string)
        algorithm, fingerprint_type, fingerprint = string.split(/ /, 3)
        {
          'algorithm' => algorithm,
          'fingerprint_type' => fingerprint_type,
          'fingerprint' => fingerprint
        }
      end

    end
  end
end
