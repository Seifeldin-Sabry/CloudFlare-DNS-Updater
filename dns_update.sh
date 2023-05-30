#!/bin/bash

IFS='
'
for line in $(cat ./.env)
do
  export $line
done
unset IFS

# Cloudflare settings
auth_email=$auth_email
auth_key=$auth_key
zone_id=$zone_id
record_name=$record_name

# Get current public IP
ip=$(curl -s https://ifconfig.me)

# Fetch current DNS IP from Cloudflare
current_ip=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=A&name=${record_name}" -H "Authorization: Bearer ${auth_key}" -H "Content-Type: application/json" | jq -r .result[0].content)

# Update DNS record with current public IP
if [[ "${ip}" != "${current_ip}" ]]; then
  record_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?type=A&name=${record_name}" -H "Authorization: Bearer ${auth_key}" -H "Content-Type: application/json" | jq -r .result[0].id)
  update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${record_id}" -H "Authorization: Bearer ${auth_key}" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"name\":\"${record_name}\",\"content\":\"${ip}\"}")
fi
