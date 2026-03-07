class InviteCode < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validate :code_format

  before_validation :normalize_code
  before_validation :generate_code, on: :create, if: -> { code.blank? }

  scope :valid, -> { where("(expires_at IS NULL OR expires_at > ?) AND uses_count < max_uses", Time.current) }

  def valid_for_use?
    (expires_at.nil? || expires_at > Time.current) && uses_count < max_uses
  end

  def use!
    increment!(:uses_count)
  end

  private

  def normalize_code
    self.code = code&.strip&.upcase
  end

  def generate_code
    self.code = SecureRandom.alphanumeric(8).upcase
  end

  def code_format
    return if code.blank?
    unless code.match?(/\A[A-Z0-9]+\z/)
      errors.add(:code, "can only contain letters and numbers")
    end
  end
end
