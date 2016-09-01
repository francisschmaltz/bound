structure :record do
  basic :id, "The ID of the record", :type => Integer, :eg => 1234
  basic :name, "The name of the record", :type => String, :eg => "www"
  basic :full_name, "The name of the record with the zone suffixed as appropriate", :type => String, :eg => "www.atechmedia.com"
  basic :ttl, "The TTL for the record if it has been overriden", :type => Integer, :eg => 300
  basic :data, "The raw stored data for the record (as exportable to BIND)", :type => String, :eg => "12.34.45.67"
  basic :form_data, "The hash of data that is presented to the form", :type => Hash
  expansion :type, "The type of record", :type => Hash, :structure => :record_type
end
