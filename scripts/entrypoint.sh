#!/bin/bash

set -e

echo "Nginx & Let's Encrypt"
nginx -v
certbot --version

# Create log directories
# if [ ! -d /var/log/nginx ]
# then
#   mkdir /var/log/nginx
# fi

if [ -f /etc/letsencrypt/cli.ini ]
then
  echo "Found Letsencrypt cli.ini file"

  echo "Moving pre_cert.conf configuration into place"
  ln -sf /etc/nginx/pre_cert.conf /etc/nginx/sites-enabled/default

  echo "Starting Nginx"
  nginx -c /etc/nginx/nginx.conf &
  nginx_pid=$!

  sleep 2

  echo "Getting certificates"

  # Get initial certificates
  certbot certonly -c /etc/letsencrypt/cli.ini

  # Stop Nginx again
  nginx -s stop

  wait $nginx_pid

  # Remove pre_cert config
  rm /etc/nginx/sites-enabled/default

  echo "Adding in auto-renew script for Supervisord"
  ln -sf /etc/supervisor/conf.d/cert_renew.conf.live /etc/supervisor/conf.d/cert_renew.conf
fi

echo "Adding site configurations"
ls -1 /etc/nginx/sites-available | xargs -I{} ln -sf /etc/nginx/sites-available/{} /etc/nginx/sites-enabled/{}

echo "Starting Supervisord"

# Take over as init please
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
