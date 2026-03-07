Rails.application.config.slack = ActiveSupport::OrderedOptions.new
Rails.application.config.slack.webhook_url = ENV.fetch("SLACK_WEBHOOK_URL", nil)
Rails.application.config.slack.channel = ENV.fetch("SLACK_CHANNEL", "#f1-predictions")
Rails.application.config.slack.username = ENV.fetch("SLACK_USERNAME", "F1 Predictions Bot")
Rails.application.config.slack.enabled = ENV.fetch("SLACK_ENABLED", "true") == "true"
