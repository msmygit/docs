#!/bin/bash

# MUST DO THE URL AND PATH SUBSTITUTIONS BEFORE RUNNING THE TESTS

export ASTRA_CLUSTER_ID=8319febd-e7cf-4595-81e3-34f45d332d2a
export ASTRA_REGION=us-east1
export ASTRA_USERNAME=polandll
export ASTRA_PASSWORD=Lmm2soht!

for FILE in *;
 do 
    if [[ "$FILE" != "test"* ]]
    then
      gsed 's#{my_base_url}#https://$ASTRA_CLUSTER_ID-$ASTRA_REGION.apps.astra.datastax.com#; s#{my_base_api_schema_path}#/api/rest/v2/schemas#; s#{my_base_api_path}#/api/rest/v2#' $FILE > $FILE.tmp;
      chmod 755 $FILE.tmp;
    fi
done

# SET THE AUTH_TOKEN FOR ALL THE OTHER COMMANDS

export AUTH_TOKEN=$(curl -s -L -X POST 'https://8319febd-e7cf-4595-81e3-34f45d332d2a-us-east1.apps.astra.datastax.com/api/rest/v1/auth' \
  -H 'Content-Type: application/json' \
  --data-raw '{
    "username": "polandll",
    "password": "Lmm2soht!"
}' | jq -r '.authToken')

#export AUTH_TOKEN=$(curl -s -L -X POST 'https://$ASTRA_CLUSTER_ID-$ASTRA_REGION.apps.astra.datastax.com/api/rest/v1/auth' \
#  -H 'Content-Type: application/json' \
#  --data-raw '{
#    "username": "$ASTRA_USERNAME",
#    "password": "$ASTRA_PASSWORD"
#}' | jq -r '.authToken')

printenv |grep AUTH_TOKEN

echo "drop ks to clear all data: "
#./curl_drop_ks.sh.tmp

# RUN THE DDL

#echo "create keyspace "
#./curl_create_ks.sh.tmp | jq -r '.name | test("users_keyspace")'

# HOW TO TEST THE ALTERNATE CREATE_KS?? NEED TO FIGURE IT OUT
#./curl_simple_ks.sh.tmp | jq -r '.name | test("users_keyspace")'
#echo "create ks_dcs: "
#./curl_ks_dcs.sh.tmp | jq -r '.name | test("users_keyspace_dcs")'

echo "create table and add columns "
./curl_create_table.sh.tmp | jq -r '.name | test("users")'
echo "add_column: "
./curl_add_column.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_add_column.result)
echo "add_set_to_table: "
./curl_add_set_to_table.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_add_set_to_table.result)
echo "add_list_to_table: "
./curl_add_list_to_table.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_add_list_to_table.result)
echo "add map to table: "
./curl_add_map_to_table.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_add_map_to_table.result)
echo "add tuple to table: "
./curl_add_tuple_to_table.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_add_tuple_to_table.result)
echo "add udt to table: "
./curl_add_udt_to_table.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_add_udt_to_table.result)

# NEED TO CHECK CURL_CHANGE_COLUMN.SH, BUT IT MESSES UP REST OF WORK, SO CHANGE BACK
echo "Change column and back: "
./curl_change_column.sh.tmp
./curl_change_column_back.sh.tmp

# CHECK EXISTENCE OF SCHEMA
echo "check existence"
#test $(./curl_check_ks_exists.sh.tmp | jq '.| length') -eq 1 && echo "PASS" || echo "FAIL"
./curl_check_ks_exists.sh.tmp | jq -r '.data[].name | test("users_keyspace")'
echo "check ks users_keyspace"
./curl_get_particular_ks.sh.tmp | jq '.'> HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_particular_ks.result)
./curl_check_table_exists.sh.tmp | jq '.data[].name | test("users")'
echo "check table users"
./curl_get_particular_table.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_particular_table.result)
echo "email test 1"
./curl_check_column_exists.sh.tmp | jq '.data[].name | test("email")'
echo "email test 2"
./curl_check_column_exists.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_check_column_exists.result)
echo "check column email"
./curl_get_particular_column.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_particular_column.result)

# CQL INDEXES ARE REQUIRED FOR SOME DML, MUST CREATE IN CQLSH
# CREATE INDEX books_idx ON users_keyspace.users (VALUES(favorite_books));
# CREATE INDEX tv_idx ON users_keyspace.users (VALUES (top_three_tv.sh.tmpows));
# CREATE INDEX eval_idx ON users_keyspace.users (KEYS (evaluations));
# CREATE INDEX country_idx ON users_keyspace.users (current_country);

# RUN THE DML
echo "write users"
./curl_write_users.sh.tmp|jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_write_users.result)
echo "write set"
./curl_insert_set_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_insert_set_data.result)
echo "write list"
./curl_insert_list_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_insert_list_data.result)
echo "write map"
./curl_insert_map_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_insert_map_data.result)
echo "write tuple"
./curl_insert_tuple_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_insert_tuple_data.result)
echo "write udt"
./curl_insert_udt_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_insert_udt_data.result)

echo "patch users"
./curl_patch_users.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_patch_users.result)
echo "update users"
./curl_update_users.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_update_users.result)

echo "get prim key"
./curl_get_primKey.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_primKey.result)
# THESE NEED 2i
echo "get set"
./curl_get_set_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_set_data.result)
echo "get list"
./curl_get_list_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_list_data.result)
echo "get map"
./curl_get_map_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_map_data.result)
echo "get tuple"
./curl_get_tuple_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_tuple_data.result)
# END OF NEED 2i
echo "get udt"
./curl_get_udt_data.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_udt_data.result)

echo "get users"
./curl_get_users.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_users.result)
echo "get users where"
./curl_get_users_where.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_users_where.result)
echo "get users mult where"
./curl_get_users_mult_where.sh.tmp | jq -r '.' > HOLD; diff <(gron HOLD) <(gron ../result/rest_curl_get_users_mult_where.result)

# DROP/DELETE ALL SCHEMA
#./curl_delete_row.sh.tmp
#./curl_drop_column.sh.tmp
#./curl_drop_table.sh.tmp
#./curl_drop_ks.sh.tmp

# CLEAN UP tmp files
#rm *.tmp; rm HOLD;
