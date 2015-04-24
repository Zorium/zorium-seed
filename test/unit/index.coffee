require 'polyfill'

mock = require 'mock'
testsContext = require.context('.', true)
testsContext.keys().forEach testsContext
