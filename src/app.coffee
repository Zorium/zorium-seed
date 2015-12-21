z = require 'zorium'
Rx = require 'rx-lite'
HttpHash = require 'http-hash'

config = require './config'
gulpPaths = require '../gulp_paths'
HomePage = require './pages/home'
RedPage = require './pages/red'
FourOhFourPage = require './pages/404'

ANIMATION_TIME_MS = 500

styles = if not window? and config.ENV is config.ENVS.PROD
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  fs.readFileSync gulpPaths.dist + '/bundle.css', 'utf-8'
else
  null

bundlePath = if not window? and config.ENV is config.ENVS.PROD
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  stats = JSON.parse \
    fs.readFileSync gulpPaths.dist + '/stats.json', 'utf-8'

  "/#{stats.hash}.bundle.js"
else
  null

module.exports = class App
  constructor: ({requests, model, router}) ->
    routes = new HttpHash()

    # TODO: ugly
    @req = requests.getValue()
    @reqToRoute = (req) ->
      route = routes.get req.path
      # TODO: HttpHash should support a catchall
      route.handler ?= -> $fourOhFourPage
      return route

    requests = requests.map (req) =>
      route = @reqToRoute req
      {req, route, $page: route.handler()}

    $homePage = new HomePage({
      model
      router
      requests: requests.filter ({$page}) -> $page instanceof HomePage
    })
    $redPage = new RedPage({
      model
      router
      requests: requests.filter ({$page}) -> $page instanceof RedPage
    })
    $fourOhFourPage = new FourOhFourPage({
      model
      requests: requests.filter ({$page}) -> $page instanceof FourOhFourPage
    })

    routes.set '/', -> $homePage
    routes.set '/red', -> $redPage

    @state = z.state {
      requests: requests.doOnNext ({$page, req}) ->
        if $page instanceof FourOhFourPage
          req.res.status? 404
    }

  render: =>
    {requests, $modal} = @state.getValue()

    head = requests?.$page.renderHead {styles, bundlePath}
    # If an error occures during server-side rendering
    head ?= @reqToRoute(@req).handler().renderHead {styles, bundlePath}

    z 'html',
      head
      z 'body',
        z '#zorium-root',
          z '.z-root',
            requests?.$page
