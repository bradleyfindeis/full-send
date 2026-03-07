class Season < ApplicationRecord
  has_many :races, dependent: :destroy
  has_many :season_predictions, dependent: :destroy

  validates :year, presence: true, uniqueness: true

  scope :current, -> { find_by(current: true) }

  def self.current_season
    find_by(current: true) || order(year: :desc).first
  end
end
