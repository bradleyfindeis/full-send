class ScoreCalculator
  POINTS = {
    qualifying: { 1 => 10, 2 => 8, 3 => 6 },
    race: { 1 => 15, 2 => 10, 3 => 8 },
    sprint: { 1 => 10, 2 => 7, 3 => 5 },
    fastest_lap: 5,
    podium_sweep: 10
  }.freeze

  def initialize(race)
    @race = race
  end

  def calculate_all!
    return unless @race.race_results.any?

    User.find_each do |user|
      calculate_for_user(user)
    end
  end

  def calculate_for_user(user)
    predictions = @race.predictions.where(user: user)
    return if predictions.empty?

    total_points = 0
    podium_correct = { qualifying: 0, race: 0, sprint: 0 }

    predictions.each do |prediction|
      points = calculate_prediction_points(prediction)
      prediction.update!(points_earned: points)
      total_points += points

      if prediction.prediction_type == "position" && prediction.position.in?(1..3)
        podium_correct[prediction.session_type.to_sym] += 1 if points > 0
      end
    end

    podium_correct.each do |session_type, count|
      if count == 3
        bonus = Prediction.find_or_create_by!(
          user: user,
          race: @race,
          session_type: session_type,
          prediction_type: "podium_sweep",
          driver: Driver.first
        )
        bonus.update!(points_earned: POINTS[:podium_sweep])
      end
    end

    user.recalculate_total_points!
  end

  private

  def calculate_prediction_points(prediction)
    case prediction.prediction_type
    when "position"
      calculate_position_points(prediction)
    when "fastest_lap"
      calculate_fastest_lap_points(prediction)
    else
      0
    end
  end

  def calculate_position_points(prediction)
    result = @race.race_results.find_by(
      session_type: prediction.session_type,
      position: prediction.position,
      driver: prediction.driver
    )

    return 0 unless result

    session_points = POINTS[prediction.session_type.to_sym]
    session_points[prediction.position] || 0
  end

  def calculate_fastest_lap_points(prediction)
    result = @race.race_results.find_by(
      session_type: "race",
      fastest_lap: true,
      driver: prediction.driver
    )

    result ? POINTS[:fastest_lap] : 0
  end
end
