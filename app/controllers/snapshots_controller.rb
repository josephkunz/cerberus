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
    base_url = infringement.url
    if base_url.include?("https")
      base_url_nohttp = base_url.gsub("https://", "")
      url_array = base_url_nohttp.split("/")
    elsif base_url.include?("http")
      base_url_nohttp = base_url.gsub("http://", "")
      url_array = base_url_nohttp.split("/")
    else
      url_array = base_url.split("/")
    end

    if url_array.count > 1
      return url_array[0] + "/..."
    else
      return url_array[0]
    end
  end

end
