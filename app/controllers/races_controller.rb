class RacesController < ApplicationController
  def index
    @season = Season.current_season
    @races = @season&.races&.includes(:predictions)&.ordered || []
    @user_predictions_by_race = current_user.predictions.where(race_id: @races.pluck(:id)).group(:race_id).count
  end

  def show
    @race = Race.find(params[:id])
    @user_predictions = @race.predictions.where(user: current_user).includes(:driver)
    @results = @race.race_results.includes(:driver).order(:session_type, :position)
  end
end
