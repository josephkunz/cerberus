class SnapshotsController < ApplicationController

  def show
    @snapshot = Snapshot.find(params[:id])
    @infringement = @snapshot.infringement
    @number = @infringement.snapshots.find_index(@snapshot)
    @base_url = base_url(@infringement)
  end

  def next_snapshot
    @infringement = Snapshot.find(params[:id]).infringement
    @snapshot = @infringement.snapshots[params[:snapshot_id].to_i]
    @base_url = base_url(@infringement)

    @number = params[:snapshot_id].to_i

    if params[:image] == "next"
      if @snapshot == @infringement.snapshots.last
        @number = 0
      else
        @number += 1
      end
    elsif params[:image] == "previous"
      if @snapshot == @infringement.snapshots.first
        @number = @infringement.snapshots.count - 1
      else
        @number -= 1
      end
    end
    @new_snapshot = @infringement.snapshots[@number]
  end

  private

  def base_url(infringement)
    base_url = ""
    if infringement.url.include?("http")
      base_url = infringement.url.gsub("http://", "")
      base_url = infringement.url.gsub("https://", "")
    end

    url_array = base_url.split("/")

    if url_array.count > 1
      base_url = url_array[0] + "/..."
    else
      base_url = url_array[0]
    end
    return base_url
  end

end
