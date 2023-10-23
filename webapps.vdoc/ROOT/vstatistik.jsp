<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<%@include file="vdocbase.jsp"%>
<%!//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
//final boolean TRACE = false;
//============================================================================%>
<%
//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
//db.setTrace(TRACE);
String userPKEY = (String) session.getAttribute("userpkey");
String pkey = request.getParameter("pkey");
String typeSuch = "Suchen";
String typeText = "Selectionskriterien festlegen";
String textDir  = db.getWERT(pkey,"DIR");
ResultSet rs = null;
typeInit(pkey);
//------------------------------------------------------------------------------
//	H T M L
//------------------------------------------------------------------------------
%>
<!doctype html>
<html>
<head>
	<title><%=typeText%></title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<link rel="stylesheet" href="vdoc.css">	
</head>
<body>
<table width="100%" border="1">
<tr><th colspan="2">VDoc / VDir Statistik</th></tr>
<% rs = db.getSQLRO("SELECT TYPE, COUNT(*) AS ZAHL from VDOCDIR GROUP BY TYPE");
while (rs.next()){
String type = rs.getString("TYPE");
if (type.equals("D")){
	type = "VDoc-Verzeichnisse";
} else if (type.equals("F")){
	type = "VDoc-Dokumente";
} else if (type.equals("V")){
	type = "VDir-Verzeichnisse";
} else if (type.equals("W")){
	type = "VDir-Dokumente";
}
%>
<tr>
<td><%= type %></td>
<td width="40" align="right" nowrap><%= rs.getString("ZAHL")%></td>
</tr>
<%}
rs.close();
%>
</table>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>