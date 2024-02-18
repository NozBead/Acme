#!/bin/bash

endpoint="https://eu.api.ovh.com/v1"
app=
secret=
consumer=

post_data() {
	url="$1"
	timestamp=$(date +%s)
	signature='$1$'$(echo -n "$secret+$consumer+POST+$url+$(cat .body)+$timestamp" | sha1sum | cut -d ' ' -f 1)

	curl -v $url \
		-H "X-Ovh-Application: $app" \
		-H "X-Ovh-Consumer: $consumer" \
		-H "X-Ovh-Timestamp: $timestamp" \
		-H "X-Ovh-Signature: $signature" \
		--json @.body
}

cat << EOF | tr -d '\n \t' > .body
{
	"fieldType": "$2",
	"subDomain": "$3",
	"target": "$4",
	"ttl": $5
}
EOF

post_data "$endpoint/domain/zone/$1/record"

rm .body
touch .body

post_data "$endpoint/domain/zone/$1/refresh"
