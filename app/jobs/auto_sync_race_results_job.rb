class AutoSyncRaceResultsJob < ApplicationJob
  queue_as :default

  def perform
    races_needing_sync.each do |race|
      Rails.logger.info "[AutoSync] Syncing results for #{race.display_name}"
      begin
        F1SyncService.new.sync_results(race.season.year, race.round)
        race.update!(last_results_sync_at: Time.current)
        Rails.logger.info "[AutoSync] Successfully synced #{race.display_name}"
      rescue => e
        Rails.logger.error "[AutoSync] Failed to sync #{race.display_name}: #{e.message}"
      end
    end
  end

  private

  def races_needing_sync
    Race.joins(:season)
        .where(seasons: { year: Time.current.year })
        .where("race_date <= ?", Time.current)
        .where("race_date >= ?", 10.hours.ago)
        .where(results_finalized: false)
        .order(:race_date)
  end
end
