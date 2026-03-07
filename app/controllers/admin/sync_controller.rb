module Admin
  class SyncController < BaseController
    def create
      case params[:sync_type]
      when "all"
        SyncF1DataJob.perform_later(params[:year]&.to_i || Time.current.year)
        redirect_to admin_root_path, notice: "Full sync started for #{params[:year] || Time.current.year}"
      when "results"
        if params[:round].present?
          SyncRaceResultsJob.perform_later(params[:year].to_i, params[:round].to_i)
          redirect_to admin_root_path, notice: "Results sync started for Round #{params[:round]}"
        else
          redirect_to admin_root_path, alert: "Round number required for results sync"
        end
      else
        redirect_to admin_root_path, alert: "Unknown sync type"
      end
    end
  end
end
