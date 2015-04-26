#!/bin/bash
export NODE_ENV=development
export REMOTE_SELENIUM=1
trap "exit" INT # allow ctrl-c to exit

declare -a browsers=("chrome" "firefox" "safari" "internet explorer" "android")

for i in "${browsers[@]}"
do
  sl -e # allow ctrl-c to exit
  SELENIUM_BROWSER="$i" node_modules/gulp/bin/gulp.js test:functional
done
