should = require('chai').should()
query = require 'vtree-query'

HomePage = require './index'

describe 'home page', ->
  it 'renders', ->
    $ = query HomePage.prototype.render()
    $('.').className.should.eql 'p-home'
