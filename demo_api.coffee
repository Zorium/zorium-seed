_ = require 'lodash'
express = require 'express'
log = require 'loga'
cors = require 'cors'
bodyParser = require 'body-parser'

config = require './src/config'

app = express()
router = express.Router()
demoUserDB = {}
demoCount = 0

app.use cors()
app.use bodyParser.json()

app.use '/healthcheck', (req, res, next) ->
  res.json {healthy: true}

app.use '/ping', (req, res) ->
  res.send 'pong'

app.get '/demo', (req, res) ->
  res.json {name: 'Zorium'}

app.post '/log', (req, res) ->
  log.info JSON.stringify
    event: 'client_error'
    trace: req.body?.trace
    message: req.body?.message
  res.status(204).send()

app.get '/demo/users/me', (req, res) ->
  authHeader = req.header('Authorization') or ''
  [authScheme, accessToken] = authHeader.split(' ')

  unless demoUserDB[accessToken]
    return res.status(401).send()

  res.json demoUserDB[accessToken]

app.post '/demo/users/me', (req, res) ->
  authHeader = req.header('Authorization') or ''
  [authScheme, accessToken] = authHeader.split(' ')

  if demoUserDB[accessToken]
    return res.json demoUserDB[accessToken]

  id = _.keys(demoUserDB).length
  user = {
    id: id
    username: "test_#{id}"
    accessToken: "#{id}_#{Math.random().toFixed(10)}"
  }

  res.json demoUserDB[user.accessToken] = user

app.get '/demo/count', (req, res) ->
  authHeader = req.header('Authorization') or ''
  [authScheme, accessToken] = authHeader.split(' ')

  unless demoUserDB[accessToken]
    return res.status(401).send()

  res.json {count: demoCount}

app.post '/demo/count', (req, res) ->
  authHeader = req.header('Authorization') or ''
  [authScheme, accessToken] = authHeader.split(' ')

  unless demoUserDB[accessToken]
    return res.status(401).send()

  demoCount += 1
  res.json {count: demoCount}

app.use router

app.listen 3005, ->
  log.info 'Demo API, listening on port %d', 3005
