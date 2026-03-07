class SeasonPredictionsController < ApplicationController
  def show
    @season = Season.current_season
    @prediction = current_user.season_predictions.find_by(season: @season)

    if @prediction.nil?
      redirect_to new_season_prediction_path
    end
  end

  def new
    @season = Season.current_season
    @prediction = current_user.season_predictions.find_or_initialize_by(season: @season)
    @drivers = Driver.active.ordered
    @teams = Team.order(:name)

    if @prediction.locked?
      redirect_to season_prediction_path, notice: "Your season predictions are already locked."
    end
  end

  def create
    @season = Season.current_season
    @prediction = current_user.season_predictions.find_or_initialize_by(season: @season)

    if @prediction.locked?
      redirect_to season_prediction_path, alert: "Your season predictions are already locked."
      return
    end

    @prediction.assign_attributes(season_prediction_params)

    if @prediction.save
      redirect_to season_prediction_path, notice: "Season predictions saved! They will lock when you make your first race prediction."
    else
      @drivers = Driver.active.ordered
      @teams = Team.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def season_prediction_params
    params.require(:season_prediction).permit(:drivers_champion_id, :constructors_champion_id)
  end
end
