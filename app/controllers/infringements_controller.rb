class InfringementsController < ApplicationController
  def index
    @infringements = Infringement.all
  end

  def create
    @infringement = Infringement.new(infringement_params)

    @infringement.case = @infringement

    @infringement.save
    # TO-DO! redirect_to infringement page
  end

  private

  def infringement_params
    params.require(:infringement).permit(:id, :name, :url, :description)
  end
end
