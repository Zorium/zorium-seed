webdriverio = require 'clay-webdriverio'
SauceLabs = require 'saucelabs'
Promise = require 'bluebird'

gulpConfig = require '../../gulp_config'

client = if gulpConfig.REMOTE_SELENIUM
  webdriverio.remote
    desiredCapabilities:
      browserName: gulpConfig.SELENIUM_BROWSER
      name: 'Zorium Seed'
      tags: ['zorium_seed']
    host: 'ondemand.saucelabs.com'
    port: 80
    user: gulpConfig.SAUCE_USERNAME
    key: gulpConfig.SAUCE_ACCESS_KEY
else
  webdriverio.remote
    desiredCapabilities:
      browserName: gulpConfig.SELENIUM_BROWSER

client.addCommand 'sauceJobStatus', (status) ->
  unless gulpConfig.REMOTE_SELENIUM
    return

  sessionID = client.requestHandler.sessionID
  sauceAccount = new SauceLabs
    username: gulpConfig.SAUCE_USERNAME
    password: gulpConfig.SAUCE_ACCESS_KEY

  new Promise (resolve, reject) ->
    sauceAccount.updateJob sessionID, status, (err) ->
      if err
        reject err
      else
        resolve null

module.exports = client
