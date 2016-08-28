class ZonesController < ApplicationController

  before_action { params[:id] && @zone = Zone.find(params[:id]) }

  def index
    @zones = Zone.order(:name)
  end

  def show
    @records = @zone.records.order(:name, :type).to_a
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

  private

  def safe_params
    params.require(:zone).permit(:name, :primary_ns, :email_address, :refresh_time, :retry_time, :expiration_time, :max_cache, :ttl)
  end

end
