angular.module('contextMenu', [])

angular.module('contextMenu')
  .service('contextService', contextService)

function contextService() {

  var service = {
    targetMenu: null,
    targetElement: null
  }

  return service;
}

angular.module('contextMenu')

.directive('contextMenu', contextMenu);

contextMenu.$inject = ['$log','$document','$window','contextService'];

function contextMenu($log,$document,$window,contextService) {

  var directive = {
    restrict: 'A',
    scope: false,
    link: _link
  }

  return directive;

  function _link(scope, elem, attrs) {

    // exit if contextmenu attribute is empty
    if( !attrs.contextMenu ) {
      $log.warn('contextMenu: Empty context menu name on element: ', elem)
      return
    }

    // exit if document don't contain
    // the context menu that user specified
    // hk2015
    // CROSS-BROWSER NOTE: the document object in IE does not have a contains() method - 
    // to ensure cross-browser compatibility, use document.body.contains() instead
    if( !$document[0].body.contains(document.getElementById(attrs.contextMenu)) ) {
      $log.warn('contextMenu: The context menu id: '+ attrs.contextMenu +' does not exist!')
      return
    }

    // get document element
    var doc = $document[0].documentElement;
    // get context menu element
    var $context = angular.element(document.getElementById(attrs.contextMenu));

    // assign position
    $context.css('position', 'fixed');
    // hide element
    $context.addClass('ng-hide');

    // prevent right click on context menu
    $context.bind('contextmenu', function(e) { e.preventDefault(); })

    // close when click on itself
    $context.bind('click', function(e) {
      return close();
    })
    
    // hk
    $context.bind('mouseleave', function(e) {
      return close();
    })
    // hk
    elem.on('contextmenu', function(e) {
      e.preventDefault();
    })


    // override default contextmenu event to element
//    elem.on('contextmenu', function(e) {
    // hk
    elem.on('click', function(e) {
      e.preventDefault();
      // open contextmenu with click positions passed
      open( e.target, e.pageX, e.pageY );
    })

//    // close contextmenu if (left) click on element
//    elem.bind('click', function(e) {
//      return close();
//    })

//    // bind (left) click on document / hide context menu
//    $document.bind('click', function(e) {
//      if( e.target != contextService.targetMenu && scope.isOpen ) close();
//    })

    // open context menu
    function open(target, posX, posY) {

      // if another context is open hide it
      // before open a new one
      if( contextService.targetMenu && contextService.targetMenu != $context ) {
        contextService.targetMenu.addClass('ng-hide');
      }

      // show element
      $context.removeClass('ng-hide');

      // enable open flag
      scope.isOpen = true;

      // get element measures
      var elWidth = $context[0].clientWidth;
      var elHeight = $context[0].clientHeight;

      // calculate position from window offsets
      var docTop = (window.pageYOffset || doc.scrollTop) - (doc.clientTop || 0);
      var docLeft = (window.pageXOffset || doc.scrollLeft) - (doc.clientLeft || 0);

      // set right posX
      if( (posX + elWidth) >= $window.innerWidth ) {
        posX = posX - elWidth;
      }

      // set right posY
      if( (posY + elHeight) >= $window.innerHeight ) {
        posY = posY - elHeight;
        if (posY < 0) posY = 10; // hk20160204
      }

      // add style
      $context.css('left', (posX-docLeft-10) + 'px');
      $context.css('top', (posY-docTop-10) + 'px');

      // remove hide class
      // set current service targets
      contextService.targetElement = elem;
      contextService.targetMenu = $context;
    }

    // close context menu
    // clear service targets
    function close() {

      // hide element
      $context.addClass('ng-hide');

      // remove open flag
      scope.isOpen = false;

      // clear service targets
      contextService.targetMenu = null;
      contextService.targetElement = null;
    }
  }

}
