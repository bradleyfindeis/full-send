class ResultsController < ApplicationController
  def index
    @season = Season.current
    @completed_races = Race.includes(race_results: { driver: :team })
                           .where(season: @season)
                           .joins(:race_results)
                           .distinct
                           .order(round: :desc)
    
    @driver_standings = fetch_driver_standings
    @constructor_standings = fetch_constructor_standings
  end

  def show
    @race = Race.includes(race_results: { driver: :team }).find(params[:id])
    @qualifying_results = @race.race_results.for_session("qualifying").ordered.includes(driver: :team)
    @race_results = @race.race_results.for_session("race").ordered.includes(driver: :team)
    @sprint_results = @race.race_results.for_session("sprint").ordered.includes(driver: :team) if @race.has_sprint?
  end

  private

  def fetch_driver_standings
    data = F1ApiClient.driver_standings(Time.current.year)
    data.dig("MRData", "StandingsTable", "StandingsLists", 0, "DriverStandings") || []
  rescue => e
    Rails.logger.error "Failed to fetch driver standings: #{e.message}"
    []
  end

  def fetch_constructor_standings
    data = F1ApiClient.constructor_standings(Time.current.year)
    data.dig("MRData", "StandingsTable", "StandingsLists", 0, "ConstructorStandings") || []
  rescue => e
    Rails.logger.error "Failed to fetch constructor standings: #{e.message}"
    []
  end
end
