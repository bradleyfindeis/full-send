class PredictionReminderMailer < ApplicationMailer
  default from: "Full Send <noreply@fullsend.racing>"
  helper :prediction_reminder

  def reminder_email(user:, race:, urgency:)
    @user = user
    @race = race
    @urgency = urgency
    @predictions_url = new_race_prediction_url(race)
    @user_timezone = ActiveSupport::TimeZone[@user.timezone || "America/Denver"]

    subject = case urgency
    when :day_before_quali
      "#{race.name} predictions close tomorrow!"
    when :day_of_quali
      "Last chance for #{race.name} qualifying predictions!"
    when :day_of_race
      "Final reminder: #{race.name} race predictions closing soon!"
    else
      "Don't forget to make your #{race.name} predictions!"
    end

    mail(to: @user.email_address, subject: subject)
  end
end
