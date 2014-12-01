#= require_tree .

app = angular.module 'WeatherApp', [ 'ngMaterial' ]

app.factory "Notifier", ($rootScope, $mdToast) ->
  $rootScope.$on "toast", (event, msg, working) ->
    console.log msg, working
    $rootScope.working = working
    $rootScope.status = msg
    # @toast.resolve() if @toast
    # @toast = $mdToast.simple().content(msg).position( "top right").hideDelay( 2[000, ").action('OK')"],
    # console.log @toast
    # $mdToast.show @toast 

  notify = (msg, done) ->
    $rootScope.$broadcast( "toast", msg, done )

  {notify: notify }

app.factory "IPLocation", ($q, $http, Notifier) ->
  my_location = undefined 
  location = ->
    return $q.when( my_location ) if my_location
    result = $q.defer()

    Notifier.notify "Location by IP", true
    $http.jsonp( "http://freegeoip.net/json/?callback=JSON_CALLBACK" ).success (data) ->
      Notifier.notify "Got location by IP", false
      my_location = data
      console.log( data )
      result.resolve( my_location )
    return result.promise

  { location: location }

app.factory "HTML5Location", ($q, Notifier) ->
  location = ->
    result = $q.defer()
    if navigator.geolocation
      Notifier.notify "Looking up HTML5 location", true
      navigator.geolocation.getCurrentPosition(
        (position) ->
          Notifier.notify "Got HTML5 location", false
          console.log( position )
          result.resolve( position )
        (err) ->
          Notifier.notify "User blocked HTML5 location", false
          result.reject( "Rejected" )
      )
    else
      Notifier.notify "No HTML5 location available", false
    result.promise

  { location: location }

app.factory "Location", ($q, HTML5Location, IPLocation, Notifier) ->
  location = ->
    result = $q.defer()

    Notifier.notify "Looking up location", true
    HTML5Location.location().then(
      (position) -> 
        result.resolve lat: position.coords.latitude, lng:position.coords.longitude;
      (data) ->
        IPLocation.location().then (data) ->
          result.resolve lat: data.latitude, lng: data.longitude
    )
    result.promise

  { location: location }

app.factory "Weather", ($q, $http, Notifier) ->
  lookup_by_lat_long = (lat, lng) ->
    Notifier.notify "Looking up weather", true
    result = $q.defer()

    url = "http://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lng + "&callback=JSON_CALLBACK"
    $http.jsonp( url ).success (data) ->
      Notifier.notify "Found weather", false
      result.resolve data

    result.promise

  lookup_by_location = (location) ->
    Notifier.notify "Looking up weather for " + location, true

    result = $q.defer()
    url = "http://api.openweathermap.org/data/2.5/weather?q=" + location + "&callback=JSON_CALLBACK"
    $http.jsonp( url ).success (data) ->
      Notifier.notify "Found weather", false
      result.resolve data

    result.promise

  lookup_by_lat_long: lookup_by_lat_long
  lookup_by_location: lookup_by_location

DialogController = ($scope, $mdDialog) ->
  $scope.hide = ->
    $mdDialog.hide()

  $scope.cancel = ->
    $mdDialog.cancel()

  $scope.answer = (answer)->
    $mdDialog.hide(answer);

app.controller "WeatherCntl", ( $scope, $mdToast, $mdDialog, Location, Weather ) ->
  $scope.reports = []
  $scope.location = ""

  new_report = (lat, lng) ->
    report = {lat: lat, lng: lng}
    Weather.lookup_by_lat_long(lat, lng).then (data)->
      console.log data
      report.data = data
      report.weather = data['weather'][0]
    
    $scope.reports.push(report)

  $scope.lookupLocation = ->
    console.log $scope.location
    report = {location: $scope.location }
    $scope.location = ""
    Weather.lookup_by_location( report.location ).then (data) ->
      console.log data
      report.data = data
      report.weather = data['weather'][0]
      report.lat = data.coord.lat
      report.lng = data.coord.lon
      console.log report.weather

    $scope.reports.push( report )

  $scope.findLocation = ->
    Location.location().then (data) ->
      $scope.location = data
      new_report( data['lat'], data['lng'] )

  $scope.showAbout = (ev) ->
    $mdDialog.show
      controller: DialogController,
      templateUrl: 'about.tmpl.html',
      targetEvent: ev,
    .then (answer) ->
      $scope.alert = 'You said the information was "' + answer + '".';
    , ->
      $scope.alert = 'You cancelled the dialog.';


lookup_codes = {
  200: 'storm-showers'
  201: 'thunderstorm'
  202: 'thunderstorm'
  210: 'storm-showers'
  211: 'thunderstorm'
  212: 'thunderstorm'
  221: 'thunderstorm'
  230: 'storm-showers'
  231: 'storm-showers'
  232: 'thunderstorm'
  300: 'sprinkles'
  301: "sprinkles"
  302: "sprinkle"
  310: "showers"
  311: "showers"
  312: "showers"
  313: "showers"
  314: "showers"
  321: "showers"
  500: "rain"
  501: "rain"
  502: "rain"
  503: "rain"
  504: "rain-mix"
  511: "rain-mix"
  520: "rain-mix"
  521: "rain-mix"
  522: "rain-mix"
  531: "rain-mix"
  600: "snow"
  601: "snow"
  602: "snow"
  611: "hail"
  612: "hail"
  615: "hail"
  616: "rain-mix"
  620: "rain-mix"
  621: "snow"
  622: "snow"
  701: "fog"
  711: "smoke"
  721: "dust"
  731: "dust"
  741: "fog"
  751: "dust"
  761: "dust"
  762: "strong-wind"
  771: "tornado"
  781: "tornado"
  800: "day-sunny"
  801: "day-cloudy"
  802: "day-sunny-overcast"
  803: "day-sunny-overcast"
  804: "day-sunny-overcast"
  900: "tornado"
  901: "hurricane"
  902: "hurricane"
  903: "snowflake-cold"
  904: "hot"
  905: "windy"
  906: "hail"
  951: "moon-full"
  952: "fog"
  953: "fog"
  954: "fog"
  955: "cloudy-windy"
  956: "cloudy-gusts"
  957: "strong-wind"
  958: "cloud-refresh"
  959: "cloud-refresh"
  960: "tornado"
  961: "tornado"
  962: "hurricane"
}

app.directive 'weatherIcon', ->
  restrict: 'E'
  replace: true
  scope: code: '@'
  template: '<i class="wi wi-{{ key }}"></i>'
  controller: ($scope) ->
    $scope.$watch "code", (new_val,old_val) ->
      console.log( "code", new_val )
      $scope.key = lookup_codes[new_val]

