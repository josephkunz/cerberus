class Case < ApplicationRecord
  belongs_to :user
  belongs_to :client
  has_many :infringements
end
