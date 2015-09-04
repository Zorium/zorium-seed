should = require('chai').should()
query = require 'vtree-query'

FourOhFourPage = require './index'

describe '404 page', ->
  it 'renders', ->
    $ = query FourOhFourPage.prototype.render()
    $('.').className.should.eql 'p-404'
