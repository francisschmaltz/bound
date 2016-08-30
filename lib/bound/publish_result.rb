module Bound
  class PublishResult

    attr_accessor :zone_files_exported
    attr_accessor :zone_files_deleted
    attr_accessor :configuration_check
    attr_accessor :configuration_errors
    attr_accessor :reload

    def initialize
      @zone_files_exported = []
      @zone_files_deleted = []

      @configuration_check = nil
      @reload = nil
    end

    def success?
      reload == true
    end

  end
end
