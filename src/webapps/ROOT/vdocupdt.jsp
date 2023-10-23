<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<%@include file="vdocbase.jsp"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.net.*"%>
<%!//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
//============================================================================%>
<%
//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
if (TRACE) db.setTrace(TRACE);
String userPKEY = (String) session.getAttribute("userpkey");
String resp = request.getParameter("resp");
String action = request.getParameter("action");
String pkey = request.getParameter("pkey");
String ckey = request.getParameter("ckey");
String pfad = "";
String filename = "";
String text = "";
String expDate = "";
String expUser = "";
String typeText = "Dokument";
ResultSet rs = null;
boolean ok = true;
boolean get = false;
boolean put = false; // nach Upload = true
boolean qik = false; // einchecken mit implizitem auschecken
boolean upd = false; // DB Updaten
boolean form = false;
if (ok && userPKEY == null){ok = false;msg("Sie sind nicht angemeldet");}
if (ok && action == null){ok = false;}
if (ok && !action.equals("get") && !action.equals("put") && !action.equals("qik")){ok = false;}
if (ok && action.equals("get")){get = true;}
if (ok && action.equals("put")){put = true;}
if (ok && action.equals("qik")){put = true; qik = true;}
if (ok && pkey == null){ok = false;}
if (ok && resp != null){
	if (resp.equals("updt") && put){upd = true;}
	if (resp.equals("expo") && get){upd = true;}
}
if (ok) {
	String psql = "Select * from VDOCDIR where PKEY='" + pkey + "'";
	try {	// gibt es das Dokument?
		rs = db.getSQLRU(psql);
		if (rs.first()) {
			if (rs.getString("TYPE").equals("F")){
				filename = rs.getString("DIR");
				text     = rs.getString("TEXT");
				if (rs.getLong("EXPDATE")==0) {
					if (put && !qik){
						ok = false;
						msg ("Das Dokument <span class='fehler'>" + filename + "</span> wurde nicht zum &Auml;ndern abgeholt!");
					}
				} else {
					if (get && !qik){
						ok = false;
						msg ("Das Dokument <span class='fehler'>" + filename + "</span> wurde schon zum &Auml;ndern abgeholt!");
					}
				}
				if (ok && upd && get) {
					rs.updateNull("EXPDATE");
					rs.updateString("EXPUSER",userPKEY);
				}
				if (ok && upd && put) {
					rs.updateNull("UPDDATE");
					rs.updateLong("FRGDATE", 0);
					rs.updateLong("EXPDATE", 0);
					rs.updateString("EXPUSER","0");
				}
				if (ok && upd) {
					rs.updateRow();
					rs.close();
					rs = db.getSQLRO(psql);
					rs.first();
				}
				pfad = db.getPfad(rs.getString("CKEY"));
				expUser = db.getUSERWERT(rs.getString("EXPUSER"),"USERID");
				expDate = (rs.getLong("EXPDATE")==0) ? "" : rs.getString("EXPDATE");
			} else {ok = false;
				msg("PKEY=" + pkey + " ist kein Dokument!");
			}
		} else {ok = false;
			msg("PKEY=" + pkey + " Dokument ist nicht im Archiv vorhanden.");
		}
	} catch (Exception e){
		ok=false;
		msg(e.toString());
	} finally {
		try {rs.close();} catch (Exception e){}
	}
}
if ((ok && upd && get) || (ok && !upd && qik)) { // Ablage erstellen
	try {
		String ablageName = "";
		ablageName = db.copyToAblage(pkey,db.VDOC_ABLAGE_PKEY);
		if (ablageName.length() != 0){
			msg("Dokument wurde in Altablage kopiert.");
		}
	} catch (Exception e){
		ok=false;
		err(e.toString());
	}
}
trace("userPKEY=" + userPKEY);
trace("resp=" + resp);
trace("action=" + action);
trace("pkey=" + pkey);
trace("ckey=" + ckey);
trace("filename=" + filename);
trace("pfad=" + pfad);
trace("text=" + text);
trace("expDate=" + expDate);
trace("expUser=" + expUser);
trace("typeText=" + typeText);
trace("get=" + get);
trace("put=" + put);
trace("upd=" + upd);
trace("OK=" + ok);
%>
<html>
<head>
	<title>VDoc Update Dokument</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<link rel="stylesheet" href="vdoc.css">
</head>
<body>
<% if (get && !upd && !qik){ %><h1>Dokument auschecken</h1><%}%>
<% if (get &&  upd && !qik){ %><h1>Dokument auschecken OK!</h1><%}%>
<% if (put && !upd && !qik){ %><h1>Dokument einchecken</h1><%}%>
<% if (put &&  upd && !qik){ %><h1>Dokument einchecken OK!</h1><%}%>
<% if (put && !upd &&  qik){ %><h1>Dokument schnell einchecken </h1><%}%>
<% if (put &&  upd &&  qik){ %><h1>Dokument schnell einchecken OK!</h1><%}%><%= err() + msg() %>
  <table border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <th nowrap class="desc" colspan="2"><%=typeText%></td>
    </tr>
    <tr> 
      <td nowrap class='desc'>Name: </td>
      <td nowrap><%= filename %></td>
    </tr>
    <tr> 
      <td nowrap class='desc'>Beschreibung: </td>
      <td nowrap><%= text %></td>
    </tr>
    <tr> 
      <td class='desc'>abgeholt am: </td>
      <td nowrap><%= expDate %></td>
    </tr>
    <tr> 
      <td class='desc'>abgeholt von: </td>
      <td nowrap><%= expUser %></td>
    </tr>
  </table>
<% if (ok && get && !upd && !qik){form = true;%>
<form method="post">
<input type="hidden" name="pkey" value="<%=pkey%>">
<input type="hidden" name="action" value="get">
<input type="hidden" name="resp" value="expo">
<input type="submit" value="auschecken" onClick="window.open('<%="docs/" + pfad + "/" + filename%>','')">
<input type="reset"  value="Abbrechen" onClick="location.href='leer.htm'">
</FORM><% } %>
<% if (ok && put && !upd){form = true;%>
<form action="servlet/UploadServlet" method="post" enctype="multipart/form-data" onSubmit="return sendtest(this);">
<input type="hidden" name=":respto" value="../vdocupdt.jsp?resp=updt&ckey=<%=ckey%>">
<input type="hidden" name=":Directory" value="<%=request.getParameter("at")%>" size="50" maxlength="60">
<input type="hidden" name=":action"    value="upd">
<input type="hidden" name="action"     value="<%=request.getParameter("action")%>">
<input type="hidden" name="userpkey"   value="<%=session.getAttribute("userpkey")%>">
<input type="hidden" name="pkey"       value="<%=pkey%>">
<input type="hidden" name="filename"   value="<%=filename%>">
<input type="file" name="DIR" size="50"><br>
<input type="submit" name=":submit"    value="einchecken">
<input type="reset" value="Abbrechen" onClick="location.href='leer.htm'">
</FORM>
<!-- Scripts -->
<script>
function sendtest(obj) {
	var fehler = false;
	var reg = /.+(<%=filename%>)$/
	if (!reg.exec(obj.DIR.value)) fehler = true;
	if (fehler) {
		alert("Sie muessen exakt die richtige Datei auswaehlen.");
	}
	return !(fehler);
}
</script>
<% } %>
<% if (!form){ %>
<form method="post">
<input type="reset"  value="Abbrechen" onClick="location.href='leer.htm'">
</FORM>
<% } %>
<%= trace() %>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>
