#!/bin/bash
export NODE_ENV=development
export REMOTE_SELENIUM=1


declare -a browsers=("chrome" "firefox" "safari" "internet explorer" "android")

for i in "${browsers[@]}"
do
  SELENIUM_BROWSER="$i" node_modules/gulp/bin/gulp.js test:functional
done
