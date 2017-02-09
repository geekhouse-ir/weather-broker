Q = require 'q'
_ = require 'lodash'

module.exports = class Adapter
  constructor: (@api) ->

  config: (options) ->
    @api.config Adapter.adapt options

  get_forecasts: (location, count) ->
    Q.allSettled([@api.get_current(location), @api.get_forecasts(location)])
      .then (response) =>
        Adapter.mask response

  @adapt: (options) ->
    {
      appid: options.api_key if options.api_key
      unit: options.unit if options.unit?
      cnt: options.count if options.count?
    }

  @mask: (response) ->
    current_raw = response[0].value
    forecasts_raw = response[1].value
    forecasts_raw = if forecasts_raw.list?
      forecasts_raw.list
    else
      forecasts_raw.List
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
