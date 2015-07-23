Example = require './example'

module.exports = class Model
  constructor: ({cookieSubject, proxy}) ->
    @example = new Example()
