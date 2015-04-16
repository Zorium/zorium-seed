z = require 'zorium'
paperColors = require 'zorium-paper/colors.json'
Rx = require 'rx-lite'

config = require './config'
HomePage = require './pages/home'
FourOhFourPage = require './pages/404'

router = new z.Router()
isInliningSource = config.ENV is config.ENVS.PROD

styles = if not window? and isInliningSource
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  fs.readFileSync './dist/bundle.css', 'utf-8'
else
  null

scripts = if not window? and isInliningSource
  # Avoid webpack include
  _fs = 'fs'
  fs = require _fs
  fs.readFileSync './dist/bundle.js', 'utf-8'
else
  null

class Root
  constructor: ->
    @$currentPage = new Rx.ReplaySubject(1)
    @state = z.state {
      lastRenderedPath: null
      status: 200
      $currentPage: @$currentPage
    }

  render: ({path, cookies}) ->
    {lastRenderedPath, $currentPage, status} = @state.getValue()

    if path isnt lastRenderedPath
      lastRenderedPath = path
      if path is '/'
        @$currentPage.onNext new HomePage()
      else
        @state.set status: 404
        @$currentPage.onNext new FourOhFourPage()

    webpackDevHostname = config.WEBPACK_DEV_HOSTNAME
    title = 'Zorium Seed'
    description = 'Zorium Seed - (╯°□°）╯︵ ┻━┻)'
    keywords = 'Zorium'
    name = 'Zorium Seed'
    twitterHandle = '@ZoriumJS'
    themeColor = paperColors.$teal700
    favicon = '/images/zorium_icon_32.png'
    icon1024 = '/images/zorium_icon_1024.png'
    icon256 = '/images/zorium_icon_256.png'
    url = 'http://zorium.org'

    tree = z 'html',
      z 'head',
        z 'title', "#{title}"
        z 'meta', {name: 'description', content: "#{description}"}
        z 'meta', {name: 'keywords', content: "#{keywords}"}

        # mobile
        z 'meta',
          name: 'viewport'
          content: 'initial-scale=1.0, width=device-width, minimum-scale=1.0,
                    maximum-scale=1.0, user-scalable=0, minimal-ui'
        z 'meta', {name: 'msapplication-tap-highlight', content: 'no'}
        z 'meta', {name: 'apple-mobile-web-app-capable', content: 'yes'}

        # Schema.org markup for Google+
        z 'meta', {itemprop: 'name', content: "#{name}"}
        z 'meta', {itemprop: 'description', content: "#{description}"}
        z 'meta', {itemprop: 'image', content: "#{icon256}"}

        # Twitter card
        z 'meta', {name: 'twitter:card', content: 'summary_large_image'}
        z 'meta', {name: 'twitter:site', content: "#{twitterHandle}"}
        z 'meta', {name: 'twitter:creator', content: "#{twitterHandle}"}
        z 'meta', {name: 'twitter:title', content: "#{title}"}
        z 'meta', {name: 'twitter:description', content: "#{description}"}
        z 'meta', {name: 'twitter:image:src', content: "#{icon1024}"}

        # Open Graph
        z 'meta', {property: 'og:title', content: "#{name}"}
        z 'meta', {property: 'og:type', content: 'website'}
        z 'meta', {property: 'og:url', content: "#{url}"}
        z 'meta', {property: 'og:image', content: "#{icon1024}"}
        z 'meta', {property: 'og:description', content: "#{description}"}
        z 'meta', {property: 'og:site_name', content: "#{name}"}

        # iOS
        z 'link', {rel: 'apple-touch-icon', href: "#{icon256}"}

        # misc
        z 'meta', {name: 'theme-color', content: "#{themeColor}"}
        z 'link', {rel: 'shortcut icon', href: "#{favicon}"}

        # fonts
        z 'link',
          href: '//fonts.googleapis.com/css?family=Roboto:300,400,500'
          rel: 'stylesheet'
          type: 'text/css'

        # styles
        if isInliningSource
          z 'style',
            styles
        else
          null

      z 'body',
        z '#zorium-root',
          z $currentPage, {}
        z 'div',
          if isInliningSource
            z 'script', scripts
          else
            z 'script', {src: "//#{webpackDevHostname}:3004/js/bundle.js"}

    if status is 404
      throw new router.Error {tree, status}
    else
      return tree

$root = new Root()
router.add '/', ({cookies}) ->
  z $root, {path: '/', cookies}

router.add '*', ({cookies}) ->
  z $root, {path: '*', cookies}

module.exports = router
