_ = require 'lodash'
query = require 'vtree-query'
b = require 'b-assert'
config = require '../../config'

Head = require './index'

fakeMeta = {twitter: {}, openGraph: {}, ios: {}, kik: {}}

describe 'z-head', ->
  it 'renders title', ->
    $ = query Head::render.call {
      state: getValue: ->
        meta: _.merge
          title: 'test_title'
        , fakeMeta
    }, {}

    b $('title').contents, 'test_title'

  it 'has viewport meta', ->
    $ = query Head::render.call {
      state: getValue: -> {meta: fakeMeta}
    }, {}

    b $('meta[name=viewport]')?

  it 'inlines styles in production mode', ->
    oldEnv = config.ENV
    config.ENV = config.ENVS.PROD
    try
      $ = query Head::render.call {
        state: getValue: ->
          meta: fakeMeta
          serverData:
            styles: 'xxx'
      }
    finally
      config.ENV = oldEnv

    b $('.styles').innerHTML, 'xxx'


  it 'uses bundle path in production mode', ->
    oldEnv = config.ENV
    config.ENV = config.ENVS.PROD
    try
      $ = query Head::render.call {
        state: getValue: ->
          meta: fakeMeta
          serverData:
            bundlePath: 'xxx'
      }
    finally
      config.ENV = oldEnv

    b $('.bundle').src, 'xxx'
