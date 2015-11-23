_     = require 'lodash'
Joi   = require 'joi'
Q     = require 'q'
mask  = require 'json-mask'

openweather = require './openweather'

class Broker
  RESOURCES:
    openweather: 'openweather'

  UNITS:
    metric: "metric"
    imperial: "imperial"

  DEFAULTS:
    general:
      unit: Broker::UNITS.metric
      cnt: 1
    cache:
      host: "127.0.0.1"
      port: 6379

    resources:
      openweather:
        appid: ''
 
  @get: (options) ->
    @_instance ?= new @ options

  @validate_options: (options) ->
    schema = Joi.object().keys
      general: Joi.object()
      resources: Joi.object()
    Joi.validate options, schema, (err, value) ->
      not err?

  @set_options: (instance, options) ->
    _.merge instance.options, options if @validate_options options

  @masks:
    openweather: (response) ->
      current_raw = response[0].value
      forecasts_raw = response[1].value.list
      return current_raw if current_raw instanceof Error
      return forecasts_raw if forecasts_raw instanceof Error
      current =
        location: current_raw.coord
        timestamp: current_raw.dt
        temp: current_raw.main.temp
        brief: current_raw.weather[0].main
        description: current_raw.weather[0].description
        icon: current_raw.weather[0].icon

      forecasts = _.map forecasts_raw, (raw) ->
          timestamp: raw.dt
          temp: raw.temp.day
          brief: raw.weather[0].main
          description: raw.weather[0].description
          icon: raw.weather[0].icon
      
      _.union [current], forecasts

  units: @::UNITS
  options: @::DEFAULTS

  constructor: (options) ->
    @config options
    @redis.on 'connect', -> console.log 'connected'

  config: (options) ->
    Broker.set_options @, options if options?
    @redis = require('redis').createClient @options.cache.port, @options.cache.host

  build_options: (options, resource) ->
    _.merge @options.general, @options.resources["#{resource}"], options

  select_resource: (location) ->
    Broker::RESOURCES.openweather

  forecast_by_city: (city, options={}) ->
    resource = @select_resource city
    country = {} unless typeof country is 'string'
    options = @build_options( options, resource)
    options.q = city
    ow = new openweather()
    Q.allSettled([ow.current(options), ow.forecast(options)])
      .then (results) =>
        Broker.masks[resource] results

  forecast_by_location : (location, options={}) ->
    resource = @select_resource location
    options = @build_options( options, resource)
    options.lat = location.lat
    options.lon = location.lon
    ow = new openweather()
    Q.allSettled([ow.current(options), ow.forecast(options)])
      .then (results) ->
        Broker.masks[resource] results

module.exports = (options={}) ->
  Broker.get options
