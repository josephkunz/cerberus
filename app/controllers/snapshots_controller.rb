class SnapshotsController < ApplicationController

  def show
    @snapshot = Snapshot.find(params[:id])
    @infringement = @snapshot.infringement
  end

end
