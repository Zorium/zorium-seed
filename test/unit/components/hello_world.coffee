should = require('clay-chai').should()

HelloWorld = require 'components/hello_world'

describe 'StarsComponent', ->
  it 'renders stars ', ->
    helloWorldComponent = new HelloWorld()
    $ = helloWorldComponent.render()

    $.tagName.should.be 'div'
    $.properties.className.should.be 'z-hello-world'
