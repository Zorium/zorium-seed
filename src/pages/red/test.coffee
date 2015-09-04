should = require('chai').should()
query = require 'vtree-query'

RedPage = require './index'
Model = require '../../models'

describe 'red page', ->
  it 'renders', ->
    $ = query RedPage.prototype.render()
    $('.').className.should.eql 'p-red'
