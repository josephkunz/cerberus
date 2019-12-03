require 'open-uri'
require 'mini_magick'
require_relative '../jobs/track_job'

class InfringementsController < ApplicationController
  def index
    @infringements = Infringement.all
  end

  def show
    @case = Case.find(params[:case_id])
    @infringement = @case.infringements.where(id: params[:id]).first
    @snapshot = @infringement.snapshots.where(id: params[:snapshot_id]).first
    filename = "INFR #{@infringement.name} #{Time.now.to_s}.zip"

    @url = Cloudinary::Utils.download_zip_url(tags: ["INFR_#{@infringement.name}_#{@infringement.id}"],
                                              use_original_filename: true,
                                              target_public_id: filename)

    @timer_values = ["1 minute", "2 minutes", "10 minutes", "20 minutes", "30 minutes", "1 hour",
                     "2 hours", "3 hours", "4 hours", "5 hours", "6 hours", "7 hours",
                     "8 hours", "9 hours", "10 hours", "11 hours", "12 hours", "1 day",
                     "2 days", "3 days", "4 days", "5 days", "6 days", "7 days", "8 days",
                     "9 days", "10 days", "11 days", "12 days", "13 days", "14 days",
                     "15 days", "1 month", "2 months", "3 months", "4 months",
                     "5 months", "6 months", "1 year"]
    if @infringement.event.frequency.positive?
      @state = true
    else
      @state = false
    end

    if !params[:snapshots].nil?
      @number_of_snapshots = params[:snapshots].to_i
    end
  end

  def create
    @infringement = Infringement.new(infringement_params)
    @case = Case.find(params[:case_id])
    @infringement.case = @case
    @infringement.save
    create_event(@infringement)
    redirect_to case_path(@case)
  end

  def destroy
    infringement = Infringement.find(params[:id])
    infringement.destroy
    redirect_to case_path(params[:case_id])
  end

  def update
    @infringement = Infringement.find(params[:id])
    if !params[:interval].nil?
      process_select_interval(@infringement, params[:interval])
    elsif !params[:state].nil?
      @state = process_start_stop_button(@infringement, params[:state])
    elsif !params[:snapshot].nil?
      process_snapshot_button(@infringement)
    end
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

  # Process select interval action - if different interval is selected in combo,
  # change is saved
  def process_select_interval(infringement, interval)
    infringement.interval = interval
    infringement.save
    if infringement.event.frequency.positive?
      infringement.event.frequency = compute_frequency(infringement.interval)
      infringement.event.save
    end
  end

  # Process start stop functionality
  def process_start_stop_button(infringement, state)
    if state == "Start"
      infringement.event.frequency = compute_frequency(infringement.interval)
    else
      infringement.event.frequency = -1
    end
    infringement.event.save
    return state
  end

  # Process snapshot button
  def process_snapshot_button(infringement)
    TrackJob.perform_later(infringement.id)
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
