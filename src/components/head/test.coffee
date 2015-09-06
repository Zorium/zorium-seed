_ = require 'lodash'
query = require 'vtree-query'
rewire = require 'rewire'
b = require 'b-assert'
Netox = require 'netox'

Head = rewire './index'

mockModel =
  netox: new Netox()

describe 'z-head', ->
  it 'renders title', ->
    $head = new Head({model: mockModel})
    $ = query $head.render {title: 'test_title'}

    b $('title').contents, 'test_title'

  it 'has viewport meta', ->
    $head = new Head({model: mockModel})
    $ = query $head.render({})

    b $('meta[name=viewport]')?

  it 'inlines styles in production mode', ->
    config = Head.__get__('config')
    Head.__with__({
      config: _.defaults {
        ENV: config.ENVS.PROD
      }, config
    }) ->
      $head = new Head({model: mockModel})
      $ = query $head.render({styles: 'xxx'})
      b $('.styles').innerHTML, 'xxx'

  it 'uses bundle path in production mode', ->
    config = Head.__get__('config')
    Head.__with__({
      config: _.defaults {
        ENV: config.ENVS.PROD
      }, config
    }) ->
      $head = new Head({model: mockModel})
      $ = query $head.render({bundlePath: 'xxx'})
      b $('.bundle').src, 'xxx'
