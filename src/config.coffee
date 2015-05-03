module.exports =
  API_URL: process.env.API_URL or "http://localhost:#{process.env.PORT or 3000}"
  PORT: process.env.PORT or 3000
  WEBPACK_DEV_HOSTNAME: process.env.WEBPACK_DEV_HOSTNAME or 'localhost'
  WEBPACK_DEV_PORT: process.env.WEBPACK_DEV_PORT or 3001
  MOCK: process.env.MOCK is '1'
  ENV: process.env.NODE_ENV or 'production'
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'
  HOSTNAME: process.env.HOSTNAME or 'localhost'
  REMOTE_SELENIUM: process.env.REMOTE_SELENIUM is '1'
  SELENIUM_BROWSER: process.env.SELENIUM_BROWSER or 'chrome'
  SAUCE_USERNAME: process.env.SAUCE_USERNAME
  SAUCE_ACCESS_KEY: process.env.SAUCE_ACCESS_KEY
