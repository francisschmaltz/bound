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
          @zone_file.gsub(/\r/, '').strip.split(/\n/).map(&:strip).each_with_object([]) do |line, array|
            next if line.starts_with?(';')
            next if line.blank?
            parts = line.split(/\s+/)
            record = Record.new(:zone => @zone)
            record.name = parts.shift

            next_part = parts.shift
            unless next_part == "IN"
              record.ttl= next_part
              parts.shift # remove the next IN
            end
            imported_type = parts.shift.to_s.upcase
            data = parts.join(' ')
            if type = Bound::RecordType.all.values.find { |type| type.type == imported_type }
              record.type = type.class.to_s
              record.form_data = record.type.deserialize(data)
              record.serialize_form_data
            else
              record.type = imported_type
              record.data = data
            end
            record.validate
            array << record
          end.sort_by { |r| r.name.to_s }
        end
      end
    end

    def import
      stats = {:total => records.size, :imported => 0, :duplicates => 0, :errored => 0}
      records.each_with_object([]) do |record, imported|
        if @zone.records.where(:name => record.name, :type => record.type, :data => record.data).exists?
          stats[:duplicates] += 1
        else
          if record.save
            stats[:imported] += 1
            imported << record
          else
            stats[:errored] += 1
          end
        end
      end
      stats
    end

  end
end
