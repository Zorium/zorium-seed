#!/bin/sh
export NODE_ENV=test

docker run -i --rm -p 4444:4444 selenium/standalone-chrome:2.47.1 >> /dev/null &

node_modules/gulp/bin/gulp.js watch:functional
