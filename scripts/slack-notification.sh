name: CRON
on:
  schedule:
    # UTC
    - cron: "*/1 * * * *"

jobs:
  slack-notification:
    name: Fetch unreleased patch versions
    runs-on: ubuntu-latest
    steps:
      - name: Notify errors of the "fetching unreleased patch versions" step above
        run: ./scripts/slack-notification.sh
        env:
          SLACK_URL: "https://hooks.slack.com/services/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"
          SLACK_CHANNEL: "#general"
          TITLE: "現時点でbeta環境で最新のパッチバージョンでないPackage一覧"
          ENVIRONMENT: "beta"
          REF_URL: "https://github.com/dinii-inc/dinii-self-all/tree/"
          DEPLOYMENT_SERVER_URL: "https://deploy-server.develop.self.dinii.jp/"
          COLOR: "#4db56a"
          SLACK_TOKEN: ${{ secrets.SLACK_TOKEN }}