class Infringement < ApplicationRecord
  belongs_to :case
  has_many :snapshots, dependent: :destroy
  has_one :event, dependent: :destroy

  validates :url, presence: true
  validates :name, presence: true
  validates :interval, presence: true
end
