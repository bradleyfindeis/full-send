class LeaderboardController < ApplicationController
  def index
    @season = Season.current_season
    @users = User.order(total_points: :desc)
    @current_user_rank = @users.pluck(:id).index(current_user.id)&.+ 1
  end
end
