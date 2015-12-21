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
fs = require 'fs'

config = require './src/config'
gulpPaths = require './gulp_paths'
App = require './src/app'
Model = require './src/models'
CookieService = require './src/services/cookie'

MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS = 10886400000 # 18 weeks
HEALTHCHECK_TIMEOUT = 200

styles = if config.ENV is config.ENVS.PROD
  fs.readFileSync gulpPaths.dist + '/bundle.css', 'utf-8'
else
  null

bundlePath = if config.ENV is config.ENVS.PROD
  stats = JSON.parse \
    fs.readFileSync gulpPaths.dist + '/stats.json', 'utf-8'

  "/#{stats.hash}.bundle.js"
else
  null

app = express()
app.use compress()
app.use helmet.contentSecurityPolicy
  scriptSrc: [
    '\'self\''
    '\'unsafe-inline\''
    'www.google-analytics.com'
    if config.ENV is config.ENVS.DEV then config.WEBPACK_DEV_URL
  ]
  stylesSrc: [
    '\'unsafe-inline\''
    if config.ENV is config.ENVS.DEV then config.WEBPACK_DEV_URL
  ]
app.use helmet.xssFilter()
app.use helmet.frameguard()
app.use helmet.hsts
  # https://hstspreload.appspot.com/
  maxAge: MIN_TIME_REQUIRED_FOR_HSTS_GOOGLE_PRELOAD_MS
  includeSubDomains: true # include in Google Chrome
  preload: true # include in Google Chrome
  force: true
app.use helmet.noSniff()
app.disable 'x-powered-by'
app.use cookieParser()

app.use '/healthcheck', (req, res, next) ->
  Promise.all [
    Promise.cast(request(config.API_URL + '/ping'))
      .timeout HEALTHCHECK_TIMEOUT
      .reflect()
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

if config.ENV is config.ENVS.PROD
then app.use express.static(gulpPaths.dist, {maxAge: '4h'})
else app.use express.static(gulpPaths.build, {maxAge: '4h'})

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
  requests = new Rx.BehaviorSubject(req)
  serverData = {req, res, styles, bundlePath}
  z.renderToString new App({requests, model, serverData})
  .then (html) ->
    res.send '<!DOCTYPE html>' + html
  .catch (err) ->
    log.error
      event: 'error'
      error: err
    if err.html
      res.send '<!DOCTYPE html>' + err.html
    else
      next err

module.exports = app
