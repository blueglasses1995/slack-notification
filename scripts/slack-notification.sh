#!/bin/bash

if [ ! $GITHUB_TOKEN ]; then
  echo "Please set GITHUB_TOKEN as environmental variable."
  exit 1
fi

payload="\`cat << EOS
  {
    \"channel\": \"${SLACK_CHANNEL}\",
    \"username\": \"Overmind\",
    \"icon_emoji\": \":information_desk_person:\",
    \"blocks\": [
      {
        \"type\": \"header\",
        \"text\": {
          \"type\": \"plain_text\",
          \"text\": \"${TITLE}\"
        },
      \"attachments\": [
        {
          \"color\": \"${COLOR}\",
          \"blocks\": [
            {
              \"type\": \"section\",
              \"fields\": [
                {
                  \"type\": \"mrkdwn\",
                  \"text\": \"*Package*\"
                },
                {
                  \"type\": \"mrkdwn\",
                  \"text\": \"*Current Version*\"
                },
                {
                  \"type\": \"mrkdwn\",
                  \"text\": \"*Available Version*\"
                }
              ]
            },"
          
PRODUCTS=("dinii-self-backend" "dinii-self-cash-register" "dinii-self-dashboard" "dinii-self-monitor" "dinii-self-functions" "dinii-self-handy" "dinii-self-kd" "dinii-self-kiosk" "dinii-self-kiosk-customer-web" "dinii-self-web")

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
        tags="$(gh api "repos/dinii-inc/dinii-self-all/tags?per_page=100&page=${counter}" -H "Accept: application/vnd.github.ant-man-preview+json")"
        quoted_available_versions=$(echo "${tags}" | jq .[].name )
        available_versions="${quoted_available_versions//\"/}"
        
        #latest_versionより新しいパッチバージョン
        later_available_versions=$(echo "${available_versions}" | sed -n -e "1,/${latest_version}/p" | grep "${latest_minor_version}")

        later_available_versions_num=$(echo ${later_available_versions} | grep -o v | wc -l )
        
        if [ "${later_available_versions_num}" -eq 0 ] || [ "${later_available_versions_num}" -eq 1 ]; then
            break
        fi
                
        #later_available_versionsの中で差分の存在する最新のパッチバージョンがlatest_available_version
        while (( "${counter}" < "${later_available_versions_num}" ))
        do
        
            tmp_latest_version=$(echo "${later_available_versions}" | grep "${latest_minor_version}" | sed -n ${counter}p)

            echo "${tmp_latest_version}"

            diffs="`git diff --name-only ${latest_version} ${tmp_latest_version} -- ./packages/${product} `"

            if [ -n "${diffs}" ]; then
                echo "e: ${tmp_latest_version}"
                latest_available_version="${tmp_latest_version}"
                break
            fi
            
            ((counter++))
        done
        ((counter++))
    done

    diff_messages=""
    if [ ${#latest_available_version} -gt 0 ]; then
        diff_messages="{
            \"type\": \"section\",
            \"fields\": [
              {
                \"type\": \"mrkdwn\",
                \"text\": \"${product}\"
              },
              {
                \"type\": \"mrkdwn\",
                \"text\": \"<${REF_URL}${latest_version}|\`${latest_version}\`>\"
              },
              {
                \"type\": \"mrkdwn\",
                \"text\": \"<${REF_URL}${latest_available_version}|\`${latest_available_version}\`>\"
              }
            ]
          },"
      payload="${payload}${diff_messages}"
    fi
done

deployment_server_link="{
            \"type\": \"section\",
            \"fields\": [
              {
                \"type\": \"mrkdwn\",
                \"text\": \"<${DEPLOYMENT_SERVER_URL}|\`Go to Deployment Server\`>\"
              }
            ]
          }"

payload="${payload}${deployment_server_link}
            ]
          }
        ]
      }
    ]
  }
EOS\`"

TIMESTAMP=$(curl --silent --show-error -X POST \
  -H "Authorization: Bearer ${SLACK_TOKEN}" \
  -H "Content-"type": application/json; charset=utf-8" \
  --data "${payload}" \
  https://slack.com/api/chat.postMessage | jq -r ".ts")

echo ${TIMESTAMP}
