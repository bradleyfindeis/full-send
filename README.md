# F1 Predictions

A Rails application for managing F1 race predictions among friends.

## Configuration

### Environment Variables

**Slack Integration** (optional):
- `SLACK_WEBHOOK_URL` - Slack incoming webhook URL for posting results
- `SLACK_CHANNEL` - Channel to post to (default: `#f1-predictions`)
- `SLACK_USERNAME` - Bot username (default: `F1 Predictions Bot`)
- `SLACK_ENABLED` - Enable/disable Slack posting (default: `true`)

## Setup

1. Create a Slack app and incoming webhook:
   - Go to https://api.slack.com/apps
   - Create a new app
   - Enable Incoming Webhooks
   - Add a new webhook to your workspace
   - Copy the webhook URL

2. Set the environment variable:
   ```bash
   export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
   ```

## Features

### Slack Integration

Race results are automatically posted to Slack 24 hours after each race completes. The message includes:
- Race podium positions
- Fastest lap driver
- Each participant's prediction scores for that race
- Updated season standings

The job runs hourly and only posts once per race.
