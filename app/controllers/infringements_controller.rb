class InfringementsController < ApplicationController
  def index
    @infringements = Infringement.all
  end

  def show
    @infringement = Infringement.find(params[:id])
  end

  def create
    @infringement = Infringement.new(infringement_params)
    @case = Case.find(params[:case_id])
    @infringement.case = @case
    @infringement.save
    redirect_to case_path(@case)
  end

  private

  def infringement_params
    params.require(:infringement).permit(:id, :name, :url, :description)
  end
end
