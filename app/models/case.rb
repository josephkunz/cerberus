class Case < ApplicationRecord
  belongs_to :user
  belongs_to :client
  has_many :infringements, dependent: :destroy
  has_many :events, through: :infringements
  has_many :snapshots, through: :infringements
  accepts_nested_attributes_for :client
end
