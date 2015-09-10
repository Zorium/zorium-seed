z = require 'zorium'
Rx = require 'rx-lite'
HttpHash = require 'http-hash'
Qs = require 'qs'

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
  constructor: ({requests, model}) ->
    router = new HttpHash()

    defaultHandler = -> $fourOhFourPage
    requests = requests.map ({req, res}) ->
      route = router.get req.path
      $page = if route.handler? then route.handler() else defaultHandler()

      return {req, res, route, $page}

    $homePage = new HomePage({
      model
      requests: requests.filter ({$page}) -> $page instanceof HomePage
    })
    $redPage = new RedPage({
      model
      requests: requests.filter ({$page}) -> $page instanceof RedPage
    })
    $fourOhFourPage = new FourOhFourPage({
      model
      requests: requests.filter ({$page}) -> $page instanceof FourOhFourPage
    })

    router.set '/', -> $homePage
    router.set '/red', -> $redPage

    handleRequest = requests.doOnNext ({req, res, route, $page}) =>
      {$currentPage} = @state.getValue()

      if $page instanceof FourOhFourPage
        res.status? 404

      isEntering = Boolean $currentPage

      if isEntering and window?
        @state.set {
          isEntering
          $nextPage: $page
        }

        window.requestAnimationFrame =>
          setTimeout =>
            @state.set
              isActive: true

        setTimeout =>
          @state.set
            $currentPage: $page
            $nextPage: null
            isEntering: false
            isActive: false
        , ANIMATION_TIME_MS
      else
        @state.set
          $currentPage: $page

    @state = z.state {
      handleRequest: handleRequest
      $currentPage: null
      $nextPage: null
      isEntering: false
      isActive: false
    }

  render: =>
    {$nextPage, $currentPage, isEntering, isActive} = @state.getValue()

    z 'html',
      $currentPage?.renderHead {styles, bundlePath}
      z 'body',
        z '#zorium-root',
          z '.z-root',
            className: z.classKebab {isEntering, isActive}
            z '.current',
              $currentPage
            z '.next',
              $nextPage
