class Snapshot < ApplicationRecord
  belongs_to :infringement

  mount_uploader :image_path, PhotoUploader
end
