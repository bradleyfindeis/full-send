class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @predictions_by_race = @user.predictions
      .includes(:driver, race: :season)
      .where(races: { race_date: ..Time.current })
      .group_by(&:race)
      .sort_by { |race, _| -race.round }

    @season_predictions = @user.season_predictions.includes(:drivers_champion, :constructors_champion)
    @user_rank = User.where("total_points > ?", @user.total_points).count + 1
  end
end
