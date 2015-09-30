#!/bin/sh
[ -z "$NODE_ENV" ] && export NODE_ENV=development
[ -z "$WEBPACK_DEV_PORT" ] && export WEBPACK_DEV_PORT=$(shuf -i 2000-65000 -n 1)

node_modules/gulp/bin/gulp.js dev
