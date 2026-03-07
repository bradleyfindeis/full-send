class Team < ApplicationRecord
  has_many :drivers, dependent: :nullify

  validates :external_id, presence: true, uniqueness: true
  validates :name, presence: true

  def badge_style
    "background-color: #{color || '#333'};"
  end
end
