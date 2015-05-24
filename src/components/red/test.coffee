rewire = require 'rewire'
should = require('chai').should()
query = require 'vtree-query'

Red = rewire './index'

describe 'z-red', ->
  it 'goes to home page', (done) ->
    Red.__with__({
      'z.router.go': (path) ->
        path.should.eql '/'
        done()
    }) ->
      $hello = new Red()

      $hello.goToHome()

  it 'says hello world', ->
    $hello = new Red()

    $ = query($hello.render())
    $('.content').contents.should.eql 'Hello World'
