class Case < ApplicationRecord
  belongs_to :user
  belongs_to :client
  has_many :infringements
  accepts_nested_attributes_for :client
end
