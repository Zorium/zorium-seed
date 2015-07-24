should = require('chai').should()
query = require 'vtree-query'

RedPage = require './index'
Model = require '../../models'

describe 'red page', ->
  it 'sets the title', ->
    $page = new RedPage({model: new Model({})})

    $ = query $page.renderHead({})
    $('head title').contents.should.eql 'Zorium Seed - Red Page'

  it 'renders', ->
    $page = new RedPage({model: new Model({})})

    $page.render()
