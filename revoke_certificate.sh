#!/bin/bash

base64urlencode() {
	base64 -w 0 | tr '+/=' '-_ ' | tr -d ' '
}

certificate=$1
account=$2
directory=$3
url=$(cat "$directory" | jq -r .revokeCert)
nonce=$(./get_new_nonce.sh "$directory")

cat << EOF | ./create_body.sh $url $nonce $account > .body
{
	"certificate": "$(openssl x509 -in "$certificate" -outform DER | base64urlencode)",
	"reason": 4
}
EOF

curl "$url" -i -H "Content-type: application/jose+json" --data @.body
