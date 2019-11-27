class Infringement < ApplicationRecord
  belongs_to :case
  has_many :snapshots, dependent: :destroy
  has_one :event, dependent: :destroy
end
