require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'clay-loglevel'

require './root.styl'
config = require './config'
ErrorReportService = require './services/error_report'
App = require './app'

###########
# LOGGING #
###########

# TODO: Configure ErrorReportService before usage
# window.addEventListener 'error', ErrorReportService.report

if config.ENV isnt config.ENVS.PROD
  log.enableAll()
else
  log.setLevel 'error'
  # TODO: Configure ErrorReportService before usage
  # log.on 'error', ErrorReportService.report
  # log.on 'trace', ErrorReportService.report


#################
# ROUTING SETUP #
#################

init = ->
  z.router.init
    $$root: document.getElementById 'zorium-root'

  $app = new App()
  z.router.use (req, res) ->
    res.send z $app, {req, res}
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
