#!/bin/bash

set -eo pipefail

if [ $(curl localhost:8888/healthcheck) = "ok" ]
then
  exit 0
fi

exit 1
