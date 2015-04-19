PORT = process.env.PORT or 3000

module.exports =
  API_URL: process.env.API_URL or 'http://localhost:' + PORT
  PORT: PORT
  WEBPACK_DEV_HOSTNAME: process.env.WEBPACK_DEV_HOSTNAME or 'localhost'
  WEBPACK_DEV_PORT: 3004
  MOCK: process.env.MOCK is '1'
  ENV: process.env.NODE_ENV or 'production'
  ENVS:
    DEV: 'development'
    PROD: 'production'
    TEST: 'test'
