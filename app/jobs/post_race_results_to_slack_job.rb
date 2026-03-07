class PostRaceResultsToSlackJob < ApplicationJob
  queue_as :default

  def perform
    races_to_post.find_each do |race|
      post_results(race)
    end
  end

  private

  def races_to_post
    Race
      .joins(:season)
      .where(seasons: { current: true })
      .where(slack_posted_at: nil)
      .where("race_date <= ?", 24.hours.ago)
      .where.not(id: Race.left_outer_joins(:race_results).where(race_results: { id: nil }).select(:id))
  end

  def post_results(race)
    return unless race.race_results.where(session_type: "race").any?

    SlackNotifier.post_race_results(race)
    race.update!(slack_posted_at: Time.current)

    Rails.logger.info "[SlackNotifier] Posted results for #{race.display_name}"
  rescue => e
    Rails.logger.error "[SlackNotifier] Failed to post results for #{race.display_name}: #{e.message}"
    raise
  end
end
