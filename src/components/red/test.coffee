b = require 'b-assert'
query = require 'vtree-query'

Red = require './index'

describe 'z-red', ->
  it 'goes to home page', (done) ->
    Red::goToHome
      go: (path) ->
        b path, '/'
        done()

  it 'says hello world', ->
    $ = query Red::render()

    b $('.content').contents, 'Hello World'
