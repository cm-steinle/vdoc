<%@ page contentType="text/html; charset=ISO-8859-1"%>
<!doctype html>
<html ng-app="ui.bootstrap.demo">
<head>
<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
<script src="js/ng/angular.min.js"></script>
<script src="js/ng/angular-animate.min.js"></script>
<script src="js/ng/ui-bootstrap-tpls-0.14.3.js"></script>
<link rel="stylesheet" href="js/ng/bootstrap.min.css">
</head>
<body ng-app leftmargin=0 marginwidth=0 topmargin=0 marginheight=0 style="background-color: silver;">
<div ng-controller="TabsCtrl">
<uib-tabset>
  <uib-tab heading="VDoc"      select="tabSwitch('treemenu.jsp?what=vdoc' )"></uib-tab>
<% String usertype = (String) session.getAttribute("usertype");
if (usertype.equals("X")) { %>
  <uib-tab heading="VDir"      select="tabSwitch('treemenu.jsp?what=vdir')"></uib-tab>
  <uib-tab heading="Abt."      select="tabSwitch('treemenu.jsp?what=user')"></uib-tab>
  <uib-tab heading="Statistik" select="tabSwitch('vstatistik.jsp')"></uib-tab>
<%}%>
</uib-tabset>
</div>

<script language="JavaScript" type="text/javascript">
angular.module('ui.bootstrap.demo', ['ngAnimate', 'ui.bootstrap']);
angular.module('ui.bootstrap.demo').controller('TabsCtrl', function ($scope, $window) {
  $scope.tabs = [];
  $scope.alertMe = function() {
    setTimeout(function() {
      $window.alert('Sie haben Alert selectiert');
    });
  };

  $scope.tabSwitch = function(url) {
    setTimeout(function() {
      tabSwitch(url);
    });

  };
});
function tabSwitch(v)
{ if (v == "#") return;
   parent.frames.menu.location = v;
}
</script>
</body>
</html>
