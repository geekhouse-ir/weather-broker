(function() {
  var Broker;

  Broker = require('./broker');

  module.exports = function(options) {
    return Broker.get(options);
  };

}).call(this);
