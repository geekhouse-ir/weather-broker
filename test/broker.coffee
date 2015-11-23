require('chai').should()
_ = require 'lodash'
Q = require 'q'
describe 'structure', ->
  context 'if no options passes', ->
    wb = require('../src/broker.coffee')
      resources:
        openweather:
          appid: 'a54b75e2c789e0f2bd076f5eb6c28b31'

    it 'should return singleton instance', ->
      wb.options.test = 'test'
      another_wb = require('../src/broker.coffee') {}
      wb.should.be.eq another_wb
      another_wb.options.test.should.be.equal wb.options.test
      delete wb.options.test

    it 'should have options with default values', ->
      wb.should.have.property 'options'
      wb.options.general.should.have.property 'unit'

    it 'should have unit property', ->
      wb.should.have.property 'units'

    it 'should not config if options are invalid'

    it 'should set options using config method', ->
      wb.options.general.unit.should.be.equal 'metric'
      wb.config
        general:
          unit: wb.units.imperial
      wb.options.general.unit.should.be.equal 'imperial'

      wb.config
        general:
          unit: wb.units.metric
      wb.options.general.unit.should.be.equal 'metric'

    it 'should reject config if options is invalid', ->
      wb.config
        invalid: true
      wb.options.should.not.have.property 'invalid'

    it 'should set resource options', ->
      key= 'a key'
      wb.config
        resource:
          api:
            name: 'openweather'
            key: key
      wb.config.resource?.api?.key?.should.be.equal key

    it 'should get by city', ->
      cnt = 1
      wb.forecast_by_city('tehran', cnt:cnt)
        .then (res) ->
          res.should.have.length cnt + 1
        .done()
    it 'should get by city and options'
    it 'should get by city and country'
    it 'should get by city and country and options'
    it 'should not change general options after using custom options'
    it 'should find by location', ->
      cnt = 5
      wb.forecast_by_location({lat:35, lon:139}, {unit: "imperial", cnt: cnt})
        .then (res) ->
          res.should.have.length cnt+1
    it 'should find by location and custom option'

describe 'weather', ->
  it 'should give current forcast'
  it 'should give three days forcast'
