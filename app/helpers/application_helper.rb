module ApplicationHelper
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
    "audi" => "#E0001A",
    "cadillac" => "#1E3A5F"
  }.freeze

  TIMEZONE_OPTIONS = [
    ["Hawaii (HST)", "Pacific/Honolulu"],
    ["Alaska (AKST)", "America/Anchorage"],
    ["Pacific (PST)", "America/Los_Angeles"],
    ["Mountain (MST)", "America/Denver"],
    ["Central (CST)", "America/Chicago"],
    ["Eastern (EST)", "America/New_York"],
    ["Atlantic (AST)", "America/Halifax"],
    ["London (GMT)", "Europe/London"],
    ["Central European (CET)", "Europe/Paris"],
    ["Eastern European (EET)", "Europe/Helsinki"],
    ["Dubai (GST)", "Asia/Dubai"],
    ["India (IST)", "Asia/Kolkata"],
    ["Singapore (SGT)", "Asia/Singapore"],
    ["Japan (JST)", "Asia/Tokyo"],
    ["Sydney (AEST)", "Australia/Sydney"],
    ["Auckland (NZST)", "Pacific/Auckland"]
  ].freeze

  TIME_FORMAT_OPTIONS = [
    ["24-hour (14:30)", "24h"],
    ["12-hour (2:30 PM)", "12h"]
  ].freeze

  THEME_OPTIONS = [
    ["Default (Red)", "default"],
    ["Red Bull Racing", "red_bull"],
    ["Ferrari", "ferrari"],
    ["Mercedes", "mercedes"],
    ["McLaren", "mclaren"],
    ["Aston Martin", "aston_martin"],
    ["Alpine", "alpine"],
    ["Williams", "williams"],
    ["RB", "rb"],
    ["Haas", "haas"],
    ["Audi", "audi"],
    ["Cadillac", "cadillac"]
  ].freeze

  THEME_COLORS = {
    "default" => { primary: "#dc2626", hover: "#b91c1c", text: "#ffffff" },
    "red_bull" => { primary: "#3671C6", hover: "#2860b0", text: "#ffffff" },
    "ferrari" => { primary: "#E80020", hover: "#c9001b", text: "#ffffff" },
    "mercedes" => { primary: "#27F4D2", hover: "#20d4b5", text: "#000000" },
    "mclaren" => { primary: "#FF8000", hover: "#e67300", text: "#000000" },
    "aston_martin" => { primary: "#229971", hover: "#1d8260", text: "#ffffff" },
    "alpine" => { primary: "#FF87BC", hover: "#ff6aa8", text: "#000000" },
    "williams" => { primary: "#64C4FF", hover: "#4ab8ff", text: "#000000" },
    "rb" => { primary: "#6692FF", hover: "#4d7fff", text: "#ffffff" },
    "haas" => { primary: "#B6BABD", hover: "#a3a8ab", text: "#000000" },
    "audi" => { primary: "#E0001A", hover: "#c00017", text: "#ffffff" },
    "cadillac" => { primary: "#1E3A5F", hover: "#152a45", text: "#ffffff" }
  }.freeze

  def team_color(team_id)
    TEAM_COLORS[team_id] || "#6B7280"
  end

  def user_timezone
    current_user&.timezone || "America/Denver"
  end

  def user_time_format
    current_user&.time_format || "24h"
  end

  def user_theme
    current_user&.theme || "default"
  end

  def theme_colors
    THEME_COLORS[user_theme] || THEME_COLORS["default"]
  end

  def theme_primary
    theme_colors[:primary]
  end

  def theme_hover
    theme_colors[:hover]
  end

  def theme_text
    theme_colors[:text]
  end

  def local_time(time, format: :short)
    return nil unless time
    
    tz = ActiveSupport::TimeZone[user_timezone]
    local = time.in_time_zone(tz)
    use_12h = user_time_format == "12h"
    
    case format
    when :short
      use_12h ? local.strftime("%b %d, %l:%M %p") : local.strftime("%b %d, %H:%M")
    when :long
      use_12h ? local.strftime("%B %d, %Y at %l:%M %p") : local.strftime("%B %d, %Y at %H:%M")
    when :date_only
      local.strftime("%B %d, %Y")
    when :time_only
      use_12h ? local.strftime("%l:%M %p").strip : local.strftime("%H:%M")
    when :day_time
      use_12h ? local.strftime("%A, %b %d at %l:%M %p") : local.strftime("%A, %b %d at %H:%M")
    else
      local.strftime(format)
    end
  end

  def timezone_abbrev
    tz = ActiveSupport::TimeZone[user_timezone]
    Time.current.in_time_zone(tz).strftime("%Z")
  end

  def driver_options_with_teams(drivers, selected_id = nil)
    options = [content_tag(:option, "Select driver...", value: "")]
    
    drivers_by_team = drivers.includes(:team).group_by(&:team)
    
    drivers_by_team.sort_by { |team, _| team&.name || "ZZZ" }.each do |team, team_drivers|
      team_drivers.sort_by(&:name).each do |driver|
        color = team_color(team&.external_id)
        selected = driver.id == selected_id
        options << content_tag(
          :option,
          "#{driver.name} (#{team&.name || 'No Team'})",
          value: driver.id,
          selected: selected,
          data: { team_color: color, team_name: team&.name },
          style: "border-left: 4px solid #{color}; padding-left: 8px;"
        )
      end
    end
    
    safe_join(options)
  end
end
