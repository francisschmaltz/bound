controller :publishing do

  friendly_name "Publishing API"
  description "This API handles the publishing of the current configuration to DNS servers"

  action :pending_changes do
    title "View pending changes"
    description "This action will return a list of all pending changes"
    returns Hash, :structure => :change, :structure_opts => {:full => true}
    action do
      Change.pending.map { |c| structure c, :return => true }
    end
  end

  action :apply do
    title "Apply all pending changes"
    description "This action will apply all pending changes"
    returns Hash, :structure => :publish_result
    action do
      publisher = Bound::Publisher.new
      publisher.publish
      structure :publish_result, publisher.result, :return => true
    end
  end

end
