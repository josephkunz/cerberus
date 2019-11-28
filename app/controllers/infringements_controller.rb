require 'open-uri'
require 'mini_magick'

class InfringementsController < ApplicationController
  def index
    @infringements = Infringement.all
  end

  def show
    @case = Case.find(params[:case_id])
    @infringement = @case.infringements.where(id: params[:id]).first
    # @infringement = Infringement.find(params[:id])
  end

  def create
    @infringement = Infringement.new(infringement_params)
    @case = Case.find(params[:case_id])
    @infringement.case = @case
    @infringement.save
    create_event(@infringement)
    redirect_to case_path(@case)
  end

  private

  def infringement_params
    params.require(:infringement).permit(:name, :url, :description, :interval)
  end

  def create_event(infringement)
    event = Event.new(name: infringement.url,
                      frequency: (infringement.interval * 60),
                      job_name: "TrackJob",
                      job_arguments: infringement.id)
    event.save
  end
end
