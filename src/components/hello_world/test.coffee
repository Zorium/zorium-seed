Rx = require 'rx-lite'
rewire = require 'rewire'
b = require 'b-assert'
query = require 'vtree-query'

HelloWorld = rewire './index'

mockModel =
  example:
    getCount: -> Rx.Observable.just null
  user:
    getMe: -> Rx.Observable.just null

describe 'z-hello-world', ->
  it 'goes to red page', (done) ->
    HelloWorld.__with__({
      'z.router.go': (path) ->
        b path, '/red'
        done()
    }) ->
      $hello = new HelloWorld({model: mockModel})

      $hello.goToRed()

  it 'says Hello World', ->
    $hello = new HelloWorld({model: mockModel})

    $ = query($hello.render())
    b $('.hello').contents, 'Hello World'
