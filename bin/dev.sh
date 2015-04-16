#!/bin/sh
[ -z "$NODE_ENV" ] && export NODE_ENV=development
[ -z "$MOCK" ] && export MOCK=0

node_modules/gulp/bin/gulp.js dev
