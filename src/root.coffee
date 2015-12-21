require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'
cookie = require 'cookie'
StackTrace = require 'stacktrace-js'
FastClick = require 'fastclick'
Qs = require 'qs'

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

getCurrentUrl = (mode) ->
  hash = window.location.hash.slice(1)
  pathname = window.location.pathname
  search = window.location.search
  if pathname
    pathname += search

  return if mode is 'pathname' then pathname or hash \
         else hash or pathname

parseUrl = (url) ->
  a = document.createElement 'a'
  a.href = url

  {
    pathname: a.pathname
    hash: a.hash
    search: a.search
    path: a.pathname + a.search
  }

class Router
  constructor: ->
    @mode = if window.history?.pushState then 'pathname' else 'hash'
    @hasRouted = false
    @subject = new Rx.BehaviorSubject(@_parse())

    # some browsers erroneously call popstate on intial page load (iOS Safari)
    # We need to ignore that first event.
    # https://code.google.com/p/chromium/issues/detail?id=63040
    window.addEventListener 'popstate', =>
      if @hasRouted
        setTimeout =>
          @subject.onNext @_parse()

  getStream: => @subject

  _parse: (url) =>
    url ?= getCurrentUrl(@mode)
    {pathname, search} = parseUrl url
    query = Qs.parse(search?.slice(1))

    {url, path: pathname, query}

  go: (url) =>
    req = @_parse url

    if @mode is 'pathname'
      window.history.pushState null, null, req.url
    else
      window.location.hash = req.url

    @hasRouted = true
    @subject.onNext req

init = ->
  FastClick.attach document.body
  currentCookies = cookie.parse(document.cookie)
  cookieSubject = new Rx.BehaviorSubject currentCookies
  cookieSubject.subscribeOnNext setCookies(currentCookies)

  model = new Model({cookieSubject})
  router = new Router()

  root = document.createElement 'div'
  root.className = 'zorium-root'
  requests = router.getStream()
  $app = z new App({requests, model, router})
  z.bind root, $app

  (if model.wasCached() \
    then z.untilStable($app, {timeout: 200})
    else Promise.resolve null
  ).catch -> null
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
