express = require 'express'
_ = require 'lodash'
compress = require 'compression'
log = require 'clay-loglevel'
helmet = require 'helmet'
z = require 'zorium'
Promise = require 'bluebird'
request = require 'request-promise'

config = require './src/config'
rootFactory = require './src/root_factory'

MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS = 10886400000 # 18 weeks
HEALTHCHECK_TIMEOUT = 200

app = express()
router = express.Router()

log.enableAll()

app.use compress()

webpackDevHost = config.WEBPACK_DEV_HOSTNAME + ':' + config.WEBPACK_DEV_PORT
scriptSrc = [
  '\'self\''
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

app.use '/healthcheck', (req, res, next) ->
  Promise.settle [
    Promise.cast(request.get(config.API_URL + '/ping'))
      .timeout HEALTHCHECK_TIMEOUT
  ]
  .spread (api) ->
    result =
      api: api.isFulfilled()

    isHealthy = _.every _.values result
    if isHealthy
      res.json {healthy: isHealthy}
    else
      res.status(500).json _.defaults {healthy: isHealthy}, result
  .catch next

app.use '/ping', (req, res) ->
  res.send 'pong'

app.use '/demo', (req, res) ->
  res.json {name: 'Zorium'}

if config.ENV is config.ENVS.PROD
then app.use express['static'](__dirname + '/dist')
else app.use express['static'](__dirname + '/build')

app.use router
app.use z.server.factoryToMiddleware rootFactory

module.exports = app
