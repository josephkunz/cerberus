class CasesController < ApplicationController
  def index
    @cases = Case.all
  end

  def show
    @case = Case.find(params[:id])
    @user = User.find(@case.user_id)
  end

  def new
    @case = Case.new
  end

  def create
    @case = Case.new(case_params)
    @case.save
    redirect_to case_path(@case)
  end

  private

  def case_params
    params.require(:case).permit(:id, :name, :number, :description)
  end
end
