class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :predictions, dependent: :destroy
  has_many :season_predictions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true

  scope :participants, -> { where(admin: false) }

  def admin?
    admin
  end

  def participant?
    !admin?
  end

  def recalculate_total_points!
    total = predictions.sum(:points_earned) + season_predictions.sum(:points_earned)
    update!(total_points: total)
  end
end
