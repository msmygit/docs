curl --location \
--request POST '{my_base_url}{my_base_api_path}/namespaces/myworld/collections/fitness' \
--header "X-Cassandra-Token: $AUTH_TOKEN" \
--header 'Content-Type: application/json' \
--data '{
  "id": "some-stuff",
  "other": "This is nonsensical stuff."
}'