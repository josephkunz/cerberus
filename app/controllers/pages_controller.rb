class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    # Removed redirect to cases so that we can show homepage while logged in
  end
end
