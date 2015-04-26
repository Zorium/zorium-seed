_ = require 'lodash'
should = require('clay-chai').should()
request = require 'request-promise'
Promise = require 'bluebird'
revision = require 'git-rev'

config = require '../../src/config'
Client = require './client'

APP_URL = "http://#{config.HOSTNAME}:#{config.PORT}"
WEBPACK_URL = "http://#{config.WEBPACK_DEV_HOSTNAME}:#{config.WEBPACK_DEV_PORT}"

build = null

# Race!
revision.short (str) ->
  build = str

# Wait for server to be up
# coffeelint: disable=missing_fat_arrows
before ->
  @timeout 90 * 1000 # 90sec
  check = ->
    request.get APP_URL
    .then ->
      request.get WEBPACK_URL
    .catch check

  # race condition for server-reload
  Promise.delay 1000
  .then check
  .then ->
    Client.init()

after ->
  Client
    .sauceJobStatus
      passed: _.every this.test.parent.tests, {state: 'passed'}
      public: 'public'
      build: build
    .end()
# coffeelint: enable=missing_fat_arrows

describe 'functional tests', ->
  client = Client

  before ->
    client = client
      .url APP_URL
      .pause(100) # don't question it

  it 'checks title', ->
    client
      .getTitle()
      .then (title) ->
        title.should.be 'Zorium Seed'

  it 'checks root node', ->
    client
      .isVisible '#zorium-root'
      .then (isVisible) ->
        isVisible.should.be true
