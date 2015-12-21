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

    requests = requests.map (req) ->
      route = routes.get req.path
      {req, route, $page: route.handler()}

    route = (path, Page) ->
      $page = new Page({
        model, router, serverData
        requests: requests.filter ({$page}) -> $page instanceof Page
      })

      routes.set path, -> $page

    route '/', HomePage
    route '/red', RedPage
    route '/*', FourOhFourPage

    $backupPage = if serverData?
      routes.get(serverData.req.path).handler()
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
