module PredictionReminderHelper
  def format_time_for_user(time, timezone)
    return "TBD" unless time
    time.in_time_zone(timezone).strftime("%B %d at %H:%M %Z")
  end
end
