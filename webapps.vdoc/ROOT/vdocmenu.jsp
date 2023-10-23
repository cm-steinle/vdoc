<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<%
String pkey = request.getParameter("pkey");
String tree = request.getParameter("tree");
String type = request.getParameter("type");
if (pkey == null) pkey = "0";
tree = "&tree=" + ((tree == null) ? "n" : tree);
type = "&type=" + ((type == null) ? "*" : type);
%>
<html>
<head>
	<title>VDoc Menu</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<link rel="stylesheet" href="vdoc.css"> 
</head>
<% if (pkey !="0") { %>
<%=pkey%>
<jsp:include page="servlet/VDocTree" flush="true">
	<jsp:param name="vers" value="k"/>
	<jsp:param name="pkey" value="<%=pkey%>"/>
</jsp:include>
<%}%>
<body leftmargin=0 marginwidth=0 topmargin=0 marginheight=0 bgcolor="#FFFFFF">
<applet 
      width="100%" 
      height="99%"
      codebase="java"
	  code="TreeView.class">
<param name="expand" value="1">
<param name="target" value="list">
<param name="bgcolor" value="FFFFFF">
<param name="hifont" value="SansSerif,11,bold">
<param name="lofont" value="SansSerif,11">
<param name="data" value="
<%= db.VDocTree("0","",99,"D") %>">
<param name="DUMMYfile" value="/servlet/VDocTree?vers=t&pkey=<%=pkey%><%=tree%><%=type%>">
Sie haben leider keinen Java-f&amp;aauml;higen Browser
</applet>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>
