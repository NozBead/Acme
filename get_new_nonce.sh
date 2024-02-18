#!/bin/bash

directory=$1
url=$(cat "$directory" | jq -r .newNonce)

curl -I "$url" | grep -i "replay-nonce:" | cut -d ':' -f 2 | tr -d ' \r'
