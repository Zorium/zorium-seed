fs = require 'fs'
_ = require 'lodash'
del = require 'del'
path = require 'path'
gulp = require 'gulp'
karma = require('karma').server
webpack = require 'webpack'
mocha = require 'gulp-mocha'
Promise = require 'bluebird'
rename = require 'gulp-rename'
nodemon = require 'gulp-nodemon'
gulpWebpack = require 'gulp-webpack'
coffeelint = require 'gulp-coffeelint'
RewirePlugin = require 'rewire-webpack'
istanbul = require 'gulp-coffee-istanbul'
clayLintConfig = require 'clay-coffeescript-style-guide'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

FUNCTIONAL_TEST_TIMEOUT_MS = 10 * 1000 # 10sec

karmaConf =
  frameworks: ['mocha']
  client:
    useIframe: true
    captureConsole: true
    mocha:
      timeout: 1000
  files: [
    'build/test/bundle.js'
  ]
  browsers: ['Chrome', 'Firefox']

paths =
  static: './src/static/**/*'
  coffee: [
    './*.coffee'
    './src/**/*.coffee'
    './test/**/*.coffee'
  ]
  cover: [
    './*.coffee'
    './src/**/*.coffee'
  ]
  tests: './test/unit/**/*.coffee'
  serverTests: './test/server/index.coffee'
  functionalTests: './test/functional/**/*.coffee'
  root: './src/root.coffee'
  rootTests: './test/index.coffee'
  dist: './dist'
  build: './build'

mochaKiller = do ->
  pendingCnt = 0

  check = ->
    setTimeout ->
      if pendingCnt is 0
        process.exit() # mocha hangs
    , 100

  ->
    pendingCnt += 1

    hasBeenCalled = false
    ->
      unless hasBeenCalled
        hasBeenCalled = true
        pendingCnt -= 1
        check()

gulp.task 'build', ['scripts:prod', 'static:prod']

# start the dev server, and auto-update
gulp.task 'dev', ['server:webpack', 'server:dev:watch']

gulp.task 'test', ['test:karma', 'test:node:coverage', 'lint']

gulp.task 'watch', ->
  gulp.watch paths.coffee, ['test:server:watch', 'test:unit:phantom']

gulp.task 'lint', ->
  gulp.src paths.coffee
    .pipe coffeelint(null, clayLintConfig)
    .pipe coffeelint.reporter()

gulp.task 'test:karma', ['scripts:test'], ->
  karma.start _.defaults(singleRun: true, karmaConf), mochaKiller()

gulp.task 'server:webpack', ->
  require('./bin/webpack_server.coffee')

gulp.task 'server:dev:watch', ['static:dev'], ->
  nodemon {script: 'bin/dev_server.coffee', ext: 'js json coffee'}

gulp.task 'server:dev', ['static:dev'], ->
  require('./bin/dev_server.coffee')

gulp.task 'test:server:watch', ->
  gulp.src paths.serverTests
    .pipe mocha()

gulp.task 'test:functional', ->
  end = mochaKiller()
  gulp.src paths.functionalTests
    .pipe mocha(timeout: FUNCTIONAL_TEST_TIMEOUT_MS)
    .on 'error', end
    .once 'end', end

gulp.task 'test:node:coverage', ->
  end = mochaKiller()
  gulp.src paths.cover
    .pipe istanbul includeUntested: false
    .pipe istanbul.hookRequire()
    .on 'finish', ->
      gulp.src [paths.serverTests, paths.tests]
        .pipe mocha()
        .pipe istanbul.writeReports()
        .on 'error', end
        .once 'end', end

gulp.task 'watch:functional', ->
  gulp.watch paths.coffee, ['test:functional:watch']

gulp.task 'test:functional:watch', ->
  gulp.src paths.functionalTests
    .pipe mocha(timeout: FUNCTIONAL_TEST_TIMEOUT_MS)

gulp.task 'test:unit:phantom', ['scripts:test'], (cb) ->
  karma.start _.defaults({
    singleRun: true,
    browsers: ['PhantomJS']
  }, karmaConf), cb

gulp.task 'static:dev', ->
  gulp.src paths.static
    .pipe gulp.dest paths.build

gulp.task 'scripts:test', ->
  gulp.src paths.rootTests
  .pipe gulpWebpack
    devtool: 'inline-source-map'
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
      new RewirePlugin()
    ]
    resolve:
      root: [path.join(__dirname, 'bower_components')]
      extensions: ['.coffee', '.js', '.json', '']
      # browser-builtins is for tests requesting native node modules
      modulesDirectories: ['web_modules', 'node_modules', './src',
      './node_modules/browser-builtins/builtin']
  .pipe rename 'bundle.js'
  .pipe gulp.dest paths.build + '/test/'


#
# Production compilation
#

# rm -r dist
gulp.task 'clean:dist', (cb) ->
  del paths.dist, cb

gulp.task 'static:prod', ['clean:dist'], ->
  gulp.src paths.static
    .pipe gulp.dest paths.dist

# root.coffee --> dist/
gulp.task 'scripts:prod', ['clean:dist'], ->
  gulp.src paths.root
  .pipe gulpWebpack
    devtool: 'source-map'
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
          loader: ExtractTextPlugin.extract 'style-loader',
            'css!autoprefixer!' +
            'stylus?paths[]=bower_components&paths[]=node_modules'
        }
      ]
    plugins: [
      new webpack.ResolverPlugin(
        new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin(
          'bower.json', ['main']
        )
      )
      new webpack.optimize.UglifyJsPlugin()
      new ExtractTextPlugin 'bundle.css'
    ]
    resolve:
      root: [path.join(__dirname, 'bower_components')]
      extensions: ['.coffee', '.js', '.json', '']
    output:
      filename: '[hash].bundle.js'
      publicPath: '/'
  , null, (err, stats) ->
    if err
      return

    fs.writeFileSync "#{__dirname}/#{paths.dist}/stats.json",
                     JSON.stringify stats.toJson()
  .pipe gulp.dest paths.dist
