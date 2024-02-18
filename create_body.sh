#!/bin/bash

base64urlencode() {
	base64 -w 0 | tr '+/=' '-_ ' | tr -d ' '
}

remove_der() {
	openssl asn1parse -inform DER | grep INTEGER | cut -d : -f 4 | tr -d '\n' | xxd -u -p -r
}

sign() {
	echo -n $1 | openssl dgst -sha256 -sign "$2" | remove_der | base64urlencode
}

url=$1
nonce=$2
account=$3

key_field=""
key=""
if echo $account | grep -E '*.account' &> /dev/null ; then
	key=$(cat "$account" | cut -d ':' -f 1)
	key_field="\"kid\": \"$(cat "$account" | cut -d ':' -f 2-)\""
else
	key=$account
	key_field="\"jwk\": $(cat "$key.jwk")"
fi

payload=$(cat | base64urlencode)
protected=$(cat << EOF | base64urlencode
{
	"alg": "ES256",
	$key_field,	
	"nonce": "$nonce",
	"url": "$url"
}
EOF
)

cat << EOF
{
	"protected":"$protected",
	"payload":"$payload",
	"signature":"$(sign $protected.$payload $key.pem)"
}
EOF
