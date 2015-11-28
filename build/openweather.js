(function() {
  var OpenWeather, Q, _, http, querystring, request;

  Q = require('q');

  _ = require('lodash');

  querystring = require('querystring');

  request = require('request');

  http = require('http');

  module.exports = OpenWeather = (function() {
    function OpenWeather() {}

    OpenWeather.prototype.DEFAULTS = {
      hostname: 'api.openweathermap.org',
      port: 80
    };

    OpenWeather.prototype.CONFIGS = {
      data_path: '/data/2.5/'
    };

    OpenWeather.prototype.options = {
      lang: 'en',
      units: 'metric',
      mode: 'json'
    };

    OpenWeather.prototype.config = function(options) {
      return this.options = _.merge(this.options, options);
    };

    OpenWeather.prototype._make_request = function(options, endpoint) {
      var query, req;
      req = _.clone(this.DEFAULTS);
      query = querystring.stringify(_.merge(this.options, options));
      req.path = "http://" + req.hostname + ":" + req.port + this.CONFIGS.data_path + endpoint + "?" + query;
      return req;
    };

    OpenWeather.prototype._send_request = function(req) {
      return Q.nfcall(request, req.path).then(function(res) {
        var status;
        status = res[0].statusCode;
        if (status === 200) {
          return JSON.parse(res[0].body);
        }
        return new Error(res[0].body);
      });
    };

    OpenWeather.prototype.current = function(options) {
      var req;
      req = this._make_request(options, "weather");
      return this._send_request(req);
    };

    OpenWeather.prototype.forecast = function(options) {
      var req;
      req = this._make_request(options, "forecast/daily");
      return this._send_request(req);
    };

    return OpenWeather;

  })();

}).call(this);
