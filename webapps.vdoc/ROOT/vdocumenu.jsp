<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<html>
<head>
	<title>VDoc UserMenu</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<link rel="stylesheet" href="vdoc.css"> 
</head>
<body bgcolor="#FFFFFF">
<applet code="TreeView.class" codebase="java" width="100%" height="90%">
<param name="expand" value="1">
<param name="target" value="list">
<param name="bgcolor" value="FFFFFF">
<param name="hifont" value="SansSerif,11,bold">
<param name="lofont" value="SansSerif,11">
<param name="data" value="<%= db.VDocUser("0","",99,"A") %>">
Sie haben leider keinen Java-f&amp;aauml;higen Browser
</applet> 
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>
