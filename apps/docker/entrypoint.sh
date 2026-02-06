#!/usr/bin/env bash
set -euo pipefail

Rscript -e "setwd('/app/apps/cmo-explorer'); shiny::runApp('.', host='0.0.0.0', port=3838, launch.browser = FALSE)" &
Rscript -e "setwd('/app/apps/demi-regularities-explorer'); shiny::runApp('.', host='0.0.0.0', port=3839, launch.browser = FALSE)" &
Rscript -e "setwd('/app/apps/proto-mechanism-explorer'); shiny::runApp('.', host='0.0.0.0', port=3840, launch.browser = FALSE)" &

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
