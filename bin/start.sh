#!/bin/sh
[ -z "$LOG_DIR" ] && export LOG_DIR=/tmp/zorium_seed
[ -z "$LOG_NAME" ] && export LOG_NAME=zorium_seed
export NODE_ENV=production

mkdir -p $LOG_DIR && ./node_modules/gulp/bin/gulp.js build 2>&1 | tee $LOG_DIR/$LOG_NAME.build.log

./node_modules/pm2/bin/pm2 \
  start ./bin/server.coffee \
  -i 0 \
  --name $LOG_NAME \
  --merge-logs \
  --no-daemon \
  -o $LOG_DIR/$LOG_NAME.log \
  -e $LOG_DIR/$LOG_NAME.error.log \
  2>&1 | tee $LOG_DIR/$LOG_NAME.pm2.log
