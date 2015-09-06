rewire = require 'rewire'
b = require 'b-assert'
query = require 'vtree-query'

Red = rewire './index'

describe 'z-red', ->
  it 'goes to home page', (done) ->
    Red.__with__({
      'z.router.go': (path) ->
        b path, '/'
        done()
    }) ->
      $hello = new Red()

      $hello.goToHome()

  it 'says hello world', ->
    $hello = new Red()

    $ = query($hello.render())
    b $('.content').contents, 'Hello World'
