#!/usr/bin/env bash

set -eu -o pipefail

echo "Starting up test infrastructure"
docker-compose up -d

echo "Wait for Knox and containers to come up"
sleep 30

echo "Knox should be up by now"

# This can be used to test to make sure failover works even when specifying specific cookie backends
#docker-compose stop whoami1
#docker-compose stop whoami2

KNOX="https://localhost:$(docker-compose port gateway 8443 | cut -d ':' -f2)"
echo "Here is the Knox endpoint: $KNOX"

echo "Starting tests"

echo "Testing that each curl without cookies gets a new backend"
set -x
curl --fail -iku admin:admin-password "$KNOX/gateway/test/whoami/"
curl --fail -iku admin:admin-password "$KNOX/gateway/test/whoami/"
curl --fail -iku admin:admin-password "$KNOX/gateway/test/whoami/"
set +x
echo
echo

echo "Testing that invalid cookies don't affect backend selection"
set -x
curl --fail -iku admin:admin-password -b 'KNOX_BACKEND-WHOAMI=http://whoami2:8000' "$KNOX/gateway/test/whoami/"
curl --fail -iku admin:admin-password -b 'KNOX_BACKEND=5b0945097d7a654ffe3efeb74d6a2b28ff11612a9d8ba470dc05f002ead2749d' "$KNOX/gateway/test/whoami/"
set +x
echo
echo

echo "Testing that cookie selection works"
set -x
curl --fail -iku admin:admin-password -b 'KNOX_BACKEND-WHOAMI=5b0945097d7a654ffe3efeb74d6a2b28ff11612a9d8ba470dc05f002ead2749d' "$KNOX/gateway/test/whoami/"
curl --fail -iku admin:admin-password -b 'KNOX_BACKEND-WHOAMI=5b0945097d7a654ffe3efeb74d6a2b28ff11612a9d8ba470dc05f002ead2749d' "$KNOX/gateway/test/whoami/"
curl --fail -iku admin:admin-password -b 'KNOX_BACKEND-WHOAMI=5b0945097d7a654ffe3efeb74d6a2b28ff11612a9d8ba470dc05f002ead2749d' "$KNOX/gateway/test/whoami/"
set +x
echo
echo

echo "Finished testing - stopping test infrastructure"
docker-compose down -v

