#!/bin/bash

mail=$1
account=$2
directory=$3
url=$(cat "$directory" | jq -r .newAccount)
nonce=$(./get_new_nonce.sh "$directory")

./gen_ec_keys.sh $account

cat << EOF | ./create_body.sh $url $nonce $account > .body
{
	"termsOfServiceAgreed": true,
	"contact": [
	  "mailto:$mail"
	]
}
EOF

curl "$url" -i -H "Content-type: application/jose+json" --data @.body > .tmp
cat .tmp 1>&2

echo -n $account:
cat .tmp | grep -i location | cut -d : -f 2- | tr -d ' \r'
