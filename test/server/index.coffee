flareGun = require 'flare-gun'
zock = require 'zock'
should = require('chai').should()

app = require '../../server'
config = require '../../src/config'

flare = flareGun.express(app)

after ->
  flare.close()

describe 'server', ->
  it 'is healthy', ->
    zock
    .base config.API_URL
    .get '/ping'
    .reply 200, 'pong'
    .withOverride ->
      flare
        .get '/healthcheck'
        .expect 200, {
          healthy: true
        }

  it 'fails if not healthy', ->
    zock
    .base config.API_URL
    .get '/ping'
    .reply 503
    .withOverride ->
      flare
        .get '/healthcheck'
        .expect 500, {
          api: false
          healthy: false
        }

  it 'pongs', ->
    flare
      .get '/ping'
      .expect 200, 'pong'

  it 'renders /', ->
    zock
    .base config.API_URL
    .get '/demo'
    .reply 200, {name: 'Zorium'}
    .post '/demo/users/me'
    .reply 200, {}
    .withOverride ->
      flare
        .get '/'
        .expect 200

  it 'renders /404', ->
    flare
      .get '/404'
      .expect 404
