class F1ApiClient
  include HTTParty
  base_uri "https://api.jolpi.ca/ergast/f1"

  class ApiError < StandardError; end

  def self.current_season
    response = get("/current.json")
    handle_response(response)
  end

  def self.season(year)
    response = get("/#{year}.json")
    handle_response(response)
  end

  def self.drivers(year = "current")
    response = get("/#{year}/drivers.json?limit=100")
    handle_response(response)
  end

  def self.constructors(year = "current")
    response = get("/#{year}/constructors.json")
    handle_response(response)
  end

  def self.races(year = "current")
    response = get("/#{year}.json")
    handle_response(response)
  end

  def self.qualifying_results(year, round)
    response = get("/#{year}/#{round}/qualifying.json")
    handle_response(response)
  end

  def self.race_results(year, round)
    response = get("/#{year}/#{round}/results.json")
    handle_response(response)
  end

  def self.sprint_results(year, round)
    response = get("/#{year}/#{round}/sprint.json")
    handle_response(response)
  end

  def self.driver_standings(year = "current")
    response = get("/#{year}/driverStandings.json")
    handle_response(response)
  end

  def self.constructor_standings(year = "current")
    response = get("/#{year}/constructorStandings.json")
    handle_response(response)
  end

  private

  def self.handle_response(response)
    if response.success?
      response.parsed_response
    else
      raise ApiError, "API request failed: #{response.code} - #{response.message}"
    end
  end
end
