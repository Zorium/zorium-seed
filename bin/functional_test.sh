#!/bin/sh
export NODE_ENV=development

node_modules/gulp/bin/gulp.js test:functional
