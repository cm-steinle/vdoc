<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<%!//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
final boolean TRACE = false;
//============================================================================%>
<%
//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
//db.setTrace(TRACE);
String userPKEY = (String) session.getAttribute("userpkey");
String type = "";
String typeText = "Freigabe";
String puser = "";
String crtUser = "?";	// Ersteller
String frgUser = "?";	// Freigabe User
String psql = "";
ResultSet rs;

String pactionText = "Keine Aktion";
String paction = request.getParameter("action");
String pkey = request.getParameter("pkey");
String predir = request.getParameter("redir");
String pRefresh = "";
//------------------------------------------------------------------------------
//	action verarbeiten
//------------------------------------------------------------------------------
if (paction != null && paction.equals("frg")) {
	pactionText = "Dokument Freigabe";
	ResultSet ru = db.getSQLRU("UPDATE VDOCDIR SET FRGDATE=NULL where PKEY=" + pkey);
}
if (paction != null && paction.equals("showdate")) {
	typeText = "AnzeigeDatum gesetzt";
	db.setUserDocSeen(pkey,userPKEY);
	pRefresh = "<script type='text/javascript'>location.href='" + predir + "';</script>";
	pRefresh = "<script type='text/javascript'>location=location.protocol + '//' + location.hostname + '/" + predir + "';</script>";
}
//------------------------------------------------------------------------------
//	Anzeige aufbereiten
//------------------------------------------------------------------------------
int i, rowCount;
try {
	psql =  "Select a.*, f.PUSER";
	psql += ", coalesce(f.USERID, a.FRGUSER) as FRGUSERID";
	psql += " from VDOCDIR as a";
	psql += " left outer join VDOCUSER AS f";
	psql += " on a.FRGUSER = f.PUSER";
	psql += " where PKEY='" + pkey + "'";
	rs = db.getSQLRO(psql);
	if (rs.first()) {
		type = rs.getString("TYPE");
		typeText = ((type.equals("D")) ? "Verzeichnis" : "Dokument") + " " + typeText;
		crtUser  = rs.getString("CRTUSER");
		frgUser = (rs.getString("FRGUSERID").equals("0")) ? "?" : rs.getString("FRGUSERID");
		puser = rs.getString("PUSER");
	}
%>
<%
//------------------------------------------------------------------------------
//	H T M L
//------------------------------------------------------------------------------
%>
<html>
<head>
<%= pRefresh %>
	<title><%=typeText%></title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<link rel="stylesheet" href="vdoc.css">	
</head>
<body>
  <table border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="2" nowrap bgcolor="#3399FF" class="blue"><%=typeText%> </td>
    </tr>
    <tr> 
      <td nowrap bgcolor="#FFFFCC">Name: </td>
      <td nowrap> 
				<%= rs.getString("DIR") %>
			</td>
    </tr>
    <tr> 
      <td bgcolor="#FFFFCC">Beschreibung: </td>
      <td nowrap> 
				<%= rs.getString("TEXT") %>
      </td>
    </tr>
    <tr> 
      <td bgcolor="#FFFFCC">Freigabe durch: </td>
      <td nowrap> 
				<%= frgUser %> am: <%if (rs.getLong("FRGDATE")==0) {%>noch nicht freigegeben<%}else%><%=rs.getDate("FRGDATE")%>
      </td>
    </tr>
	</table>
</body>
</html>
<%
	rs.close();
} catch (Exception e) {
%><%= e.toString() %><br><%
}%>
<%@include file="vdocbeanclose.jsp.inc"%>