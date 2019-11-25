class Infringement < ApplicationRecord
  belongs_to :case
  has_many :snapshots
end
