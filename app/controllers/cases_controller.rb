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

    @number_of_records = 0
    @case.infringements.each { |infringement| @number_of_records += infringement.snapshots.count }

    @active_pages = 0
    @case.infringements.each do |infringement|
      if !infringement.event.nil? && infringement.event.frequency.positive?
        @active_pages += 1
      end
    end


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

  def edit
    @case = Case.new(case_params)
  end

  def update
    @case = Case.find(params[:id])
    @case.update(case_params)
    @case.save
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
