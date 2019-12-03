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

    @timer_values = get_timer_values

    if @infringement.event.frequency.positive?
      @state = true
    else
      @state = false
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
    if params[:interval] && params[:state].nil?
      process_select_interval(@infringement, params[:interval])
    elsif params[:state]
      @state = process_start_stop_button(@infringement, params[:state], params[:interval])
    elsif params[:snapshot]
      process_snapshot_button(@infringement)
    end
  end

  def refresh
    @infringement = Infringement.find(params[:id])
    @number_of_snapshots = params[:snapshots].to_i
  end

  def create_zip
    @case = Case.find(params[:case_id])
    @infringement = Infringement.find(params[:id])
    filename = "INFR #{@infringement.name} #{Time.now.to_s}.zip"

    p prepare_array_of_public_ids(@infringement, params[:files])

    if params[:files].empty?
      url = Cloudinary::Utils.download_zip_url(tags: ["INFR_#{@infringement.name}_#{@infringement.id}"],
                                               use_original_filename: true)
    else
      url = Cloudinary::Utils.download_zip_url(public_ids: prepare_array_of_public_ids(@infringement, params[:files]),
                                               use_original_filename: true)
    end
    @path_to_file = "/cases/#{params[:case_id]}/infringements/#{params[:id]}/sendzip"
    process_export(url)
  end

  def send_zip
    @infringement = Infringement.find(params[:id])
    filename = "INFR #{@infringement.name} #{Time.now.to_s}.zip"
    File.rename('test.zip', filename)
    send_file filename
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
  def process_start_stop_button(infringement, state, interval)
    if state == "Start"
      infringement.interval = interval
      infringement.save
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

  def get_timer_values
    return ["1 minute", "2 minutes", "10 minutes", "20 minutes", "30 minutes", "1 hour",
             "2 hours", "3 hours", "4 hours", "5 hours", "6 hours", "7 hours",
             "8 hours", "9 hours", "10 hours", "11 hours", "12 hours", "1 day",
             "2 days", "3 days", "4 days", "5 days", "6 days", "7 days", "8 days",
             "9 days", "10 days", "11 days", "12 days", "13 days", "14 days",
             "15 days", "1 month", "2 months", "3 months", "4 months",
             "5 months", "6 months", "1 year"]
  end

  def process_export(url)
    open('test.zip', 'wb') do |file|
      file << open(url).read
    end
  end

  def prepare_array_of_public_ids(infringement, params_string)
    snapshots_ids = params_string.split("_")
    public_ids = []

    snapshots_ids.each do |id|
      path = infringement.snapshots[id.to_i].image_path.to_s
      public_ids << path.split("/").last.split(".").first
    end

    return public_ids
  end
end
