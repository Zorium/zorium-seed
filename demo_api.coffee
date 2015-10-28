_ = require 'lodash'
express = require 'express'
log = require 'loga'
cors = require 'cors'
bodyParser = require 'body-parser'
router = require 'exoid-router'
uuid = require 'uuid'

config = require './src/config'

app = express()
demoUserDB = {}
demoCount = {
  id: uuid.v4()
  count: 0
}

app.use cors()
app.use bodyParser.json()
# Avoid CORS preflight
app.use bodyParser.json({type: 'text/plain'})

app.use '/healthcheck', (req, res, next) ->
  res.json {healthy: true}

app.use '/ping', (req, res) ->
  res.send 'pong'

app.post '/log', (req, res) ->
  unless req.body?.event is 'client_error'
    router.throw status: 400, detail: 'must be type client_error'

  log.warn req.body
  res.status(204).send()

auth = (handler) ->
  (body, req, rest...) ->
    accessToken = req.query?.accessToken

    unless demoUserDB[accessToken]?
      router.throw status: 401, detail: 'Unauthorized'

    req.user = demoUserDB[accessToken]

    handler body, req, rest...

exoidMiddleware = router
###################
# Public Routes   #
###################
.on 'users.create', (body) ->
  id = uuid.v4()
  user = {
    id: id
    username: "u_#{id.slice(0, 5)}"
    accessToken: "#{id}_#{Math.random().toFixed(10)}"
  }
  log.info {event: 'user_create', id: user.id}
  return demoUserDB[user.accessToken] = user
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
  log.info 'Demo API, listening on port %d', 3005
