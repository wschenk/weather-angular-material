app.factory("IPLocation", function($q, $http, Notifier) {
  var location, my_location;
  location = function() {
    var result;
    if (my_location) {
      return $q.when(my_location);
    }
    result = $q.defer();
    Notifier.notify("Location by IP", true);
    $http.jsonp("http://freegeoip.net/json/?callback=JSON_CALLBACK").success(function(data) {
      Notifier.notify("Got location by IP", false);
      my_location = data;
      console.log(data);
      return result.resolve(my_location);
    });
    return result.promise;
  };
  return {
    location: location
  };
});

app.factory("HTML5Location", function($q, Notifier) {
  var location;
  location = function() {
    var result;
    result = $q.defer();
    if (navigator.geolocation) {
      Notifier.notify("Looking up HTML5 location", true);
      navigator.geolocation.getCurrentPosition(function(position) {
        Notifier.notify("Got HTML5 location", false);
        console.log(position);
        return result.resolve(position);
      }, function(err) {
        Notifier.notify("User blocked HTML5 location", false);
        return result.reject("Rejected");
      });
    } else {
      Notifier.notify("No HTML5 location available", false);
    }
    return result.promise;
  };
  return {
    location: location
  };
});

app.factory("Location", function($q, HTML5Location, IPLocation, Notifier) {
  var location;
  location = function() {
    var result;
    result = $q.defer();
    Notifier.notify("Looking up location", true);
    HTML5Location.location().then(function(position) {
      return result.resolve({
        lat: position.coords.latitude,
        lng: position.coords.longitude
      });
    }, function(data) {
      return IPLocation.location().then(function(data) {
        return result.resolve({
          lat: data.latitude,
          lng: data.longitude
        });
      });
    });
    return result.promise;
  };
  return {
    location: location
  };
});