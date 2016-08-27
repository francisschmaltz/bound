class ZonesController < ApplicationController

  def index
    @zones = Zone.order(:name)
  end

end
