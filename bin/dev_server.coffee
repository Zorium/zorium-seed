#!/usr/bin/env coffee
log = require 'clay-loglevel'

app = require '../server'
config = require '../src/config'

webpackDevPort = config.WEBPACK_DEV_PORT
webpackDevHostname = config.WEBPACK_DEV_HOSTNAME

app.all '/*', (req, res, next) ->
  res.header(
    'Access-Control-Allow-Origin', "//#{webpackDevHostname}:#{webpackDevPort}"
  )
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
  next()

app.listen config.PORT, ->
  log.info 'Listening on port %d', config.PORT
