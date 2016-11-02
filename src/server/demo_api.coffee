_ = require 'lodash'
express = require 'express'
log = require 'loga'
bodyParser = require 'body-parser'
router = require 'exoid-router'
uuid = require 'uuid'

config = require '../config'

app = express()
demoUserDB = {}
demoCount = {
  id: uuid.v4()
  count: 0
}

# CORS
app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers',
    'Origin, X-Requested-With, Content-Type, Accept'
  next()
app.use bodyParser.json()
# Avoid CORS preflight
app.use bodyParser.json({type: 'text/plain'})

app.get '/healthcheck', (req, res, next) -> res.json {healthy: true}
app.get '/ping', (req, res) -> res.send 'pong'

auth = (handler) ->
  (body, req, rest...) ->
    accessToken = req.query?.accessToken

    unless demoUserDB[accessToken]?
      router.throw status: 401, info: 'Unauthorized'
    req.user = demoUserDB[accessToken]

    handler body, req, rest...

exoidMiddleware = router
###################
# Public Routes   #
###################
.on 'auth.login', (body) ->
  id = uuid.v4()
  accessToken = "#{id}_#{Math.random().toFixed(10)}"
  user = {
    id: id
    username: "u_#{id.slice(0, 5)}"
  }
  log.info {event: 'user_create', id: user.id}
  demoUserDB[accessToken] = user
  return {accessToken}
###################
# Authed Routes   #
###################
.on 'users.getMe', auth (body, {user}) ->
  return user
.on 'count.get', auth -> demoCount
.on 'count.inc', auth ->
  demoCount.count += 1
  log.info {event: 'count_inc', count: demoCount.count}
  return demoCount
.asMiddleware()

app.post '/exoid', exoidMiddleware

app.listen 3005, ->
  log.info
    event: 'demo_api_start'
    message: 'Demo API, listening on port 3005'
