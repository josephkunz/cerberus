class Config < ApplicationRecord
  validates :thumbnail_width, :viewport, presence: true
  validates :thumbnail_width, numericality: { only_integer: true, greater_than_or_equal_to: 100, less_than_or_equal_to: 2000 }
end
