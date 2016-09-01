controller :zones do

  friendly_name "Zones API"
  description "Provides access to manage zones"

  action :list do
    title "List all zones"
    description "This action returns a list of all configured zones"
    returns Array, :structure => :zone
    action do
      z = Zone.order(:name).to_a
      z.map { |z| structure z, :return => true }
    end
  end

  action :info do
    title "Get zone details"
    description "This action returns information about a given zone"
    use :find_zone
    returns Hash, :structure => :zone, :structure_opts => {:full => true, :expansions => [:pending_changes]}
    action do
      structure @zone, :return => true
    end
  end

  shared_action :properties do
    from_structure :zone do
    end
  end

  action :create do
    title "Create a new zone"
    description "This action will create a new zone"
    from_structure :zone do
      param :name, :required => true
      param :primary_ns, :default => Bound.config.dns_defaults.primary_ns
      param :email_address, :default => Bound.config.dns_defaults.email_address
      param :refresh_time, :default => Bound.config.dns_defaults.refresh_time
      param :retry_time, :default => Bound.config.dns_defaults.retry_time
      param :expiration_time, :default => Bound.config.dns_defaults.expiration_time
      param :max_cache, :default => Bound.config.dns_defaults.max_cache
      param :ttl, :default => Bound.config.dns_defaults.ttl
    end
    use :properties
    returns Hash, :structure => :zone, :structure_opts => {:full => true}
    use :validation_error
    action do
      zone = Zone.new
      copy_params_to zone, :name, :primary_ns, :email_address, :refresh_time, :retry_time, :expiration_time, :max_cache, :ttl
      zone.save!
      structure zone, :return => true
    end
  end

  action :update do
    title "Update a zone"
    description "This action will update the properties for a zone"
    use :find_zone
    from_structure :zone do
      param :name
      param :primary_ns
      param :email_address
      param :refresh_time
      param :retry_time
      param :expiration_time
      param :max_cache
      param :ttl
    end
    returns Hash, :structure => :zone, :structure_opts => {:full => true}
    use :validation_error
    action do
      copy_params_to @zone, :name, :primary_ns, :email_address, :refresh_time, :retry_time, :expiration_time, :max_cache, :ttl
      @zone.save!
      structure @zone, :return => true
    end
  end

  action :zone_file do
    title "Download zone file"
    description "This action will provide the raw BIND zone file for a zone"
    use :find_zone
    returns String
    action do
      @zone.generate_zone_file
    end
  end

  action :destroy do
    title "Destroy a zone"
    description "This action will delete a zone"
    use :find_zone
    returns :boolean
    action do
      @zone.destroy!
      true
    end
  end

end
