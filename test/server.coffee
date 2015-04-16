flareGun = require 'flare-gun'
nock = require 'nock'
should = require('clay-chai').should()

app = require '../server'
config = require '../src/config'

flare = flareGun.express(app)

before ->
  nock.enableNetConnect('0.0.0.0')

describe 'server', ->
  it 'is healthy', ->
    nock config.API_URL
    .get '/repos/zorium/zorium'
    .reply 200, {
      'id': 26881260,
      'name': 'zorium',
      'stargazers_count': 9001
    }

    flare
      .get '/healthcheck'
      .expect 200, {
        healthy: true
      }

  it 'fails if not healthy', ->
    nock config.API_URL
    .get '/repos/zorium/zorium'
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
    flare
      .get '/'
      .expect 200

  it 'renders /404', ->
    flare
      .get '/404'
      .expect 404
