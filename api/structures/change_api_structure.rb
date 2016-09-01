structure :change do
  basic :id, "The ID of the change", :type => Integer, :eg => 1234
  basic :zone_id, "The ID of the zone this change relates to", :type => Integer, :eg => 3
  basic :event, "The name of the event", :type => String, :eg => "ZoneAdded"
  basic :name, "The name of the zone/record", :type => String, :eg => "atechmedia.com"
  basic :attribute_name, "The name of an updated attribute (if applicable)", :type => String, :eg => "ttl"
  basic :old_value, "The old value (if applicable)", :type => String, :eg => "2.2.2.2"
  basic :new_value, "The new value (if applicable)", :type => String, :eg => "6.6.6.6"
end
