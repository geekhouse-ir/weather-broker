require('chai').should()
Q = require 'q'
_ = require 'lodash'

OpenWeather = require('../src/openweather.coffee')

DEFAULT_OPTIONS =
  lang: 'en'
  units: 'metric'
  mode: 'json'

describe 'structure', ->
  it 'should be have default options', ->
    ow = new  OpenWeather()
    ow.options.should.be.deep.eq DEFAULT_OPTIONS

  it 'should set options', ->
    ow = new OpenWeather()
    ow.config
      cnt:2
      lang: 'fr'
      appid: 'fakeid'

    ow.options.lang.should.be.eq 'fr'
    ow.options.cnt.should.be.eq 2
    ow.options.appid.should.be.eq 'fakeid'
    ow.options.units.should.be.eq 'metric'

  it 'should find weather by city', ->
    ow = new OpenWeather()
    ow.current({
      q: 'tehran'
      appid: 'a54b75e2c789e0f2bd076f5eb6c28b31'
    }).then (res) -> console.log res

