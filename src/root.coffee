require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
cookie = require 'cookie'
StackTrace = require 'stacktrace-js'
FastClick = require 'fastclick'

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
    StackTrace.fromError err
    .then (stack) ->
      stack.join('\n')
    .catch (parseError) ->
      console?.log parseError
      return err
    .then (trace) ->
      window.fetch config.API_URL + '/log',
        method: 'POST'
        headers:
          # Avoid CORS preflight
          'Content-Type': 'text/plain'
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
          key, value, CookieService.getCookieOpts()
    currentCookies = cookies

# FIXME: gross, also should be faster, also timeout is busted
isThunk = (tree) -> tree.component?
isZThunk = (tree) -> isThunk(tree) and tree.component?
timeout = 200
getZThunks = (tree) ->
  if isZThunk tree
    [tree]
  else
    _.flatten _.map tree.children, getZThunks

untilStable = (zthunk) ->
  state = zthunk.component.state

  new Promise (resolve, reject) ->
    setTimeout ->
      reject new Error "Timeout, request took longer than #{timeout}ms"
    , timeout

    onStable = if state? then state._subscribeOnStable else (cb) -> cb()
    onStable ->
      try
        children = getZThunks zthunk.render()
      catch err
        return reject err
      resolve Promise.all _.map children, untilStable
  .then -> zthunk

init = ->
  FastClick.attach document.body
  currentCookies = cookie.parse(document.cookie)
  cookieSubject = new Rx.BehaviorSubject currentCookies
  cookieSubject.subscribeOnNext setCookies(currentCookies)

  model = new Model({cookieSubject})
  router = z.router

  root = document.createElement 'div'
  root.className = 'zorium-root'
  router.init
    $$root: root

  requests = new Rx.ReplaySubject(1)
  $app = z new App({requests, model, router})
  router.use (req, res) ->
    requests.onNext {req, res}
    res.send $app
  router.go()

  (if model.wasCached() then untilStable($app) else Promise.resolve null)
  .catch -> null
  .then ->
    # TODO: explain that this prevents white flash, and maybe use reqAnimFrame
    setTimeout ->
      $$root = document.getElementById 'zorium-root'
      $$root.parentNode.replaceChild root, $$root

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
