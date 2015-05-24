flareGun = require 'flare-gun'
nock = require 'nock'
should = require('chai').should()

app = require '../../server'
config = require '../../src/config'

flare = flareGun.express(app)

before ->
  nock.enableNetConnect('0.0.0.0')

after ->
  flare.close()

describe 'server', ->
  it 'is healthy', ->
    nock config.API_URL
    .get '/ping'
    .reply 200, 'pong'

    flare
      .get '/healthcheck'
      .expect 200, {
        healthy: true
      }

  it 'fails if not healthy', ->
    nock config.API_URL
    .get '/ping'
    .reply 503, 'error'

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
    nock config.API_URL
    .get '/demo'
    .reply 200, {name: 'Zorium'}

    flare
      .get '/'
      .expect 200

  it 'renders /404', ->
    flare
      .get '/404'
      .expect 404
