_ = require 'lodash'
should = require('chai').should()
request = require 'clay-request'
Promise = require 'bluebird'
revision = require 'git-rev'

config = require '../../src/config'
gulpConfig = require '../../gulp_config'
Client = require './client'

APP_URL = "http://#{config.HOSTNAME}:#{config.PORT}"
WEBPACK_URL = "http://#{gulpConfig.WEBPACK_DEV_HOSTNAME}:" +
              "#{gulpConfig.WEBPACK_DEV_PORT}"

# Wait for server to be up
# coffeelint: disable=missing_fat_arrows
before ->
  @timeout 90 * 1000 # 90sec
  check = ->
    request APP_URL
    .then ->
      request WEBPACK_URL
    .catch check

  # race condition for server-reload
  Promise.delay 1000
  .then check
  .then ->
    Client.init()

after ->
  new Promise (resolve) ->
    revision.short resolve
  .then (build) =>
    Client
      .sauceJobStatus
        passed: _.every this.test.parent.tests, {state: 'passed'}
        public: 'public'
        build: build
      .end()
# coffeelint: enable=missing_fat_arrows

describe 'functional tests', ->
  client = null

  before ->
    client = Client
      .url APP_URL
      .pause(100) # don't question it

  it 'checks title', ->
    client
      .getTitle()
      .then (title) ->
        title.should.eql 'Zorium Seed'

  it 'checks root node', ->
    client
      .isVisible '#zorium-root'
      .then (isVisible) ->
        isVisible.should.eql true

  it 'navigates on button click', ->
    client
      .click '.p-home .z-hello-world button'
      .getTitle()
      .then (title) ->
        title.should.eql 'Zorium Seed - Red Page'
      .click '.p-red .z-red button'
      .getTitle()
      .then (title) ->
        title.should.eql 'Zorium Seed'
