_ = require 'lodash'
b = require 'b-assert'
request = require 'clay-request'
Promise = require 'bluebird'
revision = require 'git-rev'
url = require 'url'

config = require '../../src/config'
Client = require './client'

APP_URL = "http://#{config.HOSTNAME}:#{config.PORT}"
WEBPACK_URL = "http://#{config.WEBPACK_DEV_HOSTNAME}:" +
              "#{config.WEBPACK_DEV_PORT}"

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
        b title, 'Zorium Seed'

  it 'checks root node', ->
    client
      .isVisible '#zorium-root'
      .then (isVisible) ->
        b isVisible, true

  it 'navigates on button click', ->
    client
      .click '.p-home .z-hello-world button'
      .url()
      .then ({value}) ->
        b url.parse(value).pathname, '/red'
      .waitForVisible '.p-red .z-red button'
      .click '.p-red .z-red button'
      .url()
      .then ({value}) ->
        b url.parse(value).pathname, '/'
