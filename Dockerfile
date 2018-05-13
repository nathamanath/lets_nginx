FROM nginx:1.13-alpine

# Get supervisor
RUN apk add --update \
  supervisor \
  certbot \
  bash \
  curl \
  && rm -rf /var/cache/apk/*

# Copy in scripts
COPY ./scripts/* /usr/local/bin/
RUN chmod 744 \
  /usr/local/bin/cert_renew.sh \
  /usr/local/bin/entrypoint.sh \
  /usr/local/bin/healthcheck.sh

# Copy in configs
COPY confs/nginx.conf /etc/nginx/nginx.conf
COPY confs/healthcheck.conf /etc/nginx/conf.d/healthcheck.conf
COPY confs/pre_cert.conf /etc/nginx/pre_cert.conf
COPY confs/letsencrypt.conf /etc/nginx/letsencrypt.conf
COPY confs/supervisord.conf /etc/supervisor/supervisord.conf
COPY confs/cert_renew.conf /etc/supervisor/conf.d/cert_renew.conf.live
RUN touch /etc/supervisor/conf.d/cert_renew.conf

HEALTHCHECK CMD ["healthcheck.sh"]

RUN mkdir /etc/letsencrypt
RUN mkdir /etc/nginx/sites-enabled
RUN mkdir /etc/nginx/sites-available
RUN mkdir -p /var/lib/letsencrypt
RUN mkdir -p /var/log/letsencrypt
RUN mkdir -p /var/www/letsencrypt/.well-known/acme-challenge

# Remove old Nginx defaults
RUN rm /etc/nginx/conf.d/default.conf

RUN adduser -D -H -s /bin/sh www-data

# Permission changes
RUN chown -R www-data \
  /var/log/letsencrypt \
  /var/log/nginx \
  /var/cache/nginx/ \
  /etc/nginx \
  /etc/letsencrypt \
  /etc/supervisor\
  /var/lib/letsencrypt \
  /usr/share/nginx \
  /var/www \
  /usr/local/bin/cert_renew.sh \
  /usr/local/bin/entrypoint.sh \
  /usr/local/bin/healthcheck.sh

RUN chmod 777 \
  /var/log \
  /var/run \
  /run \
  /tmp

USER www-data

EXPOSE 8080 4433

CMD ["entrypoint.sh"]
