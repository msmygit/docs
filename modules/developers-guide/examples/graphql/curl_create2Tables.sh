curl --location --request POST --url {my_base_url}{my_base_api_schema_path} \
--header "X-Cassandra-Token: $AUTH_TOKEN" \
--header 'Content-Type: application/json' \
--data-raw '{"query":"mutation createTables {\n  book: createTable(\n    keyspaceName:\"library\",\n    tableName:\"book\",\n    partitionKeys: [ # The keys required to access your data\n      { name: \"title\", type: {basic: TEXT} }\n    ]\n    clusteringKeys: [\n      { name: \"author\", type: {basic: TEXT} }\n    ]\n  )\n  reader: createTable(\n    keyspaceName:\"library\",\n    tableName:\"reader\",\n    partitionKeys: [\n      { name: \"name\", type: {basic: TEXT} }\n    ]\n    clusteringKeys: [ # Secondary key used to access values within the partition\n      { name: \"user_id\", type: {basic: UUID}, order: \"ASC\" }\n        ]\n    values: [\n      { name: \"birthdate\", type: {basic: DATE} }\n      { name: \"email\", type: {basic: SET, info:{ subTypes: [ { basic: TEXT } ] } } }\n      { name: \"reviews\", type: {basic: TUPLE, info: { subTypes: [ { basic: TEXT }, { basic: INT }, { basic: DATE } ] } } }\n      { name: \"addresses\", type: { basic: LIST, info: { subTypes: [ { basic: UDT, info: { name: \"address_type\", frozen: true } } ] } } }\n    ]\n  )\n}","variables":{}}'
