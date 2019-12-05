class CasesController < ApplicationController

  def index
    # If admin -> can see all cases, if normal user -> can see their own cases
    if current_user.admin
      @cases = Case.all
    else
      @cases = Case.where(user_id: current_user.id)
    end

    # make this the most recent snapshots
    @snapshots = Snapshot.all.last(4).reverse
    # [-4..-1]

    @case = Case.new
    @client = Client.new

    #Infringement counter in dashboard
    @events = Event.all

    #Credits counter in dashboard
    @my_cases = Case.where(user_id: current_user.id)
    @my_snapshots = Snapshot.all

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
