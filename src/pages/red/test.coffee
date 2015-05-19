should = require('clay-chai').should()
query = require 'vtree-query'

RedPage = require './index'

describe 'red page', ->
  it 'sets the title', ->
    $page = new RedPage()

    $ = query $page.renderHead({})
    $('head title').contents.should.be 'Zorium Seed - Red Page'

  it 'renders', ->
    $page = new RedPage()

    $page.render()
