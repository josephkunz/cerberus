class InfringementsController < ApplicationController
  def create
    @infringement = Infringement.new(infringement_params)

    @infringement = Infringement.find(:infringement_id)
    #continue
  end

  private

  def infringement_params
    params.require(:infringement).permit(:id, :name, :url, :description, :interval, :deleted)
  end
end
