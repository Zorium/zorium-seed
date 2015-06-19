require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'loglevel'
Rx = require 'rx-lite'

require './root.styl'
config = require './config'
ErrorReportService = require './services/error_report'
App = require './app'

###########
# LOGGING #
###########

if config.ENV isnt config.ENVS.PROD
  log.enableAll()
else
  # TODO: Configure ErrorReportService before usage
  # originalFactory = log.methodFactory
  # log.methodFactory = (methodName, logLevel) ->
  #   rawMethod = originalFactory(methodName, logLevel)
  #   (args...) ->
  #     ErrorReportService.report args...
  #     return rawMethod args...
  log.setLevel 'warn' # Note: required to apply plugin

# Note: window.onerror != window.addEventListener('error')
oldOnError = window.onerror
window.onerror = (message, file, line, column, error) ->
  log.error error or message
  if oldOnError
    return oldOnError arguments...

#################
# ROUTING SETUP #
#################

init = ->
  z.router.init
    $$root: document.getElementById 'zorium-root'

  requests = new Rx.ReplaySubject(1)
  $app = new App({requests})
  z.router.use (req, res) ->
    requests.onNext {req, res}
    res.send $app
  z.router.go()

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
