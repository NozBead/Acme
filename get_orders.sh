#!/bin/bash

account=$1
directory=$2
url=$(cat $account | cut -d ':' -f 2-)/orders
nonce=$(./get_new_nonce.sh $directory)

echo -n | ./create_body.sh $url $nonce $account > .body

curl "$url" -v -H "Content-type: application/jose+json" --data @.body
