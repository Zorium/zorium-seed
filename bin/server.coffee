#!/usr/bin/env coffee
_ = require 'lodash'
log = require 'loga'
cluster = require 'cluster'
os = require 'os'

app = require '../server'
config = require '../src/config'

if cluster.isMaster
  _.map _.range(os.cpus().length), ->
    cluster.fork()

  cluster.on 'exit', (worker) ->
    log "Worker #{worker.id} died, respawning"
    cluster.fork()
else
  app.listen config.PORT, ->
    log.info 'Worker %d, listening on port %d', cluster.worker.id, config.PORT
