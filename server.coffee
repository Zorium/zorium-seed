express = require 'express'
_ = require 'lodash'
compress = require 'compression'
log = require 'clay-loglevel'
helmet = require 'helmet'
z = require 'zorium'

config = require './src/config'
routes = require './src/routes'

MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS = 10886400000 # 18 weeks

app = express()
router = express.Router()

log.enableAll()

app.use compress()

webpackDevHost = config.WEBPACK_DEV_HOSTNAME + ':' + config.WEBPACK_DEV_PORT
scriptSrc = [
  '\'unsafe-eval\''
  '\'unsafe-inline\''
  'www.google-analytics.com'
  if config.ENV is config.ENVS.DEV then webpackDevHost
]
stylesSrc = [
  '\'unsafe-inline\''
  if config.ENV is config.ENVS.DEV then webpackDevHost
]
app.use helmet.contentSecurityPolicy
  scriptSrc: scriptSrc
  stylesSrc: stylesSrc
app.use helmet.xssFilter()
app.use helmet.frameguard()
app.use helmet.hsts
  # https://hstspreload.appspot.com/
  maxAge: MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS
  includeSubdomains: true # include in Google Chrome
  preload: true # include in Google Chrome
  force: true
app.use helmet.noSniff()
app.use helmet.crossdomain()
app.disable 'x-powered-by'

if config.ENV is config.ENVS.PROD
then app.use express['static'](__dirname + '/dist')
else app.use express['static'](__dirname + '/build')

app.use z.routerToMiddleware routes
app.use router

module.exports = app
