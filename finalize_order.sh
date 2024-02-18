#!/bin/bash

base64urlencode() {
	base64 -w 0 | tr '+/=' '-_ ' | tr -d ' '
}

order_url=$(cat "$1")
account=$2
directory=$3

curl "$order_url" > .order
finalize_url=$(cat .order | jq -r .finalize)
nonce=$(./get_new_nonce.sh "$directory")
names="$(cat .order | jq -r .identifiers[].value | sed 's/\(.*\)/DNS:\1,/' | tr '\n' ' ' | head -c -2)"

openssl req -new -subj "/C=FR" -addext "subjectAltName = $names" -outform DER > csr

cat << EOF | ./create_body.sh $finalize_url $nonce $account > .body
{
	"csr": "$(cat csr | base64urlencode)"
}
EOF

curl "$finalize_url" -i -H "Content-type: application/jose+json" --data @.body
