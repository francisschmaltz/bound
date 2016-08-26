require 'bound/record_type'

module Bound
  module BuiltinRecordTypes
    class A < Bound::RecordType

      self.type_name = "A"
      self.type_description = "An IPv4 address for a host"

    end
  end
end
