structure :zone do
  basic :id, "The ID of the zone", :type => Integer, :eg => 1234
  basic :name, "The full name of the zone", :type => String, :eg => "atechmedia.com"
  basic :serial, "The current serial number of the zone", :type => Integer, :eg => 58
  basic :updated_at, "The time this zone (or any of its records) was last updated", :type => :timestamp

  full :primary_ns, "The name of the primary nameserver", :type => String, :eg => "dns1.atechmedia.com"
  full :email_address, "The e-mail address of the hostmaster", :type => String, :eg => "hostmaster@atechmedia.com"
  full :refresh_time, "The refresh time for the zone", :type => Integer, :eg => 3600
  full :retry_time, "The retry time for the zone", :type => Integer, :eg => 120
  full :expiration_time, "The expiration time for the zone", :type => Integer, :eg => 2419200
  full :max_cache, "The maximum cache length for the zone", :type => Integer, :eg => 600
  full :ttl, "The default TTL for records within the zone", :type => Integer, :eg => 3600
  full :published_at, "The time this zone was last published", :type => :timestamp
  full :created_at, "The time this zone was created", :type => :timestamp
  full :reverse?, "Is this a reverse zone", :type => :boolean
  full :reverse_version, "What type of subnet is this a reverse zone for?", :type => Integer
  full :reverse_subnet, "What's the subnet for the zone?", :type => String, :value => proc { o.reverse_subnet&.to_s }

  expansion :pending_changes, "The number of pending changes", :type => Integer do
    o.pending_changes.size
  end
end
