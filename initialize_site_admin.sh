#!/bin/bash

dns_host_name=$1
dns_domain_name=$2
sg_initial_admin_email=$3
sg_initial_admin_username=$4
sg_initial_admin_password=$5
sg_initial_admin_timeout_seconds=$6

sg_url="https://$dns_host_name.$dns_domain_name/-/site-init"


function curl_sg_url() {
    curl \
        --output /dev/null \
        --silent \
        --connect-timeout 3 \
        --head \
        -w "%{http_code}" \
        "$sg_url"
}

echo "Waiting up to $sg_initial_admin_timeout_seconds seconds for Sourcegraph instance to be ready at $sg_url"

timeout_time=$(($(date +%s) + sg_initial_admin_timeout_seconds))
curl_sg_status_code=""
while true
do
    curl_sg_status_code=$(curl_sg_url)

    if [ "$curl_sg_status_code" == "200" ]
    then
        echo ""
        echo "Sourcegraph instance is ready for initilization!"
        break
    elif [[ $(date +%s) -ge $timeout_time ]]
    then
        echo ""
        echo "Sourcegraph instance failed to get ready initilization within $sg_initial_admin_timeout_seconds seconds"
        break
    else
        # printf '.'
        sleep 1
    fi
done

curl_response="$(curl \
    -s \
    -H 'Content-Type: application/json' \
    -d "$(cat <<EOF
'{
  "email": "$sg_initial_admin_email",
  "username": "$sg_initial_admin_username",
  "password": "$sg_initial_admin_password",
}'
EOF
)"  \
    "$sg_url")"

echo "curl_response: $curl_response"
