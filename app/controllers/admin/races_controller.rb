module Admin
  class RacesController < BaseController
    before_action :set_race

    def sync_results
      begin
        F1SyncService.new.sync_results(@race.season.year, @race.round)
        @race.update!(last_results_sync_at: Time.current)
        redirect_to admin_root_path, notice: "Results synced for #{@race.display_name}"
      rescue => e
        redirect_to admin_root_path, alert: "Sync failed: #{e.message}"
      end
    end

    def finalize_results
      @race.finalize_results!
      redirect_to admin_root_path, notice: "Results finalized for #{@race.display_name}"
    end

    private

    def set_race
      @race = Race.find(params[:id])
    end
  end
end
