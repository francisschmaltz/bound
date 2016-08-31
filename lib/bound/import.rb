module Bound
  class Import

    def initialize(zone, zone_file)
      @zone = zone
      @zone_file = zone_file
    end

    def records
      @records ||= begin
        if @zone_file.blank?
          []
        else
          @zone_file.gsub(/\r/, '').strip.split(/\n/).each_with_object([]) do |line, array|
            next if line.starts_with?(';')
            next if line.blank?
            parts = line.strip.split(/\s+/)
            record = Record.new(:zone => @zone)
            record.name = parts.shift

            next_part = parts.shift
            unless next_part == "IN"
              record.ttl= next_part
              parts.shift # remove the next IN
            end
            imported_type = parts.shift.to_s.upcase
            if type = Bound::RecordType.all.values.find { |type| type.type == imported_type }
              record.type = type.class.to_s
              record.form_data = record.type.deserialize(parts.join(' '))
              record.serialize_form_data
            end
            record.validate
            array << record
          end.sort_by { |r| r.name.to_s }
        end
      end
    end

    def import
      records.each_with_object([]) do |record, imported|
        next unless record.valid?
        unless @zone.records.where(:name => record.name, :type => record.type, :data => record.data).exists?
          if record.save!
            imported << record
          end
        end
      end
    end

  end
end
