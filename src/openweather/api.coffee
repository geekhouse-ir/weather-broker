Q = require 'q'
_ = require 'lodash'
querystring = require 'querystring'
request = require 'request'

module.exports =  class Api
  host:"http://api.openweathermap.org/data/2.5/"
  paths:
    current: "#{@::host}weather"
    forecast: "#{@::host}forecast/daily"

  options:
    lang: 'en'
    units: 'metric'
    mode: 'json'

  config: (options) ->
    @options = _.merge @options, options if options?
    @options

  get_current: (location, unit) ->
    options = _.clone @options
    if _.isString location
      options.q = location if _.isString location
    else
      options.lat = location.lat
      options.lon = location.lon
    options.unit = unit if unit?

    path = "#{Api::paths.current}?#{querystring.stringify options}"
    deferred = Q.defer()
    request path, (error, response, body) ->
      deferred.reject error if error
      deferred.resolve JSON.parse body
    deferred.promise

  get_forecasts: (location, count, unit) ->
    options = _.clone @options
    if _.isString location
      options.q = location if _.isString location
    else
      options.lat = location.lat
      options.lon = location.lon
      options.cnt = count if count?
    
    options.unit = unit if unit?

    path = "#{Api::paths.forecast}?#{querystring.stringify options}"
    deferred = Q.defer()
    request path, (error, response, body) ->
      deferred.reject error if error
      deferred.resolve JSON.parse body
    deferred.promise
