Rx = require 'rx-lite'
rewire = require 'rewire'
should = require('chai').should()
query = require 'vtree-query'

HelloWorld = rewire './index'

mockModel =
  user:
    getMe: -> Rx.Observable.just null

describe 'z-hello-world', ->
  it 'goes to red page', (done) ->
    HelloWorld.__with__({
      'z.router.go': (path) ->
        path.should.eql '/red'
        done()
    }) ->
      $hello = new HelloWorld({model: mockModel})

      $hello.goToRed()

  it 'says Hello World', ->
    $hello = new HelloWorld({model: mockModel})

    $ = query($hello.render())
    $('.hello').contents.should.eql 'Hello World'
