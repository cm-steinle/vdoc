<!DOCTYPE html>
<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%
String parentID = request.getParameter("id");
parentID = (parentID == null) ? "?id=0" : "?only=" + parentID; 
%>
<html ng-app="myTreeViewApp">
<head>
	<title>VDir Menu</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
  
  <script src="js/ng/angular.min.js"></script>
  <script src="js/ng/treeview/angular.treeview.js"></script>
  <link  href="js/ng/treeview/css/angular.treeview.css"  rel="stylesheet" type="text/css" >
	<link rel="stylesheet" href="vdoc.css">
<script type="text/javascript">
var myTreeViewApp = angular.module('myTreeViewApp', ['angularTreeview']);

myTreeViewApp.controller("myTreeViewCtrl", function($scope, $http){
  
  $scope.loaddata = function(pkey, target){ //id=36532&
    if (! target) {
      $scope.treedata = [];
      return $scope.loaddata(pkey, $scope.treedata);
    }
//    alert("ParentID=" + pkey);
//    $http.get('vdocdata2.jsp' + pkey).success(function(treedata){
      $http.get('vdirdata.jsp' + pkey).success(function(treedata){
      var treepart = treedata.trim();
      var elem = angular.element(treepart);
//      console.log(elem);
      var tmp = [];
      angular.forEach(elem, function(val, key){
        if (val.id){
          var value = angular.element(val);
          var data = {};
          data.id = value.attr('id');
          data.label = value.attr('text');
          data.childs = (value.attr('child')) ? true : false;
          data.children = [];
//          console.log(data);
          target.push(data);
        }
      }, tmp);
    });     
  };
  
  $scope.$watch( 'abc.currentNode', function( newObj, oldObj ) {
    if( $scope.abc && angular.isObject($scope.abc.currentNode) ) {
      var pkey = $scope.abc.currentNode.id;
      if ($scope.abc.currentNode.childs && $scope.abc.currentNode.children.length == 0){
         $scope.loaddata('?id=' + pkey, $scope.abc.currentNode.children);
      } else TreeSel(1, pkey);
//       console.log( 'Node Selected!!' );
//       console.log( $scope.abc.currentNode );
    }
  }, false);

});
</script>
<script>
  function TreeSel(l, s) {
    var f = document.forms[0];
    if (l == 0) {
      f.action = "vdircomp.jsp?pkey=" + s;
    } else {
      if (l == 1) {
        f.action = "vdoclist.jsp";
      } else {
        return;
      }
    }
    f.id.value = s;
    f.pkey.value = s;
    f.what.value = "vdir";
    f.submit();
  }
</script>

</head>
<body ng-controller="myTreeViewCtrl" ng-init="loaddata('<%= parentID %>')" leftmargin=0 marginwidth=0 topmargin=0 marginheight=0 bgcolor="#CECECE">
<!--     <div style="margin:10px 0 30px 0; padding:10px; background-color:#EEEEEE; border-radius:5px; font:12px Tahoma;">
      <span><b>Selected Node</b> : {{abc.currentNode.id}} {{abc.currentNode.label}}</span>
    </div> -->
<div
    data-angular-treeview="true"
    data-tree-id="abc"
    data-tree-model="treedata"
    data-node-id="id"
    data-node-label="label"
    data-node-children="children" >
</div>

<form target="list">
  <input type=hidden name=id value="">
  <input type=hidden name=pkey value="">
  <input type=hidden name=what value="">
</form>

</body>
</html>
