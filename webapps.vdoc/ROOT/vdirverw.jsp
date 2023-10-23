<%@ page contentType="text/html; charset=ISO-8859-1"%>
<!--%@include file="vdocforcelogin.jsp"%-->
<%@include file="vdocbean.jsp"%>
<%@include file="vdocbase.jsp"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%!//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
//------------------------------------------------------------------------------
//	VDir eine Server-Dir/Doc zuordnen
//------------------------------------------------------------------------------
private void vdirSxAdd(String pkey, String svdir, String type, String puser){
	ResultSet rs = null;
	try {
		rs = db.getSQLRU("Select * from VDOCDIR where PKEY='" + pkey + "'");
		rs.first();
		if (!rs.getString("TYPE").equals("V")) {throw new Exception("Zugang nur zu einem VDir-Verzeichnis moeglich!");}
		if (!type.equals("V") && !type.equals("W")) {throw new Exception("Nur Dokumenttypen 'V'-Dir und 'W'-Doc sind zulaessig!");}
		rs.moveToInsertRow();
		rs.updateInt("PKEY",0);
		rs.updateString("CKEY",pkey);
		rs.updateString("DIR",svdir);
		rs.updateString("TEXT",svdir); 
		rs.updateString("TYPE",type);
		rs.updateString("CRTUSER",puser);
		rs.updateNull("CRTDATE"); // so wird automatisch das Datum kreiert
		rs.updateString("UPDUSER","0");
		rs.updateString("UPDDATE","0");
		rs.updateString("FRGUSER","0");
		rs.updateString("FRGDATE","0");
		rs.updateString("EXPUSER","0");
		rs.updateString("EXPDATE","0");
		rs.insertRow();
		rs.last();
		//ResultSet ri = db.getSQLRO("Select PKEY from VDOCDIR where CKEY='" + pkey + "' and DIR='" + rs.getString("DIR") + "'");
		//ri.first();
		//pkey = ri.getString("PKEY");
		//ri.close();
	} catch (Exception e) {
		err(e.toString());
	} finally {
		try {rs.close();} catch (Exception e){}
	}
	return;
}
//------------------------------------------------------------------------------
//	Dir/Doc aus V-Dir entfernen
//------------------------------------------------------------------------------
private void vdirDel(String pkey){
	ResultSet rs = null;
	try {
		rs = db.getSQLRU("Select * from VDOCDIR where PKEY='" + pkey + "'");
		rs.first();
		if (!db.getCKEYCount(pkey).equals("0")){throw new Exception("VDir-Verzeichnis wird noch verwendet!");}
		ResultSet ru = db.getSQLRU("DELETE from VDOCAUTH where PKEY=" + rs.getString("PKEY"));
		rs.deleteRow();
	} catch (Exception e) {
		err(e.toString());
	} finally {
		try {rs.close();} catch (Exception e){}
	}
	return;
}
//============================================================================%>
<%
//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
String puser  = (String) session.getAttribute("userpkey");
String forw   = request.getParameter("forw");   // forward URL
String action = request.getParameter("action"); // aktion
String pkey   = request.getParameter("pkey");
String ckey   = request.getParameter("ckey");
String type   = request.getParameter("type");
String svdir  = request.getParameter("svdir");
if (action.equals("SVadd") || action.equals("SWadd")) {
	if (ckey  != null) {msg("ckey="  + ckey);}  else {err("'ckey='  fehlt.");}
	if (svdir != null) {msg("svdir=" + svdir);} else {err("'svdir=' fehlt.");}
	if (type  != null) {msg("type="  + type);}  else {err("'type=' fehlt.");}
	if (!isErr()) vdirSxAdd(ckey,svdir,type,puser);
} else if (action.equals("VVdel") || action.equals("VWdel")) {
	if (pkey  != null) {msg("pkey="  + pkey);}  else {err("'pkey='  fehlt.");}
	if (!isErr()) vdirDel(pkey);
} else if (action.equals("SVcrt")) {
	if (ckey  != null) {msg("ckey="  + ckey);}  else {err("'ckey='  fehlt.");}
	if (svdir != null) {msg("svdir=" + svdir);} else {err("'svdir=' fehlt.");}
	if (type  != null) {msg("type="  + type);}  else {err("'type=' fehlt.");}
	if (!isErr()) vdirSxAdd(ckey,".",type,puser);
} else {err("Aktion='" + action +"' ist nicht bekannt.");}
if (!isErr()) {
response.sendRedirect(forw); 
}
//==============================================================================
//
//	H  T  M  L
//
//==============================================================================
%>
<html>
<head>
	<title>VDir Verwalten</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<meta http-equiv="Expires" content="-780">
	<link rel="stylesheet" href="vdoc.css">
</head>
<body><h1>VDir Verwaltung meldet einen Fehler:</h1>
<%=err()%>
<%=msg()%>
<br><a href="<%= forw %>">zur&uuml;ck</a>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>
