require '../src/polyfill'
require '../src/mock'

# webpack require all tests
testsContext = require.context('./unit', true)
testsContext.keys().forEach testsContext
