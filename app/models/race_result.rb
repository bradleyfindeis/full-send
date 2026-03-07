class RaceResult < ApplicationRecord
  belongs_to :race
  belongs_to :driver

  validates :session_type, presence: true, inclusion: { in: Race::SESSION_TYPES }
  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :position, uniqueness: { scope: [:race_id, :session_type] }
  validates :driver_id, uniqueness: { scope: [:race_id, :session_type] }

  scope :for_session, ->(session_type) { where(session_type: session_type) }
  scope :podium, -> { where(position: 1..3) }
  scope :ordered, -> { order(:position) }

  def podium?
    position <= 3
  end
end
