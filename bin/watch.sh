#!/bin/sh
export NODE_ENV=test
export NODE_PATH=./src

node_modules/gulp/bin/gulp.js watch
