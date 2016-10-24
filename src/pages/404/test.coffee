b = require 'b-assert'
query = require 'vtree-query'

FourOhFourPage = require './index'

describe '404 page', ->
  it 'renders', ->
    $ = query FourOhFourPage::render()
    b $('.').className, 'p-404'
