class Event < ApplicationRecord
  belongs_to :infringement
  validates :name, :frequency, :job_name, :infringement_id, presence: true

  def if?(time)
    case self.frequency
    when 0
      self.frequency = -1
      self.save
      return true
    when -1
      return false
    else
      return true
    end
  end
end
