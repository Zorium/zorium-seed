require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
cookie = require 'cookie'
StackTrace = require 'stacktrace-js'
FastClick = require 'fastclick'
LocationRouter = require 'location-router'

require './root.styl'

config = require './config'
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
    StackTrace.fromError err
    .then (stack) ->
      stack.join('\n')
    .catch (parseError) ->
      console?.log parseError
      return err
    .then (trace) ->
      window.fetch '/log',
        method: 'POST'
        headers:
          'Content-Type': 'application/json'
        body: JSON.stringify
          event: 'client_error'
          trace: trace
          error: String(err)
    .catch (err) ->
      console?.log err
  catch err
    console?.log err

# Note: window.onerror != window.addEventListener('error')
oldOnError = window.onerror
window.onerror = (message, file, line, column, error) ->
  log.error error or new Error message
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
          key, value, {
            path: '/'
            expires: new Date(Date.now() + config.COOKIE_DURATION_MS)
          }
    currentCookies = cookies

init = ->
  FastClick.attach document.body
  currentCookies = cookie.parse(document.cookie)
  cookieSubject = new Rx.BehaviorSubject currentCookies
  cookieSubject.subscribeOnNext setCookies(currentCookies)

  router = new LocationRouter()
  model = new Model({cookieSubject})

  root = document.createElement 'div'
  requests = router.getStream()
  $app = z new App({requests, model, router})
  z.bind root, $app

  (if model.wasCached() \
    then z.untilStable($app, {timeout: 200}) # arbitrary
    else Promise.resolve null
  ).catch -> null
  .then ->
    # nextTick prevents white flash
    setTimeout ->
      $$root = document.getElementById 'zorium-root'
      $$root.parentNode.replaceChild root, $$root

if document.readyState isnt 'complete' and
    not document.getElementById 'zorium-root'
  window.addEventListener 'load', init
else
  init()

#############################
# SERVICE WORKERS           #
#############################

if location.protocol is 'https:'
  navigator.serviceWorker?.register '/service_worker.js'
  .catch log.error

#############################
# ENABLE WEBPACK HOT RELOAD #
#############################

if module.hot
  module.hot.accept()
