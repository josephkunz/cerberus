class CasesController < ApplicationController
  def index
    @cases = Case.all
    @case = Case.new
    @client = Client.new
  end

  def show
    @case = Case.find(params[:id])
    @user = User.find(@case.user_id)
    @infringement = Infringement.new
    # @infringement = Infringement.find(@case.infringements)
  end

  def create
    @case = Case.new(case_params)
    @client = Client.new(client_params)
    @client.save!
    @case.user = current_user
    @case.client = @client
    @case.save!
    redirect_to case_path(@case)
  end

  def destroy
    @case = Case.find(params[:id])
    @case.destroy
    redirect_to cases_path
  end

  private

  def case_params
    params.require(:case).permit(:id, :name, :number, :description)
  end

  def client_params
    params.require(:case).require(:clients).permit(:first_name, :last_name)
  end
end
