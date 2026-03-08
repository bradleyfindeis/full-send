class Race < ApplicationRecord
  belongs_to :season
  has_many :race_results, dependent: :destroy
  has_many :predictions, dependent: :destroy

  validates :external_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :round, presence: true, uniqueness: { scope: :season_id }

  scope :upcoming, -> { where("race_date > ?", Time.current).order(:race_date) }
  scope :past, -> { where("race_date <= ?", Time.current).order(race_date: :desc) }
  scope :ordered, -> { order(:round) }

  SESSION_TYPES = %w[qualifying race sprint].freeze

  def quali_locked?
    quali_date.present? && Time.current >= quali_date
  end

  def race_locked?
    race_date.present? && Time.current >= race_date
  end

  def sprint_locked?
    return true unless has_sprint?
    sprint_date.present? && Time.current >= sprint_date
  end

  def session_locked?(session_type)
    case session_type.to_s
    when "qualifying" then quali_locked?
    when "race" then race_locked?
    when "sprint" then sprint_locked?
    else true
    end
  end

  def next_session
    return nil if cancelled?

    now = Time.current
    if quali_date && now < quali_date
      { type: "qualifying", date: quali_date }
    elsif has_sprint? && sprint_date && now < sprint_date
      { type: "sprint", date: sprint_date }
    elsif race_date && now < race_date
      { type: "race", date: race_date }
    end
  end

  def status
    return :cancelled if cancelled?
    return :completed if race_date && Time.current > race_date
    return :in_progress if quali_date && Time.current >= quali_date
    :upcoming
  end

  def display_name
    "Round #{round}: #{name}"
  end

  def results_ready_for_slack?
    return false if slack_posted_at.present?
    return false unless race_date && race_date <= 24.hours.ago
    race_results.where(session_type: "race").any?
  end

  def needs_results_sync?
    return false if results_finalized?
    return false unless race_date && race_date <= Time.current
    race_date >= 10.hours.ago
  end

  def has_race_results?
    race_results.where(session_type: "race").any?
  end

  def finalize_results!
    update!(results_finalized: true)
  end
end
