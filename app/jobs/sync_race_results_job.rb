class SyncRaceResultsJob < ApplicationJob
  queue_as :default

  def perform(year, round)
    F1SyncService.new.sync_results(year, round)
  end
end
