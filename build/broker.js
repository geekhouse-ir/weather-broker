(function() {
  var Broker, Joi, OpenWeather, Q, UNITS, _, mask;

  _ = require('lodash');

  Joi = require('joi');

  Q = require('q');

  mask = require('json-mask');

  OpenWeather = {
    adapter: require('./openweather/adapter'),
    api: require('./openweather/api')
  };

  UNITS = {
    metric: "metric",
    imperial: "imperial"
  };

  module.exports = Broker = (function() {
    Broker.prototype.units = UNITS;

    Broker.get = function(options) {
      return this._instance != null ? this._instance : this._instance = new this(options);
    };

    Broker.setup_cache = function(options) {
      Broker.redis = require('redis').createClient(options.port, options.host);
      return Broker.redis.on('connect', function() {});
    };

    function Broker(options) {
      if (options != null) {
        this.options = options;
      }
      this.provider = this.get_provider();
      if (this.provider instanceof Error) {
        return this.provider;
      }
      this.provider.config(this.options);
      Broker.setup_cache(this.options.cache);
    }

    Broker.prototype.config = function(options) {
      this.options = _.merge(this.options, options);
      return this.provider.config(this.options);
    };

    Broker.prototype.get_provider = function() {
      switch (this.options.provider) {
        case 'openweather':
          return new OpenWeather.adapter(new OpenWeather.api(this.options));
        default:
          return new Error("api is not supported");
      }
    };

    Broker.prototype.get_forecasts = function(location) {
      return this.provider.get_forecasts(location).then((function(_this) {
        return function(result) {
          return result;
        };
      })(this));

      /*
      cache_key = @cache_key location
      @get_cache(cache_key)
        .then (cache_result) =>
          return cache_result if cache_result?
          @provider.get_forecasts(location)
            .then (result) =>
              @set_cache cache_key, result
              result
       */
    };

    Broker.prototype.set_cache = function(key, value) {
      return Broker.redis.setex(key, 3600, JSON.stringify(value));
    };

    Broker.prototype.get_cache = function(key) {
      var deferred;
      deferred = Q.defer();
      Broker.redis.get(key, (function(_this) {
        return function(error, body) {
          var err, result;
          result = "";
          try {
            result = JSON.parse(body);
          } catch (error1) {
            err = error1;
            console.log(err, "<<<<err<<<<");
            console.log(JSON.parse("'" + body + "'"));
          }
          return deferred.resolve(result);
        };
      })(this));
      return deferred.promise;
    };

    Broker.prototype.cache_key = function(location) {
      if (!_.isString(location)) {
        location = location.lat + "_" + location.lon;
      }
      return location + ":" + this.options.count + ":" + this.options.unit;
    };

    return Broker;

  })();

}).call(this);
