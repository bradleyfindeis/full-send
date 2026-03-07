class SyncF1DataJob < ApplicationJob
  queue_as :default

  def perform(year = Time.current.year)
    F1SyncService.new.sync_all(year)
  end
end
