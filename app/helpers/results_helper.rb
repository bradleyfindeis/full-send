module ResultsHelper
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

  def team_color(team_id)
    TEAM_COLORS[team_id] || "#6B7280"
  end

  def clean_team_name(name)
    return "" if name.blank?
    name
      .gsub(/ F1 Team$/i, "")
      .gsub(/^Stake F1 Team /, "")
      .gsub(/^MoneyGram /, "")
      .gsub(/^Visa Cash App /, "")
      .strip
  end
end
