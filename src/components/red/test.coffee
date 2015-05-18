rewire = require 'rewire'
should = require('clay-chai').should()

Red = rewire './index'

describe 'Red', ->
  it 'goes to home page', (done) ->
    Red.__with__({
      'z.router.go': (path) ->
        path.should.be '/'
        done()
    }) ->
      $hello = new Red()

      $hello.goToHome()
