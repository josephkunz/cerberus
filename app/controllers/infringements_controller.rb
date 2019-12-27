require 'open-uri'
require 'mini_magick'
require 'selenium-webdriver'
require_relative '../jobs/track_job'

class InfringementsController < ApplicationController

  # List all infringements
  def index
    @infringements = Infringement.all
  end

  # Show one infringement content
  def show
    @case = Case.find(params[:case_id])
    @infringement = @case.infringements.where(id: params[:id]).first
    @snapshot = @infringement.snapshots.where(id: params[:snapshot_id]).first
    @tracked_for = tracked_for(@infringement.created_at)

    @timer_values = get_timer_values

    if @infringement.event.frequency.positive?
      @state = true
    else
      @state = false
    end
  end

  # Process creation of a new infringement
  def create
    @infringement = Infringement.new(infringement_params)
    @case = Case.find(params[:case_id])
    @infringement.case = @case
    @infringement.save
    create_event(@infringement)
    redirect_to case_path(@case)
  end

  # Process deletion of specific infringement
  def destroy
    infringement = Infringement.find(params[:id])
    infringement.destroy
    redirect_to case_path(params[:case_id])
  end

  # Process three events on the infr page:
  # 1. Change of interval (user changes interval in combo box
  # 2. Change of start or stop (user presses start/stop button),
  # 3. Download one snapshot immediatelly (user presses take snapshot button)
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

  # Refresh page contents without reloading it
  def refresh
    @infringement = Infringement.find(params[:id])
    @tracked_for = tracked_for(@infringement.created_at)
    @number_of_snapshots = params[:snapshots].to_i
  end

  # Create url to download selected snapshots from cloudinary and download this zip
  # file
  def create_zip
    @case = Case.find(params[:case_id])
    @infringement = Infringement.find(params[:id])
    filename = "INFR #{@infringement.name} #{Time.now.to_s}.zip"

    prepare_array_of_public_ids(@infringement, params[:files])

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

  # Send prepared zip file with selected snapshots from cloudinary
  def send_zip
    @infringement = Infringement.find(params[:id])
    filename = "INFR #{@infringement.name} #{Time.now.to_s}.zip"
    File.rename('test.zip', filename)
    send_file filename
  end

  # Process deletion of selected snapshots on infringement page
  def delete_snapshots
    @infringement = Infringement.find(params[:id])
    @tracked_for = tracked_for(@infringement.created_at)
    process_delete(@infringement, params[:files])
  end

  private

  def infringement_params
    params.require(:infringement).permit(:name, :url, :description, :interval)
  end

  # Create new row in Events table for specific infringement, which is used by
  # clockwork scheduler to regularly run snapshot creation
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

  # Computes frequency in seconds from the value chosen by user (values are strings
  # like "1 minute", "6 months" etc.)
  def compute_frequency(interval_string)
    if interval_string == "1 snapshot"
      return 0
    end

    interval_array = interval_string.split(" ")
    case interval_array[1]
    when "second", "seconds"
      return interval_array[0].to_i
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

  # Interval values, user can choose from
  def get_timer_values
    return ["30 seconds", "1 minute", "1 hour", "6 hours", "12 hours", "1 day",
            "7 days", "14 days", "1 month", "6 months", "1 year"]
  end

  # Download and save zip file from cloudinary using given url
  def process_export(url)
    open('test.zip', 'wb') do |file|
      file << open(url).read
    end
  end

  # Prepare array of identifiers of files we want to download in zip from cloudinary
  # params_string contains db ids of snapshots in string, separated by "_"
  def prepare_array_of_public_ids(infringement, params_string)
    snapshots_ids = params_string.split("_")
    public_ids = []

    snapshots_ids.each do |id|
      path = infringement.snapshots[id.to_i].image_path.to_s
      public_ids << path.split("/").last.split(".").first
    end

    return public_ids
  end

  # Delete all snapshots contained in params_string
  # params_string contains db ids of snapshots in string, separated by "_"
  def process_delete(infringement, params_string)
    if params_string.nil?
      infringement.snapshots.each do |snapshot|
        snapshot.destroy
      end
    else
      snapshots_ids = params_string.split("_")
      snapshots_ids.each do |id|
        infringement.snapshots[id.to_i].destroy
      end
    end
  end

  # Prepare "tracked for" string, which is showed on the infr page - this string
  # shows how much time is the infr tracked for in human form (e.g. "1m 2w 5d 23:12")
  def tracked_for(start_time)
    tracked = TimeDifference.between(start_time, Time.now).in_general
    tracked_str = ""
    tracked_str += "#{tracked[:years]}y " if tracked[:years].positive?
    tracked_str += "#{tracked[:months]}m " if tracked[:months].positive?
    tracked_str += "#{tracked[:weeks]}w " if tracked[:weeks].positive?
    tracked_str += "#{tracked[:days]}d " if tracked[:days].positive?

    if tracked[:hours].positive?
      #hours = tracked[:hours].to_s.rjust(2, '0')
      tracked_str += "#{tracked[:hours].to_s.rjust(2, '0')}:"
    else
      tracked_str += "00:"
    end

    if tracked[:minutes].positive?
      #minutes = tracked[:minutes].to_s.rjust(2, '0')
      tracked_str += "#{tracked[:minutes].to_s.rjust(2, '0')}"
    else
      tracked_str += "00"
    end

    return tracked_str
  end
end
