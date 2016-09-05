class APITokensController < ApplicationController

  before_action { @active_nav = :tokens }

  def index
    @api_tokens = APIToken.order(:name).to_a
  end

  def new
    @api_token = APIToken.new
  end

  def create
    @api_token = APIToken.new(params.require(:api_token).permit(:name))
    if @api_token.save
      redirect_to api_tokens_path, :notice => "#{@api_token.name} has been created successfully. The token is #{@api_token.token}"
    else
      render 'new'
    end
  end

  def destroy
    @api_token = APIToken.find(params[:id])
    if @api_token.destroy
      redirect_to api_tokens_path, :notice => "#{@api_token.name} has been revoked successfully"
    else
      redirect_to api_tokens_path, :alert => @api_token.errors.full_messages.to_sentence
    end
  end

end
