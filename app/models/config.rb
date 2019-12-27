class Config < ApplicationRecord
  validates :screenshot_width, :window_width, :window_height, :screenshot_quality, presence: true
  validates :screenshot_width, :window_width, :window_height, numericality: { only_integer: true, greater_than_or_equal_to: 100, less_than_or_equal_to: 3000 }
  validates :screenshot_quality, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100 }
end
