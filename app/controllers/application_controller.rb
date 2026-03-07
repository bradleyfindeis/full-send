class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_onboarding

  private

  def require_onboarding
    return unless authenticated?
    return if current_user.onboarding_completed?
    return if controller_name.in?(%w[onboarding sessions registrations passwords])

    redirect_to onboarding_path
  end
end
