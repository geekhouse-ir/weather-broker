_     = require 'lodash'
Joi   = require 'joi'
Q     = require 'q'
mask  = require 'json-mask'

OpenWeather =
  adapter: require './openweather/adapter'
  api: require './openweather/api'

UNITS =
    metric: "metric"
    imperial: "imperial"

module.exports = class Broker
  units: UNITS

  @get: (options) ->
    @_instance ?= new @ options
  
  @setup_cache: (options) ->
    Broker.redis =  require('redis').createClient options.port, options.host
    Broker.redis.on 'connect', -> console.log 'connected'

  constructor: (options) ->
    @options = options if options?
    @provider = @get_provider()
    return @provider if @provider instanceof Error
    @provider.config @options
    Broker.setup_cache @options.cache

  config: (options) ->
    @options = _.merge @options, options
    @provider.config @options

  get_provider:  ->
    switch @options.provider
      when 'openweather' then new OpenWeather.adapter new OpenWeather.api @options
      else
        new Error "api is not supported"

  get_forecasts: (location) ->
    cache_key = @cache_key location
    @get_cache(cache_key)
      .then (cache_result) =>
        return cache_result if cache_result?
        @provider.get_forecasts(location)
          .then (result) =>
            @set_cache cache_key, result
            result
  
  set_cache: (key, value) ->
    Broker.redis.setex key, 3600, JSON.stringify value

  get_cache: (key) ->
    deferred = Q.defer()
    Broker.redis.get key, (error, body) =>
      result = ""
      try
        result = JSON.parse body
      catch err
        console.log err, "<<<<err<<<<"
        console.log JSON.parse "'#{body}'"
      deferred.resolve result
    deferred.promise
  
  cache_key: (location) ->
   location = "#{location.lat}_#{location.lon}" unless _.isString location
   "#{location}:#{@options.count}:#{@options.unit}"
