class SeasonPrediction < ApplicationRecord
  belongs_to :user
  belongs_to :season
  belongs_to :drivers_champion, class_name: "Driver", optional: true
  belongs_to :constructors_champion, class_name: "Team", optional: true

  validates :user_id, uniqueness: { scope: :season_id }

  DRIVERS_CHAMPION_POINTS = 50
  CONSTRUCTORS_CHAMPION_POINTS = 50

  def locked?
    locked_at.present?
  end

  def lock!
    update!(locked_at: Time.current) unless locked?
  end

  def complete?
    drivers_champion_id.present? && constructors_champion_id.present?
  end
end
