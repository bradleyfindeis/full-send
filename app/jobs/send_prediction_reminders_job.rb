class SendPredictionRemindersJob < ApplicationJob
  queue_as :default

  def perform
    season = Season.current_season
    return unless season

    now = Time.current
    
    season.races.each do |race|
      next if race.race_locked?
      
      urgency = determine_urgency(race, now)
      next unless urgency

      users_without_predictions(race, urgency).find_each do |user|
        next if already_reminded?(user, race, urgency)
        
        PredictionReminderMailer.reminder_email(
          user: user,
          race: race,
          urgency: urgency
        ).deliver_later

        record_reminder(user, race, urgency)
      end
    end
  end

  private

  def determine_urgency(race, now)
    quali_date = race.quali_date
    race_date = race.race_date
    
    return nil unless quali_date && race_date

    hours_until_quali = (quali_date - now) / 1.hour
    hours_until_race = (race_date - now) / 1.hour

    if hours_until_race > 0 && hours_until_race <= 3
      :day_of_race
    elsif hours_until_quali > 0 && hours_until_quali <= 12
      :day_of_quali
    elsif hours_until_quali > 12 && hours_until_quali <= 36
      :day_before_quali
    else
      nil
    end
  end

  def users_without_predictions(race, urgency)
    case urgency
    when :day_of_race
      users_missing_race_predictions(race)
    else
      users_missing_any_predictions(race)
    end
  end

  def users_missing_any_predictions(race)
    User.where(email_reminders: true).where.not(
      id: Prediction.where(race: race).select(:user_id).distinct
    )
  end

  def users_missing_race_predictions(race)
    users_with_complete_race_predictions = Prediction.where(
      race: race,
      session_type: "race"
    ).group(:user_id).having("COUNT(*) >= 4").select(:user_id)

    User.where(email_reminders: true).where.not(id: users_with_complete_race_predictions)
  end

  def already_reminded?(user, race, urgency)
    cache_key = reminder_cache_key(user, race, urgency)
    Rails.cache.exist?(cache_key)
  end

  def record_reminder(user, race, urgency)
    cache_key = reminder_cache_key(user, race, urgency)
    Rails.cache.write(cache_key, true, expires_in: 7.days)
  end

  def reminder_cache_key(user, race, urgency)
    "prediction_reminder:#{user.id}:#{race.id}:#{urgency}"
  end
end
