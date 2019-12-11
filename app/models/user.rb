class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :cases
  has_many :infringements, through: :cases
  has_many :snapshots, through: :infringements
  has_many :events, through: :infringements
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def is_admin?
    return admin
  end

end
