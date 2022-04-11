#!/bin/bash

payload="\`cat \<\< EOS
  {
    \"channel\": ${SLACK_CHANNEL},
    \"username\": \"Overmind\",
    \"icon_emoji\": \":information_desk_person:\",
    \"blocks\": [
      {
        \"type\": \"header\",
        \"text\": {
          \"type\": \"plain_text\",
          \"text\": ${TITLE}
        }
      },
    \"attachments\": [
      {
        \"color\": ${COLOR},
        \"blocks\": [
          {
            \"type\": \"section\",
            \"fields\": [
              {
                \"type\": \"mrkdwn\",
                \"text\": \"*Package*\",
              },
              {
                \"type\": \"mrkdwn\",
                \"text\": \"*Current Version*\",
              },
              {
                \"type\": \"mrkdwn\",
                \"text\": \"*Available Version*\",
              },
            ],
          },"
          
PRODUCTS=("dinii-self-backend" "dinii-self-cash-register" "dinii-self-dashboard" "dinii-self-monitor" "dinii-self-functions" "dinii-self-handy" "dinii-self-kd" "dinii-self-kiosk" "dinii-self-kiosk-customer-web" "dinii-self-web")

echo $GITHUB_TOKEN | gh auth login --with-token

for product in ${PRODUCTS[@]}
do
    data="$(gh api "repos/dinii-inc/dinii-self-all/deployments?task=deploy-${product}&environment=${ENVIRONMENT}" -H "Accept: application/vnd.github.ant-man-preview+json")"
    deployments=$(echo "${data}" | jq -r '[.[] | { deployment_id: .id, version: .ref }]')
    
    if [ -z ${deployments} ]; then
        continue
    fi

    deployments_length=$(echo "${deployments}" | jq '. | length')

    latest_version=""
    latest_minor_version=""
    counter=0
    while (( "${counter}" < ${deployments_length} ))
    do
        deployment_id=$( echo "${deployments}" | jq .["${counter}"].deployment_id)
        version=$( echo "${deployments}" | jq .["${counter}"].version)
        status="$(gh api "repos/dinii-inc/dinii-self-all/deployments/${deployment_id}/statuses" -H "Accept: application/vnd.github.ant-man-preview+json")"
        
        #成功した場合にのみ文字列が返る
        is_success=$( echo $(echo "${status}" | jq .[].state )  | grep '"success"')
        latest_version="${version//\"/}"
        latest_minor_version=$( echo "${latest_version}" | cut -c 1-5)
        if [[ "${is_success}" ]]; then
            break
        fi
        ((counter++))
    done

    if [ -z ${is_success} ]; then
        continue
    fi

    latest_available_version=""
    while (( "${counter}" < 100000 ))
    do
        tags="$(gh api "repos/dinii-inc/dinii-self-all/tags?per_page=10&page=${counter}" -H "Accept: application/vnd.github.ant-man-preview+json")"
        quoted_available_versions=$(echo "${tags}" | jq .[].name )
        available_versions="${quoted_available_versions//\"/}"
        if [[ $(echo "${available_versions}" | grep "${latest_minor_version}") ]]; then
            #最新マイナーバージョンのうちの最大パッチバージョンを持ってくる
            for version in $available_versions; do
                if [[ $(echo "${version}" | grep "${latest_minor_version}") ]]; then
                    latest_available_version="${version}"
                    break
                fi
            done
            break
        fi
        ((counter++))
    done

    diff_messages=""
    if test "${latest_version}" != "${latest_available_version}"; then
        diff_messages="{
            \"type\": \"section\",
            \"fields\": [
              {
                \"type\": \"mrkdwn\",
                \"text\": ${product},
              },
              {
                \"type\": \"mrkdwn\",
                \"text\": <${REF_URL}${latest_version}|\`${latest_version}\`>,
              },
              {
                \"type\": \"mrkdwn\",
                \"text\": <${REF_URL}${latest_available_version}|\`${latest_available_version}\`>,
              },
            ],
          },"
      payload="${payload}${diff_messages}"
    fi
done

deployment_server_link="{
            \"type\": \"section\",
            \"fields\": [
              {
                \"type\": \"mrkdwn\",
                \"text\": <${DEPLOYMENT_SERVER_URL}|\`Go to Deployment Server\`,
              },
            ],
          },"

payload="${payload}${deployment_server_link}
        ],
      },
    ],
  }
EOS\`"

TIMESTAMP=$(curl --silent --show-error -X POST \
  -H "Authorization: Bearer ${SLACK_TOKEN}" \
  -H "Content-"type": application/json; charset=utf-8" \
  --data "${payload}" \
  https://slack.com/api/chat.postMessage | jq -r ".ts")

echo $TIMESTAMP