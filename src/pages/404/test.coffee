should = require('chai').should()
query = require 'vtree-query'

FourOhFourPage = require './index'
Model = require '../../models'

describe '404 page', ->
  it 'has default title', ->
    $page = new FourOhFourPage({model: new Model({})})

    $ = query $page.renderHead({})
    $('head title').contents.should.eql 'Zorium Seed - 404'

  it 'renders', ->
    $page = new FourOhFourPage({model: new Model({})})

    $page.render()
