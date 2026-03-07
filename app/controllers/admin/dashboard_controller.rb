module Admin
  class DashboardController < BaseController
    def index
      @users_count = User.count
      @predictions_count = Prediction.count
      @races_count = Race.count
      @drivers_count = Driver.count
      @invite_codes = InviteCode.order(created_at: :desc).limit(5)
      @recent_users = User.order(created_at: :desc).limit(5)
      @season = Season.current_season
    end
  end
end
