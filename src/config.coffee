# REPLACE_ENV_* is replaced at run-time with * environment variable when
# starting production server. This is necessary to avoid re-building at run-time

HOST = process.env.HOST or REPLACE_ENV_HOST? and REPLACE_ENV_HOST or 'localhost'

env = process.env

hostToHostname = (host) ->
  host.split(':')[0]

module.exports =
  API_URL: process.env.API_URL or
           REPLACE_ENV_API_URL? and REPLACE_ENV_API_URL or
           "http://localhost:#{process.env.PORT or 3000}"
  ENV: process.env.NODE_ENV or
       REPLACE_ENV_NODE_ENV? and REPLACE_ENV_NODE_ENV or
       'production'
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'
  HOSTNAME: hostToHostname(HOST)

  # Server only - Avoid webpack include
  PORT: env.PORT or 3000
