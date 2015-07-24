Example = require './example'
User = require './user'

module.exports = class Model
  constructor: ({cookieSubject, proxy}) ->
    @example = new Example()
    @user = new User({cookieSubject, proxy})
