express = require 'express'
_ = require 'lodash'
compress = require 'compression'
log = require 'loga'
helmet = require 'helmet'
z = require 'zorium'
Promise = require 'bluebird'
request = require 'clay-request'
Rx = require 'rx-lite'
cookieParser = require 'cookie-parser'

config = require './src/config'
gulpConfig = require './gulp_config'
App = require './src/app'
Model = require './src/models'
CookieService = require './src/services/cookie'

MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS = 10886400000 # 18 weeks
HEALTHCHECK_TIMEOUT = 200

app = express()
router = express.Router()

app.use compress()

webpackDevHost = "#{gulpConfig.WEBPACK_DEV_HOSTNAME}:" +
                 "#{gulpConfig.WEBPACK_DEV_PORT}"
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
app.use cookieParser()

app.use '/healthcheck', (req, res, next) ->
  Promise.settle [
    Promise.cast(request(config.API_URL + '/ping'))
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

# TODO: remove demo routes
# BEGIN DEMO ROUTES
demoDB = {}
app.get '/demo', (req, res) ->
  res.json {name: 'Zorium'}

app.get '/demo/users/me', (req, res) ->
  authHeader = req.header('Authorization') or ''
  [authScheme, accessToken] = authHeader.split(' ')

  unless demoDB[accessToken]
    return res.status(401).send()

  res.json demoDB[accessToken]

app.post '/demo/users/me', (req, res) ->
  authHeader = req.header('Authorization') or ''
  [authScheme, accessToken] = authHeader.split(' ')

  if demoDB[accessToken]
    return res.json demoDB[accessToken]

  id = _.keys(demoDB).length
  user = {
    id: id
    username: "test_#{id}"
    accessToken: "#{id}_#{Math.random().toFixed(10)}"
  }

  res.json demoDB[user.accessToken] = user
# END DEMO ROUTES

if config.ENV is config.ENVS.PROD
then app.use express.static(gulpConfig.paths.dist, {maxAge: '4h'})
else app.use express.static(gulpConfig.paths.build, {maxAge: '4h'})

app.use router
app.use (req, res, next) ->
  setCookies = (currentCookies) ->
    (cookies) ->
      _.map cookies, (value, key) ->
        unless currentCookies[key] is value
          res.cookie(key, value, CookieService.getCookieOpts())
      currentCookies = cookies

  cookieSubject = new Rx.BehaviorSubject req.cookies
  cookieSubject.subscribeOnNext setCookies(req.cookies)

  model = new Model({cookieSubject, serverHeaders: req.headers})

  z.renderToString new App({requests: Rx.Observable.just({req, res}), model})
  .then (html) ->
    res.send '<!DOCTYPE html>' + html
  .catch (err) ->
    if err.html
      log.error err
      res.send '<!DOCTYPE html>' + err.html
    else
      next err

module.exports = app
