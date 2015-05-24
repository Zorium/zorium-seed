should = require('chai').should()
query = require 'vtree-query'

FourOhFourPage = require './index'

describe 'home page', ->
  it 'had default title', ->
    $page = new FourOhFourPage()

    $ = query $page.renderHead({})
    $('head title').contents.should.eql 'Zorium Seed - 404'

  it 'renders', ->
    $page = new FourOhFourPage()

    $page.render()
