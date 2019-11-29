require 'open-uri'
require 'mini_magick'

class InfringementsController < ApplicationController
  def index
    @infringements = Infringement.all
  end

  def show
    @case = Case.find(params[:case_id])
    @infringement = @case.infringements.where(id: params[:id]).first
    @snapshot = @infringement.snapshots.where(id: params[:snapshot_id]).first
    filename = "INFR #{@infringement.name} #{Time.now.to_s}.zip"
    @url = Cloudinary::Utils.download_zip_url(tags: ['INFR', @infringement.name, @infringement.id],
                                              use_original_filename: true,
                                              target_public_id: filename)
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
    frequency = compute_frequency(infringement.interval)
    event = Event.new(name: infringement.url,
                      frequency: frequency,
                      job_name: "TrackJob",
                      job_arguments: infringement.id,
                      infringement_id: infringement.id)
    event.save
  end

  def compute_frequency(interval_string)
    if interval_string == "1 snapshot"
      return 0
    end

    interval_array = interval_string.split(" ")
    case interval_array[1]
    when "minute", "minutes"
      return interval_array[0].to_i * 60
    when "hour", "hours"
      return interval_array[0].to_i * 60 * 60
    when "day", "days"
      return interval_array[0].to_i * 60 * 60 * 24
    when "month", "months"
      return interval_array[0].to_i * 60 * 60 * 24 * 30
    when "year", "years"
      return interval_array[0].to_i * 60 * 60 * 24 * 365
    end
  end
end
