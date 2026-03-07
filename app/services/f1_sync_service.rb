class F1SyncService
  TEAM_COLORS = {
    "red_bull" => "#3671C6",
    "ferrari" => "#E80020",
    "mercedes" => "#27F4D2",
    "mclaren" => "#FF8000",
    "aston_martin" => "#229971",
    "alpine" => "#FF87BC",
    "williams" => "#64C4FF",
    "rb" => "#6692FF",
    "sauber" => "#52E252",
    "haas" => "#B6BABD",
    "audi" => "#52E252",
    "cadillac" => "#1E3A5F"
  }.freeze

  DRIVER_TEAMS_2026 = {
    "max_verstappen" => "red_bull",
    "hadjar" => "red_bull",
    "leclerc" => "ferrari",
    "hamilton" => "ferrari",
    "russell" => "mercedes",
    "antonelli" => "mercedes",
    "norris" => "mclaren",
    "piastri" => "mclaren",
    "alonso" => "aston_martin",
    "stroll" => "aston_martin",
    "gasly" => "alpine",
    "colapinto" => "alpine",
    "albon" => "williams",
    "sainz" => "williams",
    "lawson" => "rb",
    "lindblad" => "rb",
    "hulkenberg" => "audi",
    "bortoleto" => "audi",
    "ocon" => "haas",
    "bearman" => "haas",
    "perez" => "cadillac",
    "bottas" => "cadillac"
  }.freeze

  def sync_all(year = Time.current.year)
    sync_season(year)
    sync_teams(year)
    sync_drivers(year)
    sync_races(year)
  end

  def sync_season(year)
    Season.find_or_create_by!(year: year) do |season|
      season.current = (year == Time.current.year)
    end

    Season.where.not(year: year).update_all(current: false) if year == Time.current.year
  end

  def sync_teams(year)
    data = F1ApiClient.constructors(year)
    constructors = data.dig("MRData", "ConstructorTable", "Constructors") || []

    constructors.each do |constructor|
      team = Team.find_or_initialize_by(external_id: constructor["constructorId"])
      team.name = clean_team_name(constructor["name"])
      team.color ||= TEAM_COLORS[constructor["constructorId"]]
      team.save!
    end
  end

  def sync_drivers(year)
    data = F1ApiClient.drivers(year)
    drivers = data.dig("MRData", "DriverTable", "Drivers") || []

    drivers.each do |driver_data|
      driver = Driver.find_or_initialize_by(external_id: driver_data["driverId"])
      driver.name = "#{driver_data['givenName']} #{driver_data['familyName']}"
      driver.code = driver_data["code"]
      driver.number = driver_data["permanentNumber"]&.to_i
      driver.save!
    end

    sync_driver_teams(year)
  end

  def sync_driver_teams(year)
    data = F1ApiClient.driver_standings(year)
    standings = data.dig("MRData", "StandingsTable", "StandingsLists", 0, "DriverStandings") || []

    if standings.any?
      standings.each do |standing|
        driver_id = standing.dig("Driver", "driverId")
        constructor_id = standing.dig("Constructors", 0, "constructorId")

        next unless driver_id && constructor_id

        driver = Driver.find_by(external_id: driver_id)
        team = Team.find_by(external_id: constructor_id)

        driver&.update(team: team) if team
      end
    else
      assign_driver_teams_from_mapping
    end
  end

  def assign_driver_teams_from_mapping
    DRIVER_TEAMS_2026.each do |driver_id, team_id|
      driver = Driver.find_by(external_id: driver_id)
      team = Team.find_by(external_id: team_id)

      driver&.update(team: team) if driver && team
    end
  end

  def clean_team_name(name)
    name
      .gsub(/ F1 Team$/i, "")
      .gsub(/^Stake F1 Team /, "")
      .gsub(/^MoneyGram /, "")
      .gsub(/^Visa Cash App /, "")
      .strip
  end

  def sync_races(year)
    season = Season.find_by!(year: year)
    data = F1ApiClient.races(year)
    races = data.dig("MRData", "RaceTable", "Races") || []

    races.each do |race_data|
      race = Race.find_or_initialize_by(external_id: "#{year}_#{race_data['round']}")
      race.season = season
      race.name = race_data["raceName"]
      race.round = race_data["round"].to_i
      race.circuit_name = race_data.dig("Circuit", "circuitName")
      race.circuit_country = race_data.dig("Circuit", "Location", "country")
      race.race_date = parse_datetime(race_data["date"], race_data["time"])
      race.quali_date = parse_datetime(race_data.dig("Qualifying", "date"), race_data.dig("Qualifying", "time"))
      race.sprint_date = parse_datetime(race_data.dig("Sprint", "date"), race_data.dig("Sprint", "time"))
      race.has_sprint = race_data["Sprint"].present?
      race.save!
    end
  end

  def sync_results(year, round)
    race = Race.joins(:season).find_by!(seasons: { year: year }, round: round)

    sync_qualifying_results(year, round, race)
    sync_race_results(year, round, race)
    sync_sprint_results(year, round, race) if race.has_sprint?

    ScoreCalculator.new(race).calculate_all!
  end

  def sync_qualifying_results(year, round, race)
    data = F1ApiClient.qualifying_results(year, round)
    results = data.dig("MRData", "RaceTable", "Races", 0, "QualifyingResults") || []

    return if results.empty?

    results.each do |result|
      driver = Driver.find_by(external_id: result.dig("Driver", "driverId"))
      next unless driver

      RaceResult.find_or_initialize_by(
        race: race,
        driver: driver,
        session_type: "qualifying"
      ).update!(position: result["position"].to_i)
    end
  end

  def sync_race_results(year, round, race)
    data = F1ApiClient.race_results(year, round)
    results = data.dig("MRData", "RaceTable", "Races", 0, "Results") || []

    return if results.empty?

    results.each do |result|
      driver = Driver.find_by(external_id: result.dig("Driver", "driverId"))
      next unless driver

      RaceResult.find_or_initialize_by(
        race: race,
        driver: driver,
        session_type: "race"
      ).update!(
        position: result["position"].to_i,
        fastest_lap: result.dig("FastestLap", "rank") == "1"
      )
    end
  end

  def sync_sprint_results(year, round, race)
    data = F1ApiClient.sprint_results(year, round)
    results = data.dig("MRData", "RaceTable", "Races", 0, "SprintResults") || []

    return if results.empty?

    results.each do |result|
      driver = Driver.find_by(external_id: result.dig("Driver", "driverId"))
      next unless driver

      RaceResult.find_or_initialize_by(
        race: race,
        driver: driver,
        session_type: "sprint"
      ).update!(position: result["position"].to_i)
    end
  end

  private

  def parse_datetime(date, time)
    return nil unless date

    if time
      Time.zone.parse("#{date}T#{time}")
    else
      Time.zone.parse(date)
    end
  rescue ArgumentError
    nil
  end
end
