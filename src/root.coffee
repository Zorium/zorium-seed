require './polyfill'

_ = require 'lodash'
z = require 'zorium'
log = require 'clay-loglevel'

require './root.styl'
config = require './config'
ErrorReportService = require './services/error_report'
rootFactory = require './root_factory'

###########
# LOGGING #
###########

window.addEventListener 'error', ErrorReportService.report

if config.ENV isnt config.ENVS.PROD
  log.enableAll()
else
  log.setLevel 'error'
  log.on 'error', ErrorReportService.report
  log.on 'trace', ErrorReportService.report


#################
# ROUTING SETUP #
#################

z.server.set
  $$root: document
  factory: rootFactory
z.server.go()

log.info 'App Ready'

#############################
# ENABLE WEBPACK HOT RELOAD #
#############################

if module.hot
  module.hot.accept()
