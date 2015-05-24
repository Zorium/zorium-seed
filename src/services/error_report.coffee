config = require '../config'

# Report client-side errors to a server-side logging route
# To configure, simply set a valid ERROR_REPORT_ENDPOINT

ERROR_REPORT_ENDPOINT = config.API_URL + '/log' # stub

# FIXME: Move this into a node module as a loglevel plugin
class ErrorReportService
  report: ->
    # Remove the circular dependency within error objects
    args = _.map arguments, (arg) ->

      if arg instanceof Error and arg.stack
      then arg.stack
      else if arg instanceof Error
      then arg.message
      else if arg instanceof ErrorEvent and arg.error
      then arg.error.stack
      else if arg instanceof ErrorEvent
      then arg.message
      else arg

    window.fetch ERROR_REPORT_ENDPOINT,
      method: 'POST'
      headers:
        'Accept': 'application/json'
        'Content-Type': 'application/json'
      body:
        JSON.stringify message: args.join ' '
    .catch (err) ->
      console?.error err

module.exports = new ErrorReportService()
