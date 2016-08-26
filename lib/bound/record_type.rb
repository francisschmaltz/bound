module Bound
  class RecordType

    class << self
      attr_accessor :type_name
      attr_accessor :type_description

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

    # This method will receive the user submitted value and it should add errors
    # to the provided array. If nothing is added, the record is considered value.
    def validate(value, errors)
    end

    # The user will submit a value from the form which will either be a single
    # text field (if there are no fields) or a hash containing multiple values
    # (if the type has fields). This method will receive the value and it should
    # return a string that will be presented to bind.
    def serialize(value)
      value
    end

    # This method will receive a string and it should be convert into a string
    # (if there are no fields) or a hash (if there are fields). This will be
    # provided back to the user if they edit a record.
    def deserialize(value)
      value
    end

    # This method will receive the serialized string and it should return the
    # value which should be exported into the bind config file.
    def prepare_for_bind(value)
      value
    end

  end
end
