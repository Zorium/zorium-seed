# REPLACE_ENV_* is replaced at run-time with * environment variable when
# starting production server. This is necessary to avoid re-building at run-time

env = process.env
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

   # Dev only
  MOCK: process.env.MOCK is '1'

  # Server only - Avoid webpack include
  PORT: env.PORT or 3000
  WEBPACK_DEV_HOSTNAME: env.WEBPACK_DEV_HOSTNAME or 'localhost'
  WEBPACK_DEV_PORT: env.WEBPACK_DEV_PORT or 3001
  HOSTNAME: env.HOSTNAME or 'localhost'
  REMOTE_SELENIUM: env.REMOTE_SELENIUM is '1'
  SELENIUM_BROWSER: env.SELENIUM_BROWSER or 'chrome'
  SAUCE_USERNAME: env.SAUCE_USERNAME
  SAUCE_ACCESS_KEY: env.SAUCE_ACCESS_KEY
