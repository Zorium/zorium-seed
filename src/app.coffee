z = require 'zorium'
Rx = require 'rx-lite'
HttpHash = require 'http-hash'

config = require './config'
gulpPaths = require '../gulp_paths'
HomePage = require './pages/home'
RedPage = require './pages/red'
FourOhFourPage = require './pages/404'

module.exports = class App
  constructor: ({requests, serverData, model, router}) ->
    routes = new HttpHash()

    # TODO: ugly
    reqToRoute = (req) ->
      route = routes.get req.path
      # TODO: HttpHash should support a catchall
      route.handler ?= -> $fourOhFourPage
      return route

    requests = requests.map (req) ->
      route = reqToRoute req
      {req, route, $page: route.handler()}

    $homePage = new HomePage({
      model
      router
      serverData
      requests: requests.filter ({$page}) -> $page instanceof HomePage
    })
    $redPage = new RedPage({
      model
      router
      serverData
      requests: requests.filter ({$page}) -> $page instanceof RedPage
    })
    $fourOhFourPage = new FourOhFourPage({
      model
      serverData
      requests: requests.filter ({$page}) -> $page instanceof FourOhFourPage
    })

    routes.set '/', -> $homePage
    routes.set '/red', -> $redPage

    $backupPage = if serverData?
      reqToRoute(serverData.req).handler()
    else
      null

    @state = z.state {
      $backupPage
      request: requests.doOnNext ({$page, req}) ->
        if $page instanceof FourOhFourPage
          res?.status? 404
    }

  render: =>
    {request, $backupPage, $modal} = @state.getValue()

    z 'html',
      request?.$page.renderHead() or $backupPage?.renderHead()
      z 'body',
        z '#zorium-root',
          z '.z-root',
            request?.$page or $backupPage
