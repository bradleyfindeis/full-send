class PredictionsController < ApplicationController
  before_action :set_race
  before_action :set_drivers

  def new
    @existing_predictions = @race.predictions.where(user: current_user).index_by { |p| "#{p.session_type}_#{p.prediction_type}_#{p.position}" }
  end

  def create
    ActiveRecord::Base.transaction do
      save_session_predictions("qualifying") unless @race.quali_locked?
      save_session_predictions("race") unless @race.race_locked?
      save_session_predictions("sprint") if @race.has_sprint? && !@race.sprint_locked?
      save_fastest_lap_prediction unless @race.race_locked?
    end

    lock_season_prediction_if_needed

    redirect_to race_path(@race), notice: "Predictions saved successfully!"
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Error saving predictions: #{e.message}"
    @existing_predictions = @race.predictions.where(user: current_user).index_by { |p| "#{p.session_type}_#{p.prediction_type}_#{p.position}" }
    render :new, status: :unprocessable_entity
  end

  def edit
    @existing_predictions = @race.predictions.where(user: current_user).index_by { |p| "#{p.session_type}_#{p.prediction_type}_#{p.position}" }
    render :new
  end

  def update
    create
  end

  private

  def set_race
    @race = Race.find(params[:race_id])
  end

  def set_drivers
    @drivers = Driver.active.ordered
  end

  def save_session_predictions(session_type)
    (1..3).each do |position|
      driver_id = params.dig(:predictions, session_type, "p#{position}")
      next if driver_id.blank?

      prediction = @race.predictions.find_or_initialize_by(
        user: current_user,
        session_type: session_type,
        prediction_type: "position",
        position: position
      )
      prediction.driver_id = driver_id
      prediction.save!
    end
  end

  def save_fastest_lap_prediction
    driver_id = params.dig(:predictions, :fastest_lap)
    return if driver_id.blank?

    prediction = @race.predictions.find_or_initialize_by(
      user: current_user,
      session_type: "race",
      prediction_type: "fastest_lap"
    )
    prediction.driver_id = driver_id
    prediction.position = nil
    prediction.save!
  end

  def lock_season_prediction_if_needed
    season_prediction = current_user.season_predictions.find_by(season: @race.season)
    return unless season_prediction&.complete? && !season_prediction.locked?

    season_prediction.lock!
  end
end
