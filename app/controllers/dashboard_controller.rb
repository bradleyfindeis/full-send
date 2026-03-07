class DashboardController < ApplicationController
  def index
    @season = Season.current_season
    @upcoming_race = @season&.races&.upcoming&.first
    @recent_races = @season&.races&.past&.limit(3) || []
    @user_predictions = current_user.predictions.includes(:race, :driver).order(created_at: :desc).limit(5)
    @leaderboard = User.order(total_points: :desc).limit(5)
  end
end
