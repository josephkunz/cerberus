class CasesController < ApplicationController
  def index
    @cases = Case.all
  end

  def show
    @case = Case.find(params[:id])
    @user = User.find(@case.user_id)
  end

  def new
  end

  def create
  end
end
