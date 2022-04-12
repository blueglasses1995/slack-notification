payload='{ "channel": "#general",
  "username": "Overmind",
  "icon_emoji": ":information_desk_person:",
  "blocks": [
    { "type": "header",
      "text": { "type": "plain_text", "text": "現時点でstaging環境で最新のパッチバージョンでないPackage一覧" },
      "attachments": [
        { "color": "#4db56a",
          "blocks": [
            { "type": "section", "fields": [
                { "type": "mrkdwn", "text": "*Package*", },
                { "type": "mrkdwn", "text": "*Current Version*", },
                { "type": "mrkdwn", "text": "*Available Version*", },
              ],
            },
            { "type": "section", "fields": [
                { "type": "mrkdwn", "text": "dinii-self-backend", },
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.0|`v1.68.0`>", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.2|`v1.68.2`>", }, 
              ], 
            },
            { "type": "section", "fields": [
                { "type": "mrkdwn", "text": "dinii-self-cash-register", },
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.0|`v1.68.0`>", },
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.2|`v1.68.2`>", },
              ],
            },
            { "type": "section", "fields": [ 
                { "type": "mrkdwn", "text": "dinii-self-dashboard", },
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.0|`v1.68.0`>", },
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.2|`v1.68.2`>", },
              ], 
            },
            { "type": "section", "fields": [
                { "type": "mrkdwn", "text": "dinii-self-monitor", },
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.0|`v1.68.0`>", },
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.2|`v1.68.2`>", },
              ],
            },
            { "type": "section", "fields": [ 
                { "type": "mrkdwn", "text": "dinii-self-handy", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.0|`v1.68.0`>", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.2|`v1.68.2`>", }, 
              ], 
            },
            { "type": "section", "fields": [ 
                { "type": "mrkdwn", "text": "dinii-self-kd", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.0|`v1.68.0`>", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.2|`v1.68.2`>", }, 
              ], 
            },
            { "type": "section", "fields": [ 
                { "type": "mrkdwn", "text": "dinii-self-kiosk", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.0|`v1.68.0`>", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.2|`v1.68.2`>", }, 
              ], 
            },
            { "type": "section", "fields": [ 
                { "type": "mrkdwn", "text": "dinii-self-kiosk-customer-web", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.53.0|`v1.53.0`>", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.53.46|`v1.53.46`>", }, 
              ], 
            },
            { "type": "section", "fields": [ 
                { "type": "mrkdwn", "text": "dinii-self-web", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.0|`v1.68.0`>", }, 
                { "type": "mrkdwn", "text": "<https://github.com/dinii-inc/dinii-self-all/tree/v1.68.2|`v1.68.2`>", }, 
              ], 
            },
            { "type": "section", "fields": [ 
                { "type": "mrkdwn", "text": "<https://deploy-server.develop.self.dinii.jp/|`Go to Deployment Server`", }, 
              ],
            }, 
        }, 
      ], 
    }, 
  ], 
}'

TIMESTAMP=$(curl --silent --show-error -X POST \
  -H "Authorization: Bearer ${SLACK_TOKEN}" \
  -H "Content-"type": application/json; charset=utf-8" \
  --data "\`cat << EOS ${payload} EOS\`" \
  https://slack.com/api/chat.postMessage | jq -r ".ts")