# Nginx & Let's Encrypt

Currently the image is locked to Nginx version `1.10.3`

This uses the [Certbot](https://certbot.eff.org/docs/install.html) client to handle Let's Encrypt certificates.

## Running the image

You'll need to generate 3 files:

`cli.ini` - Configuration for Letsencrypt - a sample is provided.

`default.conf` - Configuration for at least 1 site - `sample_default.conf` contains a sample.

`dh_params.pem` - DH params file for [forward secrecy](https://scotthelme.co.uk/perfect-forward-secrecy/).

If the `cli.ini` file is not mapped to `/etc/letsencrypt/cli.ini`, the Let's Encrypt integration will be disabled.

This allows for a site that requires TLS but does not wish to make use of Let's Encrypt (self signed certificates etc).

To generate the DH params file, run the following:

```bash
$ openssl dhparam -out dh_params.pem -2 2048
```

This image has been created to run as a non-root user (`www-data`). Therefore, it doesn't use Certbots standalone plugin (that would rely on [ports below 1024](https://www.w3.org/Daemon/User/Installation/PrivilegedPorts.html)), it relies on Nginx config to send all requests to `/.well-known/acme-challenge/` to the local directory at `/var/www/letsencrypt/.well-known/acme-challenge/` and uses the [webroot plugin](https://certbot.eff.org/docs/using.html#webroot) for Certbot to handle this. This also allows for automatic renewals without taking Nginx offline.

Note: You'll need to have the following within a `server` block within your Nginx site configuration:

```
include /etc/nginx/letsencrypt.conf;
```

This is to handle the request to the ACME challenge path mentioned above.

The following is an example `docker run` command:

```bash
$ docker run -d -p 80:8080 -p 443:4433 \
  -v $(pwd)/dh_params.pem:/etc/ssl/dh/dh_params.pem \
  -v $(pwd)/default.conf:/etc/nginx/sites-available/default.conf \
  -v $(pwd)/cli.ini:/etc/letsencrypt/cli.ini \
  [THIS_IMAGE_NAME]
```

You'll notice the ports have been bumped up here to get around the issues with non-root and ports below 1024.

See `docker-stack.yml` for an example Swarm config.

## Environment variables

There is only currently 1 environment variable that can be set. This sets the renewal period for the TLS certificate. It is: `RENEWAL_PERIOD` and is passed to `sleep`. By default this is `1d` (1 day).
