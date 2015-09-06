b = require 'b-assert'
query = require 'vtree-query'

RedPage = require './index'
Model = require '../../models'

describe 'red page', ->
  it 'renders', ->
    $ = query RedPage.prototype.render()
    b $('.').className, 'p-red'
