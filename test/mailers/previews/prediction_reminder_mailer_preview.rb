class PredictionReminderMailerPreview < ActionMailer::Preview
  def day_before_quali
    PredictionReminderMailer.reminder_email(
      user: User.first,
      race: Race.first,
      urgency: :day_before_quali
    )
  end

  def day_of_quali
    PredictionReminderMailer.reminder_email(
      user: User.first,
      race: Race.first,
      urgency: :day_of_quali
    )
  end

  def day_of_race
    PredictionReminderMailer.reminder_email(
      user: User.first,
      race: Race.first,
      urgency: :day_of_race
    )
  end
end
