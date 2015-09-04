_ = require 'lodash'
Netox = require 'netox'

Auth = require './auth'
User = require './user'
Example = require './example'
config = require '../config'

module.exports = class Model
  constructor: ({cookieSubject, serverHeaders}) ->
    @netox = new Netox {headers: serverHeaders}
    @auth = new Auth({@netox, cookieSubject})
    @user = new User({@auth})
    @example = new Example({@auth})
