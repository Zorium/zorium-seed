#!/usr/bin/env coffee
log = require 'loga'

app = require '../server'
config = require '../src/config'

app.all '/*', (req, res, next) ->
  res.header(
    'Access-Control-Allow-Origin', config.WEBPACK_DEV_URL
  )
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
  next()

app.listen config.PORT, ->
  log.info 'Listening on port %d', config.PORT
