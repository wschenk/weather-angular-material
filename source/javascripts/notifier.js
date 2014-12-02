app.factory( "Notifier", function($rootScope, $mdToast) {
  $rootScope.$on( "toast", function(event, msg, working) {
    console.log( msg, working)
    $rootScope.working = working
    $rootScope.status = msg
    // # @toast.resolve() if @toast
    // # @toast = $mdToast.simple().content(msg).position( "top right").hideDelay( 2[000, ").action('OK')"],
    // # console.log @toast
    // # $mdToast.show @toast 
  } );

  var notify = function( msg, done ) {
    $rootScope.$broadcast( "toast", msg, done )
  }

  return { notify: notify }
} );
