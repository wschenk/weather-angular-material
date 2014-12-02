app.factory("Weather", function($q, $http, Notifier) {
  var lookup_by_lat_long, lookup_by_location;
  lookup_by_lat_long = function(lat, lng) {
    var result, url;
    Notifier.notify("Looking up weather", true);
    result = $q.defer();
    url = "http://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lng + "&callback=JSON_CALLBACK";
    $http.jsonp(url).success(function(data) {
      Notifier.notify("Found weather", false);
      return result.resolve(data);
    });
    return result.promise;
  };
  lookup_by_location = function(location) {
    var result, url;
    Notifier.notify("Looking up weather for " + location, true);
    result = $q.defer();
    url = "http://api.openweathermap.org/data/2.5/weather?q=" + location + "&callback=JSON_CALLBACK";
    $http.jsonp(url).success(function(data) {
      Notifier.notify("Found weather", false);
      return result.resolve(data);
    });
    return result.promise;
  };
  return {
    lookup_by_lat_long: lookup_by_lat_long,
    lookup_by_location: lookup_by_location
  };
});