#!/bin/bash

base64urlencode() {
	base64 -w 0 | tr '+/=' '-_ ' | tr -d ' '
}

openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out "$1.pem"
openssl ec -in "$1.pem" -pubout -out "$1_pub.pem"

openssl ec -in "$1_pub.pem" -pubin -noout -text 2>&1 | grep -E '^ +' | tr -d ':\n ' | xxd -r -p > "$1.bin"

cat > "$1.jwk" << EOF
{
	"kty":"EC",
	"crv":"P-256",
	"x":"$(cat "$1.bin" | tail -c +2 | head -c 32 | base64urlencode)",
	"y":"$(cat "$1.bin" | tail -c +34 | base64urlencode)",
        "use":"enc"
}
EOF
