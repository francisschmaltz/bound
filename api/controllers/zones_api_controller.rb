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

end
