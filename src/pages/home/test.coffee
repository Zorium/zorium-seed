should = require('chai').should()
query = require 'vtree-query'

HomePage = require './index'
Model = require '../../models'

describe 'home page', ->
  it 'has default title', ->
    $page = new HomePage({model: new Model({})})

    $ = query $page.renderHead({})
    $('head title').contents.should.eql 'Zorium Seed'

  it 'renders', ->
    $page = new HomePage({model: new Model({})})

    $page.render()
