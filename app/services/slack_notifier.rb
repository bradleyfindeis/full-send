class SlackNotifier
  class << self
    def post_race_results(race)
      return unless enabled?

      message = RaceResultsFormatter.new(race).format
      post(message)
    end

    def post(message)
      return unless enabled?
      return if webhook_url.blank?

      notifier.post(text: message)
    end

    def enabled?
      Rails.application.config.slack.enabled && webhook_url.present?
    end

    private

    def notifier
      @notifier ||= Slack::Notifier.new(webhook_url) do
        defaults channel: Rails.application.config.slack.channel,
                 username: Rails.application.config.slack.username
      end
    end

    def webhook_url
      Rails.application.config.slack.webhook_url
    end
  end

  class RaceResultsFormatter
    def initialize(race)
      @race = race
      @season = race.season
    end

    def format
      [
        header,
        race_results_section,
        prediction_results_section,
        season_standings_section
      ].join("\n\n")
    end

    private

    def header
      ":checkered_flag: *#{@race.display_name}* Results :checkered_flag:"
    end

    def race_results_section
      results = @race.race_results.where(session_type: "race").order(:position).limit(3)
      return "" if results.empty?

      lines = ["*Race Podium:*"]
      results.each do |result|
        emoji = position_emoji(result.position)
        lines << "#{emoji} #{result.driver.name}"
      end

      fastest_lap = @race.race_results.find_by(session_type: "race", fastest_lap: true)
      lines << ":stopwatch: Fastest Lap: #{fastest_lap.driver.name}" if fastest_lap

      lines.join("\n")
    end

    def prediction_results_section
      user_points = calculate_user_points_for_race
      return "" if user_points.empty?

      lines = ["*This Week's Prediction Scores:*"]
      sorted = user_points.sort_by { |_, points| -points }

      sorted.each_with_index do |(user, points), index|
        prefix = index == 0 ? ":trophy: " : ""
        lines << "#{prefix}#{user.name}: #{points} pts"
      end

      lines.join("\n")
    end

    def season_standings_section
      users = User.order(total_points: :desc).limit(10)
      return "" if users.empty?

      lines = ["*Season Standings:*"]
      users.each_with_index do |user, index|
        position = index + 1
        emoji = position_emoji(position)
        lines << "#{emoji} #{user.name}: #{user.total_points} pts"
      end

      lines.join("\n")
    end

    def calculate_user_points_for_race
      User.all.each_with_object({}) do |user, hash|
        points = @race.predictions.where(user: user).sum(:points_earned)
        hash[user] = points if points > 0
      end
    end

    def position_emoji(position)
      case position
      when 1 then ":first_place_medal:"
      when 2 then ":second_place_medal:"
      when 3 then ":third_place_medal:"
      else "#{position}."
      end
    end
  end
end
