_ = require 'lodash'
query = require 'vtree-query'
rewire = require 'rewire'
should = require('chai').should()
Netox = require 'netox'

Head = rewire './index'

mockModel =
  netox: new Netox()

describe 'z-head', ->
  it 'renders title', ->
    $head = new Head({model: mockModel})
    $ = query $head.render {title: 'test_title'}

    $('title').contents.should.eql 'test_title'

  it 'has viewport meta', ->
    $head = new Head({model: mockModel})
    $ = query $head.render({})

    should.exist $('meta[name=viewport]')

  it 'inlines styles in production mode', ->
    config = Head.__get__('config')
    Head.__with__({
      config: _.defaults {
        ENV: config.ENVS.PROD
      }, config
    }) ->
      $head = new Head({model: mockModel})
      $ = query $head.render({styles: 'xxx'})
      $('.styles').innerHTML.should.eql 'xxx'

  it 'uses bundle path in production mode', ->
    config = Head.__get__('config')
    Head.__with__({
      config: _.defaults {
        ENV: config.ENVS.PROD
      }, config
    }) ->
      $head = new Head({model: mockModel})
      $ = query $head.render({bundlePath: 'xxx'})
      $('.bundle').src.should.eql 'xxx'
