#!/bin/bash

domain=$1
account=$2
directory=$3
url=$(cat "$directory" | jq -r .newOrder)
nonce=$(./get_new_nonce.sh "$directory")

identifiers="$(echo -e $domain | sed 's/\(.*\)/{"type":"dns","value":"\1"},/' | head -c -2)"

cat << EOF | ./create_body.sh $url $nonce $account > .body
{
	"identifiers": [
		$identifiers
	]
}
EOF

curl "$url" -i -H "Content-type: application/jose+json" --data @.body > .tmp
cat .tmp 1>&2
cat .tmp | grep -i location | cut -d : -f 2- | tr -d ' \r'
