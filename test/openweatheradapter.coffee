require('chai').should()
Q = require 'q'
_ = require 'lodash'

OpenWeather =
  api:      require('../src/openweather/api.coffee')
  adapter:  require('../src/openweather/adapter.coffee')

API_KEY = 'a54b75e2c789e0f2bd076f5eb6c28b31'
describe 'structure', ->
  it 'should get forecasts of a city', ->
    adapter = new OpenWeather.adapter new OpenWeather.api()
    adapter.config api_key:API_KEY, unit:'metric', count: 2
    adapter.get_forecasts('tehran')
      .then (results) ->
        results.should.have.length 3


  it 'should get forecasts of a location', ->
    adapter = new OpenWeather.adapter new OpenWeather.api()
    adapter.config api_key:API_KEY, unit:'metric', count: 4
    adapter.get_forecasts('tehran')
      .then (results) ->
        results.should.have.length 5


