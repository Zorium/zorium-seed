#!/bin/bash
[ -z "$LOG_DIR" ] && export LOG_DIR=/tmp/zorium_seed
[ -z "$LOG_NAME" ] && export LOG_NAME=zorium_seed
export NODE_ENV=production

mkdir -p $LOG_DIR

paths_dist=`./node_modules/coffee-script/bin/coffee -e "process.stdout.write require('./gulp_config').paths.dist"`

if [ ! -d $paths_dist ]; then
  echo "./dist directory not found. make sure to run 'npm run dist' beforehand" | tee $LOG_DIR/$LOG_NAME.build.log
  exit 1
fi

if [ -d "$paths_dist/backup" ]; then
  # Restore js from previous build
  echo "restoring backup dist files" | tee $LOG_DIR/$LOG_NAME.build.log
  cp $paths_dist/backup/*.js $paths_dist/

else
  # Backup js files before replacing
  mkdir -p $paths_dist/backup
  echo "backing up js files before replacing env" | tee $LOG_DIR/$LOG_NAME.build.log
  cp $paths_dist/*.js $paths_dist/backup/
fi

# Replace REPLACE_ENV_* with environment variable
while read -d $'\0' -r file; do
  echo "replacing environment variables in $file" | tee $LOG_DIR/$LOG_NAME.build.log
  while read line; do
    if [[ $line =~ REPLACE_ENV_([A-Z0-9_]+) ]]; then
      env_name="${BASH_REMATCH[1]}"
      env_value=$(echo $(eval "echo \$$env_name") | sed -e 's/[\/&]/\\&/g')
      echo "replacing $env_name with '$env_value'" | tee $LOG_DIR/$LOG_NAME.build.log
      sed -i s/REPLACE_ENV_$env_name/\"$env_value\"/g $file
    fi
  done < <(grep -o "REPLACE_ENV_[A-Z0-9_]\+" $file | uniq)
done < <(find $paths_dist -maxdepth 1 -iname '*.bundle.js' -print0)

./node_modules/pm2/bin/pm2 \
  start ./bin/server.coffee \
  -i 0 \
  --name $LOG_NAME \
  --merge-logs \
  --no-daemon \
  -o $LOG_DIR/$LOG_NAME.log \
  -e $LOG_DIR/$LOG_NAME.error.log \
  2>&1 | tee $LOG_DIR/$LOG_NAME.pm2.log
