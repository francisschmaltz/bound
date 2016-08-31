module Bound
  class RecordType

    class << self
      attr_accessor :type_name
      attr_accessor :color

      def all
        @all ||= ObjectSpace.each_object(Class).select { |klass| klass < self }.sort_by { |a| a.type_name }.each_with_object({}) do |type, hash|
          hash[type.name] = type.new
        end
      end

    end

    # Return the name of the type
    def type
      @type ||= self.class.name.split('::').last
    end

    # Return an array of additional fields which are prompted for when
    # this record is added.
    def fields
      []
    end

    # This method will receive the user submitted hash and it should add errors
    # to the provided array. If nothing is added, the record is considered value.
    def validate(hash, errors)
    end

    # The user will provide a hash of values (for the fields defined above).
    # This method should serialize the data for storage in the database's data
    # column. It should be much like will be presented to BIND (although additional
    # manipulations can be made with the prepare_for_bind method which is used
    # on export).
    def serialize(hash)
      hash.inspect
    end

    # This method will receive a serialized string and it should be convert into
    # a hash. This will be provided back to the form for editting records.
    def deserialize(string)
      string
    end

    # This method will receive the serialized string and it should return the
    # value which should be exported into the bind config file.
    def prepare_for_bind(string)
      string
    end

  end
end
