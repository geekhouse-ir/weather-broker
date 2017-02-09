(function() {
  var Adapter, Q, _;

  Q = require('q');

  _ = require('lodash');

  module.exports = Adapter = (function() {
    function Adapter(api) {
      this.api = api;
    }

    Adapter.prototype.config = function(options) {
      return this.api.config(Adapter.adapt(options));
    };

    Adapter.prototype.get_forecasts = function(location, count) {
      return Q.allSettled([this.api.get_current(location), this.api.get_forecasts(location)]).then((function(_this) {
        return function(response) {
          return Adapter.mask(response);
        };
      })(this));
    };

    Adapter.adapt = function(options) {
      return {
        appid: options.api_key ? options.api_key : void 0,
        unit: options.unit != null ? options.unit : void 0,
        cnt: options.count != null ? options.count : void 0
      };
    };

    Adapter.mask = function(response) {
      var current, current_raw, forecasts, forecasts_raw;
      current_raw = response[0].value;
      forecasts_raw = response[1].value;
      forecasts_raw = forecasts_raw.list != null ? forecasts_raw.list : forecasts_raw.List;
      if (current_raw instanceof Error) {
        return current_raw;
      }
      if (forecasts_raw instanceof Error) {
        return forecasts_raw;
      }
      current = {
        location: current_raw.coord,
        timestamp: current_raw.dt,
        temp: current_raw.main.temp,
        brief: current_raw.weather[0].main,
        description: current_raw.weather[0].description,
        icon: current_raw.weather[0].icon
      };
      forecasts = _.map(forecasts_raw, function(raw) {
        return {
          timestamp: raw.dt,
          temp: raw.temp.day,
          brief: raw.weather[0].main,
          description: raw.weather[0].description,
          icon: raw.weather[0].icon
        };
      });
      return _.union([current], forecasts);
    };

    return Adapter;

  })();

}).call(this);
