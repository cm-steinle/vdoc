<%@ page contentType="text/html; charset=ISO-8859-1"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
// <!--%@include file="vdocforcelogin.jsp"%-->
// <!--%@include file="vdocbean.jsp"%-->
String parentID = request.getParameter("id");
parentID = (parentID == null) ? "" : "?only=" + parentID; %>
<html>
<head>
	<title>VDir Menu</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<link rel="stylesheet" href="vdoc.css">
<script language="JavaScript1.2" type="text/javascript">
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
<body leftmargin=0 marginwidth=0 topmargin=0 marginheight=0 bgcolor="#CECECE"> 
<applet
      width="100%" 
      height="90%"
      codebase="java"
      code="com.scand.jtree.TreeApplet.class"
      archive="jtree.jar"
      name="MyTree" 
      MAYSCRIPT>
<param name=XML value="vdocdata2.jsp<%= parentID %>">    
Sie haben leider keinen Java-f&amp;aauml;higen Browser
</applet>
<form target="list">
	<input type=hidden name=id value="">
	<input type=hidden name=pkey value="">
	<input type=hidden name=what value="">
</form>
</body>
</html>
