paths =
  static: './src/static/**/*'
  coffee: ['./*.coffee', './src/**/*.coffee', './test/**/*.coffee']
  cover: [
    './*.coffee'
    './src/**/*.coffee'
    '!./src/**/*.test.coffee'
    '!./src/**/test.coffee'
  ]
  unitTests: ['./src/**/test.coffee', './src/**/*.test.coffee']
  serverTests: './test/server/index.coffee'
  functionalTests: './test/functional/**/*.coffee'
  root: './src/root.coffee'
  dist: './dist'
  build: './build'

karma =
  singleRun: true
  frameworks: ['mocha']
  files: [paths.build + '/bundle.js']
  browsers: ['Chrome', 'Firefox']

cssLoader = 'css!autoprefixer!stylus?paths[]=node_modules'
webpack =
  devtool: 'inline-source-map'
  module:
    exprContextRegExp: /$^/
    exprContextCritical: false
    loaders: [
      { test: /\.coffee$/, loader: 'coffee' }
      { test: /\.json$/, loader: 'json' }
    ]
  resolve:
    extensions: ['.coffee', '.js', '.json', '']
  output:
    filename: 'bundle.js'
    publicPath: '/'

# Avoid webpack include
env = process.env
module.exports = {
  FUNCTIONAL_TEST_TIMEOUT_MS: 10 * 1000 # 10sec
  WEBPACK_DEV_HOSTNAME: env.WEBPACK_DEV_HOSTNAME or 'localhost'
  WEBPACK_DEV_PORT: env.WEBPACK_DEV_PORT or 3001
  REMOTE_SELENIUM: env.REMOTE_SELENIUM is '1'
  SELENIUM_BROWSER: env.SELENIUM_BROWSER or 'chrome'
  SAUCE_USERNAME: env.SAUCE_USERNAME
  SAUCE_ACCESS_KEY: env.SAUCE_ACCESS_KEY
  paths
  karma
  cssLoader
  webpack
}
