require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
cookie = require 'cookie'
StackTrace = require 'stacktrace-js'

require './root.styl'

config = require './config'
CookieService = require './services/cookie'
App = require './app'
Model = require './models'

###########
# LOGGING #
###########

if config.ENV is config.ENVS.PROD
  log.level = 'warn'

# Report errors to API_URL/log
log.on 'error', (err) ->
  try
    trace = StackTrace({e: err, guess: true}).join('\n')
    window.fetch config.API_URL + '/log',
      method: 'POST'
      headers:
        'Accept': 'application/json'
        'Content-Type': 'application/json'
      body: JSON.stringify
        trace: trace
        message: err?.message or String(err)
    .catch (err) ->
      console?.error err
  catch err
    console?.error err

# Note: window.onerror != window.addEventListener('error')
oldOnError = window.onerror
window.onerror = (message, file, line, column, error) ->
  log.error error or message
  if oldOnError
    return oldOnError arguments...

#################
# ROUTING SETUP #
#################
setCookies = (currentCookies) ->
  (cookies) ->
    _.map cookies, (value, key) ->
      unless currentCookies[key] is value
        document.cookie = cookie.serialize \
          key, value, CookieService.getCookieOpts()
    currentCookies = cookies

init = ->
  currentCookies = cookie.parse(document.cookie)
  cookieSubject = new Rx.BehaviorSubject currentCookies
  cookieSubject.subscribeOnNext setCookies(currentCookies)

  model = new Model({cookieSubject})
  router = z.router

  router.init
    $$root: document.getElementById 'zorium-root'

  requests = new Rx.ReplaySubject(1)
  $app = new App({requests, model, router})
  router.use (req, res) ->
    requests.onNext {req, res}
    res.send $app
  router.go()

if document.readyState isnt 'complete' and
    not document.getElementById 'zorium-root'
  window.addEventListener 'load', init
else
  init()

#############################
# ENABLE WEBPACK HOT RELOAD #
#############################

if module.hot
  module.hot.accept()
  init()
