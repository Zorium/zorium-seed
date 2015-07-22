# REPLACE__* is replaced at run-time with * environment variable when
# starting production server. This is necessary to avoid re-building at run-time

HOST = process.env.HOST or REPLACE__HOST? and REPLACE__HOST or 'localhost'

hostToHostname = (host) ->
  host.split(':')[0]

module.exports =
  API_URL: process.env.API_URL or
           REPLACE__API_URL? and REPLACE__API_URL or
           "http://localhost:#{process.env.PORT or 3000}"
  ENV: process.env.NODE_ENV or
       REPLACE__NODE_ENV? and REPLACE__NODE_ENV or
       'production'
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'
  HOST: HOST
  HOSTNAME: hostToHostname(HOST)

  # Server only
  PORT: process.env.PORT or 3000
