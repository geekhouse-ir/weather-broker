require('chai').should()
Q = require 'q'
_ = require 'lodash'

Broker = require('../src/broker.coffee')
API_KEY = 'a54b75e2c789e0f2bd076f5eb6c28b31'

OpenWeather =
  api:      require('../src/openweather/api.coffee')
  adapter:  require('../src/openweather/adapter.coffee')

describe 'structure', ->
  it 'should get forecasts of a city', ->
    broker = new Broker
      provider: 'openweather'
      api_key: API_KEY
      unit: 'metric'
      count: 4
      cache:
        host: '127.0.0.1'
        port: 6379

    broker.get_forecasts('tehran')
      .then (res) ->
        res.should.have.length 5

  it 'should get forecasts of a location', ->
    broker = new Broker
      provider: 'openweather'
      api_key: API_KEY
      unit: 'metric'
      count: 4
      cache:
        host: '127.0.0.1'
        port: 6379

    broker.get_forecasts(lat: 55, lon: 66)
      .then (res) ->
        res.should.have.length 5

  it 'should config provider later', ->
    broker = new Broker
      provider: 'openweather'
      api_key: API_KEY
      cache:
        host: '127.0.0.1'
        port: 6379

    broker.config
      count: 2
    broker.get_forecasts('tehran')
      .then (res) ->
        res.should.have.length 3
