class Driver < ApplicationRecord
  belongs_to :team, optional: true
  has_many :race_results, dependent: :destroy
  has_many :predictions, dependent: :destroy

  validates :external_id, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { all }
  scope :with_team, -> { where.not(team_id: nil) }
  scope :ordered, -> { order(:name) }

  def display_name
    code.present? ? "#{name} (#{code})" : name
  end

  def short_name
    code || name.split.last[0..2].upcase
  end
end
