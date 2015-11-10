z = require 'zorium'
colors = require 'zorium-paper/colors.json'

config = require '../../config'

module.exports = class Head
  constructor: ({model}) ->
    @state = z.state
      modelSerialization: model.getSerializationStream()

  render: ({styles, bundlePath, title}) =>
    {modelSerialization} = @state.getValue()

    isInliningSource = config.ENV is config.ENVS.PROD
    webpackDevUrl = config.WEBPACK_DEV_URL
    title ?= 'Zorium Seed'
    description = 'Zorium Seed - (╯°□°）╯︵ ┻━┻)'
    keywords = 'Zorium'
    name = 'Zorium Seed'
    twitterHandle = '@ZoriumJS'
    themeColor = colors.$teal700
    favicon = '/images/zorium_icon_32.png'
    icon1024 = '/images/zorium_icon_1024.png'
    icon256 = '/images/zorium_icon_256.png'
    url = 'https://zorium.org'

    z 'head',
      z 'title', "#{title}"
      z 'meta', {name: 'description', content: "#{description}"}
      z 'meta', {name: 'keywords', content: "#{keywords}"}

      # Appcache
      if config.ENV is config.ENVS.PROD
        z 'iframe',
          src: '/manifest.html'
          style:
            width: 0
            height: 0
            visibility: 'hidden'
            position: 'absolute'
            border: 'none'

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

      # serialization
      z 'script.model',
        innerHTML: modelSerialization or ''

      # fonts
      z 'link',
        rel: 'stylesheet'
        type: 'text/css'
        href: 'https://fonts.googleapis.com/css?family=Roboto:400,300,500'

      # styles
      if isInliningSource
        z 'style.styles',
          innerHTML: styles
      else
        null

      # scripts
      z 'script.bundle',
        async: true
        src: if isInliningSource then bundlePath \
             else "#{webpackDevUrl}/bundle.js"
