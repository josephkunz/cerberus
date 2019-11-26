class CasesController < ApplicationController
  def index
  end

  def show
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
    params.require(:case).permit(:id, :name, :number, :description, :deleted, :archived)
  end
end
