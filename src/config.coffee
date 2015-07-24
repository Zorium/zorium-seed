# REPLACE__* is replaced at run-time with * environment variable when
# starting production server. This is necessary to avoid re-building at run-time
assertNoneMissing = require 'assert-none-missing'

HOST = process.env.HOST or REPLACE__HOST? and REPLACE__HOST or '127.0.0.1'

hostToHostname = (host) ->
  host.split(':')[0]

module.exports =
  API_URL: process.env.API_URL or
           REPLACE__API_URL? and REPLACE__API_URL or
           "http://127.0.0.1:#{process.env.PORT or 3000}"
  AUTH_COOKIE: 'accessToken'
  ENV: process.env.NODE_ENV or REPLACE__NODE_ENV
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'
  HOST: HOST
  HOSTNAME: hostToHostname(HOST)

  # Server only
  PORT: process.env.PORT or 3000

assertNoneMissing module.exports
