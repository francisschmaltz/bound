class ZonesController < ApplicationController

  before_action { params[:id] && @zone = Zone.find(params[:id]) }

  def index
    @zones = Zone.order(:updated_at => :desc)
  end

  def show
    @records = @zone.records.order(:name, :type).to_a
  end

  def zone_file
    render :plain => @zone.generate_zone_file
  end

  def new
    @zone = Zone.new
  end

  def create
    @zone = Zone.new(safe_params)
    if @zone.save
      redirect_to @zone, :notice => "#{@zone.name} has been created successfully"
    else
      render 'new'
    end
  end

  def update
    if @zone.update(safe_params)
      redirect_to @zone, :notice => "#{@zone.name} has been updated successfully"
    else
      render 'edit'
    end
  end

  def destroy
    @zone.destroy
    redirect_to root_path, :notice => "#{@zone.name} has been removed successfully"
  end

  def publish
    if request.post?
      publisher = Bound::Publisher.new
      if zones = publisher.publish
        redirect_to_with_return_to root_path, :notice => "Changed have been applied for #{zones.size} zone(s)"
      else
        redirect_to_with_return_to root_path, :alert => "There are no changes to apply."
      end
    else
      @zones = Zone.stale
    end
  end

  private

  def safe_params
    params.require(:zone).permit(:name, :primary_ns, :email_address, :refresh_time, :retry_time, :expiration_time, :max_cache, :ttl)
  end

end
