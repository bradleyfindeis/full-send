module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    private

    def require_admin
      unless current_user&.admin?
        redirect_to root_path, alert: "You don't have permission to access that page."
      end
    end
  end
end
