Netox = require 'netox'

Example = require './example'
User = require './user'

module.exports = class Model
  constructor: ({cookieSubject, serverHeaders}) ->
    @netox = new Netox {headers: serverHeaders}
    @user = new User({cookieSubject, @netox})
    @example = new Example({@user, @netox})
