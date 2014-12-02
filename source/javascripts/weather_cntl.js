var DialogController;

DialogController = function($scope, $mdDialog) {
  $scope.hide = function() {
    return $mdDialog.hide();
  };
  $scope.cancel = function() {
    return $mdDialog.cancel();
  };
  return $scope.answer = function(answer) {
    return $mdDialog.hide(answer);
  };
};

app.controller("WeatherCntl", function($scope, $mdDialog, Location, Weather) {
  var new_report;
  $scope.reports = [];
  $scope.location = "";
  $scope.tabs = [ {selectIndex: 0}, {selectIndex: 0}, {selectIndex: 0}]

  $scope.changeTab = function( tab ) {
    console.log( "Change tab" );
    console.log( tab )
  }

  new_report = function(lat, lng) {
    var report;
    report = {
      lat: lat,
      lng: lng
    };
    Weather.lookup_by_lat_long(lat, lng).then(function(data) {
      console.log(data);
      report.data = data;
      report.weather = data['weather'][0];
      return report.selectedIndex = 0;
    });
    return $scope.reports.push(report);
  };
  $scope.lookupLocation = function() {
    var report;
    console.log($scope.location);
    report = {
      location: $scope.location
    };
    $scope.location = "";
    Weather.lookup_by_location(report.location).then(function(data) {
      console.log(data);
      report.data = data;
      report.weather = data['weather'][0];
      report.lat = data.coord.lat;
      report.lng = data.coord.lon;
      report.selectedIndex = 0;
      return console.log(report.weather);
    });
    return $scope.reports.push(report);
  };
  $scope.findLocation = function() {
    return Location.location().then(function(data) {
      $scope.location = data;
      return new_report(data['lat'], data['lng']);
    });
  };
  $scope.find_forecast = function(report) {
    console.log("Hello");
    console.log(report);
    return report.selectedIndex = this.$index;
  };
  return $scope.showAbout = function(ev) {
    return $mdDialog.show({
      controller: DialogController,
      templateUrl: 'about.tmpl.html',
      targetEvent: ev
    }).then(function(answer) {
      return $scope.alert = 'You said the information was "' + answer + '".';
    }, function() {
      return $scope.alert = 'You cancelled the dialog.';
    });
  };
});