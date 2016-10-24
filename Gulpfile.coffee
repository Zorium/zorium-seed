fs = require 'fs'
del = require 'del'
_ = require 'lodash'
log = require 'loga'
gulp = require 'gulp'
webpack = require 'webpack'
mocha = require 'gulp-mocha'
spawn = require('child_process').spawn
autoprefixer = require 'autoprefixer'
coffeelint = require 'gulp-coffeelint'
webpackStream = require 'webpack-stream'
WebpackDevServer = require 'webpack-dev-server'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

config = require './src/config'

paths =
  static: './src/static/**/*'
  coffee: ['./*.coffee', './src/**/*.coffee']
  unitTests: ['./src/**/test.coffee', './src/**/*.test.coffee']
  root: './src/root.coffee'
  dist: './dist'
  build: './build'

webpackBase =
  module:
    exprContextRegExp: /$^/
    exprContextCritical: false
  resolve:
    extensions: ['.coffee', '.js', '.json', '']
  output:
    filename: 'bundle.js'
    publicPath: '/'
  postcss: -> [autoprefixer({})]

gulp.task 'dev', ['dev:webpack-server', 'dev:server']
gulp.task 'test', ['test:lint', 'test:unit']
gulp.task 'dist', ['dist:scripts', 'dist:static']
gulp.task 'watch', -> gulp.watch paths.coffee, ['test']

gulp.task 'test:lint', ->
  gulp.src paths.coffee
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'test:unit', ->
  gulp.src paths.unitTests
    .pipe mocha()

gulp.task 'dev:static', ->
  gulp.src paths.static
    .pipe gulp.dest paths.build

gulp.task 'dev:server', ['dev:static'], do ->
  devServer = null
  process.on 'exit', -> devServer?.kill()
  ->
    devServer?.kill()
    devServer = spawn 'coffee', ['src/server/start.coffee'], {stdio: 'inherit'}

gulp.task 'dev:webpack-server', ->
  compiler = webpack _.defaultsDeep {
    devtool: 'inline-source-map'
    entry: [
      "webpack-dev-server/client?#{config.WEBPACK_DEV_URL}"
      'webpack/hot/dev-server'
      paths.root
    ]
    output:
      path: __dirname
      publicPath: "#{config.WEBPACK_DEV_URL}/"
    module:
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {test: /\.styl$/, loaders: [
          'style-loader'
          'css-loader',
          'postcss-loader',
          'stylus-loader?paths[]=node_modules'
        ]}
      ]
    plugins: [
      new webpack.HotModuleReplacementPlugin()
      new webpack.DefinePlugin
        'process.env': _.mapValues process.env, (val) -> JSON.stringify val
    ]
  }, webpackBase

  new WebpackDevServer compiler,
    publicPath: "#{config.WEBPACK_DEV_URL}/"
    hot: true
    noInfo: true
  .listen config.WEBPACK_DEV_PORT, (err) ->
    if err
      log.error err
    else
      log.info
        event: 'webpack_server_start'
        message: "Webpack listening on port #{config.WEBPACK_DEV_PORT}"

gulp.task 'dist:clean', (cb) ->
  del paths.dist, cb

gulp.task 'dist:static', ['dist:clean'], ->
  gulp.src paths.static
    .pipe gulp.dest paths.dist

gulp.task 'dist:scripts', ['dist:clean'], ->
  scriptsConfig = _.defaultsDeep {
    devtool: 'source-map'
    plugins: [
      new webpack.optimize.UglifyJsPlugin
        mangle:
          except: ['process']
      new ExtractTextPlugin 'bundle.css'
    ]
    output:
      filename: '[hash].bundle.js'
    module:
      loaders: [
        {test: /\.coffee$/, loader: 'coffee'}
        {test: /\.json$/, loader: 'json'}
        {
          test: /\.styl$/
          loader: ExtractTextPlugin.extract [
            'css-loader',
            'postcss-loader',
            'stylus-loader?paths[]=node_modules'
          ]
        }
      ]
  }, webpackBase

  gulp.src paths.root
  .pipe webpackStream scriptsConfig, null, (err, stats) ->
    if err
      console.error err
      return
    statsJson = JSON.stringify {hash: stats.toJson().hash}
    fs.writeFileSync "#{__dirname}/#{paths.dist}/stats.json", statsJson
  .pipe gulp.dest paths.dist
