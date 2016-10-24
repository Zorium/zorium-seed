#!/bin/bash
if [ ! -d dist ]; then
  echo "./dist directory not found. make sure to run 'npm run dist' beforehand"
  exit 1
fi

if [ -d "dist/backup" ]; then
  # Restore js from previous build
  echo "restoring backup dist files"
  cp dist/backup/*.js dist/
else
  # Backup js files before replacing
  mkdir -p dist/backup
  echo "backing up js files before replacing env"
  cp dist/*.js dist/backup/
fi

# Replace process.env.* with environment variable
while read -d $'\0' -r file; do
  echo "replacing environment variables in $file"
  while read line; do
    if [[ $line =~ process\.env\.([A-Z0-9_]+) ]]; then
      env_name="${BASH_REMATCH[1]}"
      env_string=$(echo $(eval "echo \$$env_name") | sed -e 's/[\/&]/\\&/g')
      if [ -z $env_string ]; then
        env_value="undefined"
      else
        env_value="'$env_string'"
      fi
      echo "replacing $env_name with $env_value"
      sed -i.bak s/process\.env\.$env_name/$env_value/g $file
    fi
  done < <(grep -o "process\.env\.[A-Z0-9_]\+" $file | uniq)
done < <(find dist -maxdepth 1 -iname '*.js' -print0)

./node_modules/coffee-script/bin/coffee ./src/server/start.coffee
