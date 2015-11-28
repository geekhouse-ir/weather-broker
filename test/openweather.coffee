require('chai').should()
Q = require 'q'
_ = require 'lodash'

OpenWeather = require('../src/openweather/api.coffee')
APPID = 'a54b75e2c789e0f2bd076f5eb6c28b31'
describe 'structure', ->
  it 'should have default options', ->
    ow = new OpenWeather()
    ow.options.should.have.all.keys 'lang', 'units', 'mode'

  it 'should set options with config method', ->
    ow = new OpenWeather()
    ow.config appid: APPID
    ow.options.appid.should.be.eq APPID

  it 'should get current weather of a city without unit', ->
    ow = new OpenWeather()
    ow.options.appid = APPID
    ow.get_current('tehran')
      .then (result) ->
        result.should.contains.all.keys 'coord', 'weather'

  it 'should get current weather of a location without unit', ->
    ow = new OpenWeather()
    ow.options.appid = APPID
    ow.get_current(lat: 53, lon: 63)
      .then (result) ->
        result.should.contains.all.keys 'coord', 'weather'
  
  it 'should get forecast of a city without unit', ->
    ow = new OpenWeather()
    ow.config
      appid: APPID
      cnt: 2
    ow.get_forecasts('tehran')
      .then (result) ->
        result.list.should.have.length 2

  it 'should get forecast of a location without unit', ->
    ow = new OpenWeather()
    ow.options.appid = APPID
    ow.get_forecasts({lat: 53, lon: 63}, 3)
      .then (result) ->
        result.list.should.have.length 3
