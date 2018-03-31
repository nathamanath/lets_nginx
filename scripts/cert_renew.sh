#!/bin/bash

RENEWAL_PERIOD=${RENEWAL_PERIOD:-"1d"}

echo "Renewing certificates every $RENEWAL_PERIOD"

while :
do
  sleep $RENEWAL_PERIOD
  echo "Renewing certificates"

  # Run the certificate renewal
  certbot certonly -c /scripts/cli.ini --post-hook "nginx -s reload"
done