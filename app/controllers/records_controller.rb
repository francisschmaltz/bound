class RecordsController < ApplicationController

  before_action { @zone = Zone.find(params[:zone_id]) }
  before_action { params[:id] && @record = @zone.records.find(params[:id]) }
  before_action { @active_nav = :zones }

  def index
    redirect_to @zone
  end

  def show
    redirect_to edit_zone_record_path(@zone, @record)
  end

  def new
    @record = @zone.records.build
  end

  def create
    @record = @zone.records.build(safe_params)
    @record.form_data = params.dig(:record, :form_data)&.to_hash
    if @record.save
      redirect_to zone_path(@zone), :notice => "Record has been added successfully"
    else
      render 'new'
    end
  end

  def update
    @record.form_data = params.dig(:record, :form_data)&.to_hash
    if @record.update(safe_params)
      redirect_to zone_path(@zone), :notice => "Record has been updated successfully"
    else
      render 'edit'
    end
  end

  def destroy
    @record.destroy
    redirect_to zone_path(@zone), :notice => "Record has been removed successfully"
  end

  private

  def safe_params
    params.require(:record).permit(:type, :name, :ttl)
  end

end
