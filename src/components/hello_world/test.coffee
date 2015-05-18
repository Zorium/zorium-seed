rewire = require 'rewire'
should = require('clay-chai').should()

HelloWorld = rewire './index'

describe 'HelloWorld', ->
  it 'goes to red page', (done) ->
    HelloWorld.__with__({
      'z.router.go': (path) ->
        path.should.be '/red'
        done()
    }) ->
      $hello = new HelloWorld()

      $hello.goToRed()
