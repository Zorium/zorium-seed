should = require('clay-chai').should()
query = require 'vtree-query'

HomePage = require './index'

describe 'home page', ->
  it 'had default title', ->
    $page = new HomePage()

    $ = query $page.renderHead({})
    $('head title').contents.should.be 'Zorium Seed'

  it 'renders', ->
    $page = new HomePage()

    $page.render()
