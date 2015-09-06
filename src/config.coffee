# REPLACE__* is replaced at run-time with * environment variable when
# starting production server. This is necessary to avoid re-building at run-time
_ = require 'lodash'
assertNoneMissing = require 'assert-none-missing'

HOST = process.env.HOST or REPLACE__HOST? and REPLACE__HOST or '127.0.0.1'

env = process.env

hostToHostname = (host) ->
  host.split(':')[0]

isomorphic =
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

server =
  # Server only
  PORT: env.PORT or 3000

  # Development
  WEBPACK_DEV_HOSTNAME: env.WEBPACK_DEV_HOSTNAME or 'localhost'
  WEBPACK_DEV_PORT: env.WEBPACK_DEV_PORT or 3001
  REMOTE_SELENIUM: env.REMOTE_SELENIUM is '1'
  SELENIUM_BROWSER: env.SELENIUM_BROWSER or 'chrome'
  SAUCE_USERNAME: env.SAUCE_USERNAME
  SAUCE_ACCESS_KEY: env.SAUCE_ACCESS_KEY

config = _.merge isomorphic, server

if window?
  assertNoneMissing isomorphic
else
  assertNoneMissing config

module.exports = config
