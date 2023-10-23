<!DOCTYPE html>
<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%
String parentID = request.getParameter("id");
parentID = (parentID == null) ? "?id=0" : "?only=" + parentID; 
%>
<html ng-app="myTreeView">
<head>
	<title>VDir Menu</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
  <link rel="stylesheet" href="js/jq/jstree/themes/default/style.min.css" />
	<link rel="stylesheet" href="vdoc.css">
<script language="JavaScript" type="text/javascript">
function TreeSel(l,s) {
	var f = document.forms[0];
	if (l==0){
		f.action="vdircomp.jsp?pkey=" + s;  
	} else {
		if (l==1)	{
			f.action="vdoclist.jsp";
		} else {return;}
	}
	f.id.value = s; 
	f.pkey.value = s; 
	f.what.value = "vdoc"; 
	f.submit();
}

function XonMenu(id, menuId) {
	var tree = document.applets.MyTree;
	if (menuId==0)
		tree.expandAllChildren(id);
	if (menuId==1)
		tree.collapseAllChildren(id);
	if (menuId==3)
		tree.deleteItem(id);
}

function onmenupre(nodeId, popupMenu){ 
	var treeApplet = document.applets.MyTree; 
	// alert(nodeId + " # " + popupMenu);
	// Set 'disabled' flag for all menu items
	popupMenu.setEnable(0, false);
	popupMenu.setEnable(1, false);
	popupMenu.setEnable(3, false);
	if (nodeId==null) {
		// Mouse click not at node area. Identifier of item is null. Leave all items disabled.
		return;
	} else {
	// Getting the type of node - terminal or not. Emty list of children items corresponding to terminal node
		var isTerminal = (treeApplet.getSubItems(nodeId) == '');
		if (isTerminal) {
			// Set 'enabled' flag for 'Delete item' menu item
			popupMenu.setEnable(3, true);
		} else {
			// Getting the state of openable item:
			var isOpened = treeApplet.isOpen(nodeId);
			if (isOpened)
				popupMenu.setEnable(1, true); // set enable for 'Close' point
			else
				popupMenu.setEnable(0, true); // set enable for 'Open' point
		}
	}
}
function onMenu(id, menuId)
   {
      var tree = document.applets.MyTree;

      if (menuId==0)
      {
         tree.openItem(id);
      }
      else
      {	
				TreeSel(0,id);
        // tree.deleteItem(id);  
      }

   }

function loadMenu(id, menu)
   {  
	      var tree = document.applets.MyTree;
	
	      menu.removeAll();
	 		if (top.currentAdmin) {
	      menu.addString("Open/close");
	    //  menu.addSeparator();
	    //  menu.addString("mit Server vergleichen");
			}
     // if (tree.getSubItems(id)=="")
     //    menu.setEnable(0, false);
   }                          
</script>            
</head>
<body ng-controller="MainCtrl" ng-init="loaddata()" leftmargin=0 marginwidth=0 topmargin=0 marginheight=0 bgcolor="#CECECE">

  <div id="jstree">
    <!-- in this example the tree is populated from inline HTML -->
    <ul>
      <li>Root node 1
        <ul>
          <li id="child_node_1">Child node 1</li>
          <li>Child node 2</li>
        </ul>
      </li>
      <li>Root node 2</li>
    </ul>
  </div>
  <button>demo button1</button>
  <button>demo button2</button>
  
<hr>
<!-- tree={{ treepart }} -->

<!-- <js-tree tree-data="html" tree-src="vdocdata2.jsp?id=36532"></js-tree> -->
<js-tree tree-data="scope" tree-model="daten" id="treevdoc"></js-tree>

<form target="list">
	<input type=hidden name=id value="">
	<input type=hidden name=pkey value="">
	<input type=hidden name=what value="">
</form>


<script src="js/jq/jquery-2.1.4.min.js"></script>
<script src="js/jq/jstree/jstree.min.js"></script>
<script src="js/ng/angular.min.js"></script>
<script src="js/jq/jstree/jsTree.directive.js"></script>

<script>
var myTreeView = angular.module('myTreeView', ['jsTree.directive']);

myTreeView.controller('MainCtrl', function($scope, $http) {
  $scope.loaddata = function(){ //id=36532&
    $http.get('vdocdata2.jsp<%= parentID %>').success(function(treedata){
      $scope.treepart = treedata.trim()/* .replace('\r\n','') */;
      var elem = angular.element($scope.treepart);
      console.log(elem);
      var tmp = [];
      angular.forEach(elem, function(val, key){
        if (val.id){
          var value = angular.element(val);
          console.log(value);
          var child = value.attr('child');
          var data = {};
          data.id = value.attr('id');
          data.text = value.attr('text');
          data.children = true;
          data.type = "root";
        	this.push(data);
        }
      }, tmp);
      $scope.daten = tmp;
    });     
  };
});

// .controller('AjaxCtrl', ['$scope',
//   function($scope) {
// //		$scope.loaddata();
//   }
// ]);
</script>

<script>
$(function () {
  $.jstree.defaults.core.themes.variant = "small";
  // 6 create an instance when the DOM is ready
  $('#jstree').jstree();
  // 7 bind to events triggered on the tree
  $('#treevdoc').on("changed.jstree", function (e, data) {
    console.log(data.selected);
  });
  $('#jstree').on("changed.jstree", function (e, data) {
    console.log(data.selected);
  });
  // 8 interact with the tree - either way is OK
  $('button').on('click', function () {
    $('#jstree').jstree(true).select_node('child_node_1');
    $('#jstree').jstree('select_node', 'child_node_1');
    $.jstree.reference('#jstree').select_node('child_node_1');
  });
  
});
</script>

</body>
</html>
