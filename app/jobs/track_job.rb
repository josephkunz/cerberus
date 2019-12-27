require 'selenium-webdriver'

class TrackJob < ApplicationJob
  queue_as :default

  # Performs job - donwload screenshot, modify it, save it to db and upload it to cloudinary
  def perform(params)
    # params - id of infringement
    infringement = Infringement.find(params)

    # print msg about job start to the sidekiq console
    print_start_job(infringement)

    #create screenshot
    create_screenshot(infringement)

    # print msg about job end to the sidekiq console
    print_end_job(infringement)
  end

  private

  # Following methods print various msgs to sidekiq console
  def print_start_job(infringement)
    puts ""
    puts "\e[32m I'm starting the download job on following infringement: \e[0m"
    puts "\e[32m -------------------------------------------------------- \e[0m"
    puts " Name: \e[31m#{infringement.name}\e[0m"
    puts " Url: \e[31m#{infringement.url}\e[0m"
    puts " Interval: \e[31m#{infringement.interval}\e[0m"
    puts ""
  end

  def print_end_job(infringement)
    puts ""
    puts "\e[32m ------------ \e[0m"
    puts "\e[32m Job on infr. #{infringement.name}, url: #{infringement.url} completed OK \e[0m"
    puts ""
  end

  def print_job_info(screenshot)
    puts "\e[32m Snapshot created: \e[0m"
    puts "\e[32m ----------------- \e[0m"
    puts " Id: \e[31m#{screenshot.id}\e[0m"
    puts " Time: \e[31m#{screenshot.time}\e[0m"
    puts " Url: \e[31m#{screenshot.infringement.url}\e[0m"
  end

  # Creates screenshot, infringement is the infr passed to the track job
  def create_screenshot(infringement)
    # Create new instance of snapshot model
    screenshot = Snapshot.new
    screenshot.time = Time.now
    screenshot.infringement_id = infringement.id
    filename = screenshot.time.to_s + '.jpg'

    #screenshot_url = prepare_url2png(infringement.url)
    #process_screenshot(screenshot_url, screenshot.time, filename)

    # Prepare web driver (headless firefox)
    web_driver = prepare_web_driver_firefox(infringement.url)
    # Save screenshot using headless firefox, modify image using minimagick
    process_screenshot(web_driver, screenshot.time, filename)
    web_driver.quit

    # Assign downloaded file to snapshot instance and save to db
    open(filename) do |file|
      screenshot.image_path = file
    end
    screenshot.save

    # Delete temp file
    File.delete(filename)
    print_job_info(screenshot)
  end

  # Prepare web driver using headless Chrome - not used now
  def prepare_web_driver_chrome(url)
    config = Config.all.first

    puts "Preparing options"

    options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    options.add_argument('no-sandbox')
    options.add_argument('disable-dev-shm-usage')
    options.add_argument("user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15")
    #options.add_emulation(device_metrics: {pixelRatio: 1})
    options.add_argument("window-size=#{config.window_width},#{config.window_height}");

    puts "Preparing driver"
    driver = Selenium::WebDriver.for(:chrome, options: options)
    puts "Driver navigate"
    driver.navigate.to(url)

    if config.fullpage
      puts "Fullpage = true"
      width  = driver.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
      height = driver.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
      driver.manage.window.resize_to(width, height)
    end
    puts "return driver"
    return driver
  end

  # Prepare web driver using headless Firefox, url = url of site with infringement
  def prepare_web_driver_firefox(url)
    config = Config.all.first

    # Setup options of the web driver
    options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    options.add_argument("-user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:71.0) Gecko/20100101 Firefox/71.0")
    options.add_argument("-width=#{config.window_width}");
    options.add_argument("-height=#{config.window_height}");

    # Create web driver and navigate to url
    driver = Selenium::WebDriver.for(:firefox, options: options)
    driver.navigate.to(url)

    # If fullpage screenshot is required, resize browsers window to cover whole page
    if config.fullpage
      width  = driver.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
      height = driver.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
      driver.manage.window.resize_to(width, height)
    end

    sleep(1)
    return driver
  end

  # Create screenshot and modify created image
  def process_screenshot(web_driver, time, filename)
    config = Config.all.first

    # Create screenshot
    web_driver.save_screenshot(filename)

    # Open file with MiniMagick
    image = MiniMagick::Image.open(filename)
    image.combine_options do |param|
      # Resize screenshot according to the value stored in db (screenshot_width)
      if config.screenshot_width < config.window_width
        param.resize "#{config.screenshot_width}x"
      end

      # Draw timestamp to the top left corner of the screenshot
      param.fill "white"
      param.draw "rectangle 5,5,390,21"
      param.fill "black"
      param.draw "text 8,17 'Generated by Cerberus at: #{time}'"

      # Adjust quality of jpeg according to the value stored in db (screenshot_quality)
      param.quality "#{config.screenshot_quality}"
    end

    # Save changes to the screenshot
    image.write(filename)
  end

  # def prepare_url2png(url)
  #   config = Config.all.first

  #   options = {
  #     url: url,
  #     fullpage: config.fullpage,
  #     thumbnail_max_width: config.thumbnail_width,
  #     viewport: config.viewport,
  #     unique: Time.now.to_i / 30
  #   }

  #   return ScreenshotTaker.new(options).url
  # end

  # def process_screenshot(screenshot_url, time, filename)
  #   open('temporary.png', 'wb') do |file|
  #     file << open(screenshot_url).read
  #     image = MiniMagick::Image.open(file)
  #     image.combine_options do |param|
  #       param.fill "white"
  #       param.draw "rectangle 5,5,390,21"
  #       param.fill "black"
  #       param.draw "text 8,17 'Generated by Cerberus at: #{time}'"
  #     end
  #     image.write(filename)
  #   end
  # end
end
