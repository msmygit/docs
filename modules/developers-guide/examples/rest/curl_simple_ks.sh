curl -s --location --request POST '{my_base_url}{my_base_api_schema_path}/keyspaces' \
--header "X-Cassandra-Token: $AUTH_TOKEN" \
--header 'Content-Type: application/json' \
--data '{
    "name": "users_keyspace"
}'
