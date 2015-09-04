Netox = require 'netox'

Example = require './example'
User = require './user'

module.exports = class Model
  constructor: ({cookieSubject, serverHeaders}) ->
    @netox = new Netox {headers: serverHeaders}
    @example = new Example()
    @user = new User({cookieSubject, @netox})
