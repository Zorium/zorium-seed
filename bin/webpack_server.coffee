#!/usr/bin/env coffee
log = require 'clay-loglevel'
path = require 'path'

webpack = require 'webpack'
WebpackDevServer = require 'webpack-dev-server'
config = require '../src/config'

webpackDevPort = config.WEBPACK_DEV_PORT
webpackDevHostname = config.WEBPACK_DEV_HOSTNAME
isMockingApi = config.MOCK

entries = [
  "webpack-dev-server/client?http://#{webpackDevHostname}:#{webpackDevPort}"
  'webpack/hot/dev-server'
]
# Order matters because mock overrides window.XMLHttpRequest
if isMockingApi
  entries = entries.concat ['./src/mock']
entries = entries.concat ['./src/root']

new WebpackDevServer webpack({
  entry: entries
  devtool: 'inline-source-map'
  output:
    path: __dirname,
    filename: 'bundle.js',
    publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
  module:
    exprContextRegExp: /$^/
    exprContextCritical: false
    postLoaders: [
      { test: /\.coffee$/, loader: 'transform/cacheable?envify' }
    ]
    loaders: [
      { test: /\.coffee$/, loader: 'coffee' }
      { test: /\.json$/, loader: 'json' }
      {
        test: /\.styl$/
        loader: 'style!css!autoprefixer!stylus?' +
                'paths[]=bower_components&paths[]=node_modules'
      }
    ]
  plugins: [
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin(
        'bower.json', ['main']
      )
    )
    new webpack.HotModuleReplacementPlugin()
  ]
  resolve:
    root: [path.join(__dirname, '/../bower_components')]
    extensions: ['.coffee', '.js', '.json', '']
}),
  publicPath: "//#{webpackDevHostname}:#{webpackDevPort}/"
  hot: true
.listen webpackDevPort, (err) ->
  if err
    log.trace err
  log.info 'Webpack listening on port %d', webpackDevPort
