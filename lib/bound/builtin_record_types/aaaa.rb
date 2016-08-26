require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class AAAA < Bound::RecordType

      self.type_name = "AAAA"
      self.type_description = "An IPv6 address for a host"

    end
  end
end
