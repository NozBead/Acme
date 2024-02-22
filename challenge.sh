#!/bin/bash

base64urlencode() {
	base64 -w 0 | tr '+/=' '-_ ' | tr -d ' '
}

hash_bin() {
	sha256sum | cut -d " " -f 1 | xxd -p -r 
}

order=$1
account=$2
directory=$3
order_url=$(cat "$1")

key=$(cat "$account" | cut -d ':' -f 1)
thumbprint=$(cat $key.jwk | jq -c "{crv, kty, x, y}" | tr -d '\n' | hash_bin | base64urlencode)

time=$(date +%s)

for auth_url in $(curl "$order_url" | jq -r .authorizations[]) ; do
	curl "$auth_url" > .${time}.authz
	cat .${time}.authz | jq '.challenges[] | select(.type | test("dns"))' > .${time}.challenge
	identifier=$(cat .${time}.authz | jq -r .identifier.value)
	token=$(cat .${time}.challenge | jq -r .token)

	key_auth=$(echo -n $token.$thumbprint | sha256sum | cut -d " " -f 1 | xxd -p -r | base64urlencode)
	echo Waitting DNS $identifier : $key_auth
	echo Press ENTER when ready.
	ovh/add_dns_entry.sh $identifier TXT _acme-challenge $key_auth 60
	read

	nonce=$(./get_new_nonce.sh "$directory")
	challenge_url=$(cat .${time}.challenge | jq -r .url)
	echo -n '{}' | ./create_body.sh $challenge_url $nonce $account > .body
	curl "$challenge_url" -H "Content-type: application/jose+json" --data @.body 
done
