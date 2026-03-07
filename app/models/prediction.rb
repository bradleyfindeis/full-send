class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :race
  belongs_to :driver

  validates :session_type, presence: true, inclusion: { in: Race::SESSION_TYPES }
  validates :prediction_type, presence: true, inclusion: { in: %w[position fastest_lap podium_sweep] }
  validates :position, presence: true, if: -> { prediction_type == "position" }

  scope :for_session, ->(session_type) { where(session_type: session_type) }
  scope :positions, -> { where(prediction_type: "position") }
  scope :fastest_lap, -> { where(prediction_type: "fastest_lap") }
  scope :scored, -> { where("points_earned > 0") }

  POINTS = {
    qualifying: { 1 => 10, 2 => 8, 3 => 6 },
    race: { 1 => 15, 2 => 10, 3 => 8 },
    sprint: { 1 => 10, 2 => 7, 3 => 5 },
    fastest_lap: 5,
    podium_sweep: 10
  }.freeze

  def locked?
    race.session_locked?(session_type)
  end

  def calculate_points!
    return unless locked?

    result = race.race_results.find_by(
      session_type: session_type,
      position: position,
      driver: driver
    )

    if prediction_type == "fastest_lap"
      fl_result = race.race_results.find_by(session_type: "race", fastest_lap: true, driver: driver)
      self.points_earned = fl_result ? POINTS[:fastest_lap] : 0
    elsif result
      self.points_earned = POINTS[session_type.to_sym][position] || 0
    else
      self.points_earned = 0
    end

    save!
  end
end
