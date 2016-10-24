flareGun = require 'flare-gun'
zock = require 'zock'

app = require './index'
config = require '../config'

flare = flareGun.express(app)

after ->
  flare.close()

describe 'server', ->
  it 'is healthy', ->
    zock
    .base config.API_URL
    .get '/ping'
    .reply 200, 'pong'
    .withOverrides ->
      flare
        .get '/healthcheck'
        .expect 200, {
          healthy: true
          api: true
        }

  it 'fails if not healthy', ->
    zock
    .base config.API_URL
    .get '/ping'
    .reply 503
    .withOverrides ->
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
    .exoid 'auth.login'
    .reply {}
    .exoid 'users.create'
    .reply {}
    .exoid 'users.getMe'
    .reply {}
    .exoid 'count.get'
    .reply {}
    .withOverrides ->
      flare
        .get '/'
        .expect 200

  it 'renders /404', ->
    flare
      .get '/404'
      .expect 404
