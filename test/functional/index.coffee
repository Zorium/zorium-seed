_ = require 'lodash'
webdriverio = require 'clay-webdriverio'
should = require('clay-chai').should()
request = require 'request-promise'
SauceLabs = require 'saucelabs'
Promise = require 'bluebird'
revision = require 'git-rev'

config = require '../../src/config'

APP_URL = "http://#{config.HOSTNAME}:#{config.PORT}"
WEBPACK_URL = "http://#{config.WEBPACK_DEV_HOSTNAME}:#{config.WEBPACK_DEV_PORT}"

build = null

# Race!
revision.short (str) ->
  build = str

client = if config.REMOTE_SELENIUM
  webdriverio.remote
    desiredCapabilities:
      browserName: config.SELENIUM_BROWSER
      name: 'Zorium Seed'
      tags: ['zorium_seed']
    host: 'ondemand.saucelabs.com'
    port: 80
    user: config.SAUCE_USERNAME
    key: config.SAUCE_ACCESS_KEY
else
  webdriverio.remote
    desiredCapabilities:
      browserName: config.SELENIUM_BROWSER

client.addCommand 'sauceJobStatus', (status) ->
  unless config.REMOTE_SELENIUM
    return

  sessionID = client.requestHandler.sessionID
  sauceAccount = new SauceLabs
    username: config.SAUCE_USERNAME
    password: config.SAUCE_ACCESS_KEY

  new Promise (resolve, reject) ->
    sauceAccount.updateJob sessionID, status, (err) ->
      if err
        reject err
      else
        resolve null

describe 'functional tests', ->
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
      client.init()
    .then ->
      client = client
        .url APP_URL
        .pause(100) # don't question it

  after ->
    client
      .then ->
        new Promise (resolve) ->
          revision.short (str) ->
            resolve build = str
      .sauceJobStatus
        passed: _.every this.test.parent.tests, {state: 'passed'}
        public: 'public'
        build: build
      .end()
  # coffeelint: enable=missing_fat_arrows

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
