require('chai').should()
Q = require 'q'
_ = require 'lodash'

API_KEY = 'a54b75e2c789e0f2bd076f5eb6c28b31'

wb = require('../src/main.coffee')
  provider: 'openweather'
  api_key: API_KEY
  unit: 'metric'
  count: 4
  cache:
    host: '127.0.0.1'
    port: 6379

describe 'structure', ->
  it 'should get broker', ->
    wb.config unit: 'imperial', count: 1
    wb.get_forecasts('tehran')
      .then (res) ->
        res.should.have.length 2
