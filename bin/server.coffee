#!/usr/bin/env coffee
log = require 'loga'

app = require '../server'
config = require '../src/config'

app.listen config.PORT, ->
  log.info 'Listening on port %d', config.PORT
