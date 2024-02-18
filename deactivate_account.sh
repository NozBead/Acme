#!/bin/bash

account=$1
directory=$2
#url=$(cat $account | cut -d ':' -f 2-)
url=$3
nonce=$(./get_new_nonce.sh $directory)

cat << EOF | ./create_body.sh $url $nonce $account > .body
{
	"status": "deactivated"
}
EOF

curl "$url" -v -H "Content-type: application/jose+json" --data @.body
