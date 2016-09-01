shared_action :find_zone do
  param :zone_id, "The ID of the zone", :type => Integer, :required => true
  error 'ZoneNotFound', "No zone was found given the ID provided", :attributes => {:id => "The provided ID"}
  action do
    @zone = Zone.find_by_id(params.zone_id) || error('ZoneNotFound', :zone_id => params.zone_id)
  end
end
