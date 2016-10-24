#!/usr/bin/env coffee
_ = require 'lodash'
log = require 'loga'
cluster = require 'cluster'
os = require 'os'

app = require './index'
config = require '../config'

if config.ENV is config.ENVS.PROD and cluster.isMaster
  _.map _.range(os.cpus().length), ->
    cluster.fork()

  cluster.on 'exit', (worker) ->
    log.warn
      event: 'cluster_respawn'
      message: "Worker #{worker.id} died, respawning"
    cluster.fork()
else
  app.listen config.PORT, ->
    log.info
      event: 'cluster_fork'
      message:
        "Worker #{cluster.worker?.id or 0}, listening on port #{config.PORT}"
