(function() {
  var Api, Q, _, querystring, request;

  Q = require('q');

  _ = require('lodash');

  querystring = require('querystring');

  request = require('request');

  module.exports = Api = (function() {
    function Api() {}

    Api.prototype.host = "http://api.openweathermap.org/data/2.5/";

    Api.prototype.paths = {
      current: Api.prototype.host + "weather",
      forecast: Api.prototype.host + "forecast/daily"
    };

    Api.prototype.options = {
      lang: 'en',
      units: 'metric',
      mode: 'json'
    };

    Api.prototype.config = function(options) {
      if (options != null) {
        this.options = _.merge(this.options, options);
      }
      return this.options;
    };

    Api.prototype.get_current = function(location, unit) {
      var deferred, options, path;
      options = _.clone(this.options);
      if (_.isString(location)) {
        if (_.isString(location)) {
          options.q = location;
        }
      } else {
        options.lat = location.lat;
        options.lon = location.lon;
      }
      if (unit != null) {
        options.unit = unit;
      }
      path = Api.prototype.paths.current + "?" + (querystring.stringify(options));
      deferred = Q.defer();
      request(path, function(error, response, body) {
        var result;
        if (error) {
          deferred.reject(error);
        }
        if (response.statusCode === 429) {
          setTimeout((function() {
            return new Api().get_forecasts(location, count, unit);
          }), 1000);
          return deferred.resolve;
        } else {
          result = JSON.parse(body);
          return deferred.resolve(result);
        }
      });
      return deferred.promise;
    };

    Api.prototype.get_forecasts = function(location, count, unit) {
      var deferred, options, path;
      options = _.clone(this.options);
      if (_.isString(location)) {
        if (_.isString(location)) {
          options.q = location;
        }
      } else {
        options.lat = location.lat;
        options.lon = location.lon;
        if (count != null) {
          options.cnt = count;
        }
      }
      ++options.cnt;
      if (unit != null) {
        options.unit = unit;
      }
      path = Api.prototype.paths.forecast + "?" + (querystring.stringify(options));
      deferred = Q.defer();
      request(path, function(error, response, body) {
        var results;
        if (error) {
          deferred.reject(error);
        }
        if (response.statusCode === 429) {
          setTimeout((function() {
            return new Api().get_forecasts(location, count, unit);
          }), 1000);
          return deferred.resolve;
        } else {
          results = JSON.parse(body);
          results.list = _.drop(results.list);
          return deferred.resolve(results);
        }
      });
      return deferred.promise;
    };

    return Api;

  })();

}).call(this);
