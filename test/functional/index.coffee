webdriverio = require 'webdriverio'
should = require('clay-chai').should()
request = require 'request-promise'

config = require '../../src/config'

APP_URL = "http://localhost:#{config.PORT}"
WEBPACK_URL = "http://#{config.WEBPACK_DEV_HOSTNAME}:#{config.WEBPACK_DEV_PORT}"

options =
  desiredCapabilities:
    browserName: 'chrome'

client = webdriverio.remote options

# Wait for server to be up
# coffeelint: disable=missing_fat_arrows
before ->
  @timeout 30000
  check = ->
    request.get APP_URL
    .then ->
      request.get WEBPACK_URL
    .catch check

  check()
# coffeelint: enable=missing_fat_arrows

describe 'functional tests', ->
  it 'checks google', ->
    client
      .init()
      .url APP_URL
      .getTitle()
        .then (title) ->
          title.should.be 'Zorium Seed'
      .pause(1000)
      .end()
