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
    create_screenshot(@infringement)
    redirect_to case_path(@case)
  end

  private

  def infringement_params
    params.require(:infringement).permit(:name, :url, :description)
  end

  def create_screenshot(infringement)
    screenshot = Snapshot.new
    screenshot.time = Time.now
    screenshot.infringement_id = infringement.id

    screenshot_url = prepare_url2png(infringement.url)
    process_screenshot(screenshot_url)

    open('temporary.png') do |file|
      screenshot.image_path = file
    end

    screenshot.save!
  end

  def prepare_url2png(url)
    options = {
      url: url,
      #fullpage: true,
      thumbnail_max_width: 400,
      viewport: "1480x1480",
      unique: Time.now.to_i / 60
    }

    return ScreenshotTaker.new(options).url
  end

  def process_screenshot(screenshot_url)
    open('temporary.png', 'wb') do |file|
      file << open(screenshot_url).read
      image = MiniMagick::Image.open(file)
      image.combine_options do |param|
        param.fill "white"
        param.draw "rectangle 5,5,390,21"
        param.fill "black"
        param.draw "text 8,17 'Generated by Cerberus at: #{DateTime.now}'"
      end
      image.write('temporary.png')
    end
  end
end
