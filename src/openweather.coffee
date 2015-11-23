Q = require 'q'
_ = require 'lodash'
querystring = require 'querystring'
request = require 'request'
http = require 'http'

module.exports =  class OpenWeather
    DEFAULTS:
      hostname:'api.openweathermap.org'
      port: 80

    CONFIGS:
      data_path: '/data/2.5/'

    options:
      lang: 'en'
      units: 'metric'
      mode: 'json'

    config: (options) ->
      @options = _.merge @options, options

    _make_request: (options, endpoint) ->
      req = _.clone @DEFAULTS
      query = querystring.stringify _.merge @options, options
      req.path = "http://#{req.hostname}:#{req.port}#{@CONFIGS.data_path}#{endpoint}?#{query}"
      req

    _send_request: (req) ->
      Q.nfcall(request, req.path)
        .then (res) ->
          status = res[0].statusCode
          return JSON.parse res[0].body if status is 200
          new Error res[0].body

    current: (options) ->
      req = @_make_request options, "weather"
      @_send_request req
       
    forecast: (options) ->
      req = @_make_request options, "forecast/daily"
      @_send_request req
