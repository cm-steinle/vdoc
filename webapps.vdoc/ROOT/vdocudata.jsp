<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<%!//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
final boolean TRACE = false;
//------------------------------------------------------------------------------
//	SQL-Statement zusammenbauen
//------------------------------------------------------------------------------
//============================================================================%>
<%
//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
if (TRACE) db.setTrace(TRACE);
final String BEARBEITEN = "Bearbeiten";
final String AENDERNUPD  = "Speichern";
final String ABBRUCH  = "Abbrechen";
final String LOESCHEN  = "Loeschen";
final String LOESCHENDO  = "jetzt Loeschen";
final String LOESCHABTDO  = "Loeschen Abteilung";
final String NEUESUSER  = "neuer User";
final String NEUESABT  = "neue Abteilung";
final String NEUESUSERDO  = "User speichern";
final String NEUESABTDO  = "Abteilung speichern";

String puser = request.getParameter("puser");
String cuser = request.getParameter("cuser");;
String submit = request.getParameter("submit");
String action = request.getParameter("action");
String submitValue = BEARBEITEN;
String pmsg = "";	// Hinweis
String perr = "";	// Fehler
String chgFlds[] = {"FULLNAME","USERID"};
String trace = "";
String type = "";
String typeText = null;
int rowNumber = 0;
boolean nurHinweis = false;
boolean neuUser = false;
boolean neuAbt = false;
boolean neu = false;
boolean crtUser = false;
boolean crtAbt = false;
boolean crt = false;
boolean loe = false;
boolean delUser = false;
boolean delAbt = false;
boolean del = false;
boolean chg = false;
boolean upd = false;
boolean inp = false;
if (submit != null) {
	trace += "0";
	   chg = (submit.equals(BEARBEITEN)) ? true : false;
	   upd = (submit.equals(AENDERNUPD)) ? true : false;
	neuUser = (submit.equals(NEUESUSER)) ? true : false;
	neuAbt = (submit.equals(NEUESABT)) ? true : false;
	   neu = (neuUser || neuAbt) ? true : false;
	crtUser = (submit.equals(NEUESUSERDO) || (submit.equals("upld") && action.equals("crt"))) ? true : false;
	crtAbt = (submit.equals(NEUESABTDO)) ? true : false;
	   crt = (crtUser || crtAbt);
	   loe = (submit.equals(LOESCHEN)) ? true : false;
		 del = (submit.equals(LOESCHENDO)) ? true : false;
}
trace += "A";
if (upd || crt || del) {
	trace += "B";
	ResultSet rs=null;
	try {
		trace += "C";
		rs = db.getSQLRU("Select * from VDOCUSER where PUSER='" + puser + "'");
		rs.first();
		rowNumber=rs.getRow();
		if (cuser == null) cuser = rs.getString("CUSER");
		type = rs.getString("USERTYPE");
		if (upd) {
			trace += "D";
			rs.first();
			for (int i = 0; i < chgFlds.length; i++){
				if (session.getValue(chgFlds[i]).equals(rs.getString(chgFlds[i]))){
					trace += "d1";
					rs.updateString(chgFlds[i], request.getParameter(chgFlds[i]));
					trace += "d2";
				} else {upd = false;}
			}
			if (upd) {
				trace += "E";
				//rs.updateNull("UPDDATE");
				rs.updateRow();
				pmsg += "Ge&auml;ndert";
			} else {
				trace += "F";
				rs.cancelRowUpdates();
				perr += "Satz war inzwischen ge&auml;ndert. Bitte wiederholen.";
			}
		} else if (crt) {
			trace += "G";
			rs.moveToInsertRow();
			for (int i = 0; i < chgFlds.length; i++){
				String text = request.getParameter(chgFlds[i]);
				if (text.length() == 0){text = "neu";}
				rs.updateString(chgFlds[i], text);
			}
			rs.updateInt("PUSER",0);
			rs.updateString("CUSER",cuser);
			rs.updateString("USERTYPE",(crtAbt) ? "A" : "U");
			rs.updateString("CRTUSER",(String) session.getAttribute("userpkey"));
			rs.updateNull("CRTDATE"); // so wird automatisch das Datum kreiert
			rs.updateString("UPDUSER","0");
			rs.updateString("UPDDATE","0");
			rs.updateString("FRGUSER","0");
			rs.updateString("FRGDATE","0");
			rs.updateString("EXPUSER","0");
			rs.updateString("EXPDATE","0");
			trace += "g1";
			rs.insertRow();
			trace += "g2";
			rs.last();
			ResultSet ri = db.getSQLRO("Select PUSER from VDOCUSER where CUSER='" + cuser + "' and USERID='" + rs.getString("USERID") + "'");
			ri.first();
			puser = ri.getString("PUSER");
			ri.close();
			pmsg += "Angelegt.";
		} else if (del) {
			trace += ";del";
			if (db.getCKEYCount(puser).equals("0")){
				//pmsg += "Verzeichnis kann geloescht werden.";
				if (type.equals("D")) {
					try {
						db.delete(puser);
					} catch (Exception e){
					} finally {
						rs.deleteRow();
					}
				} else {
					//db.delete(puser);
					//rs.deleteRow();
					try {
						db.delete(puser);
					} catch (Exception e){
					} finally {
						ResultSet ru = db.getSQLRU("DELETE from VDOCAUTH where PUSER=" + rs.getString("PUSER"));
						rs.deleteRow();
					}
				}
			} else {
				perr += "Verzeichnis wird noch verwendet";
			}
			pmsg += "Gel&ouml;scht.";
		}
		nurHinweis = true;
	} catch (Exception e) {
		trace += "H";
		%><%= e.toString() %><br><%
	} finally {
		trace += "I";
		try {rs.close();} catch (Exception e){}
	}
	chg = false;
	neu = false;
	loe = false;
	trace += "J";
}
if (neu) {
	submitValue = (neuUser) ? NEUESUSERDO : NEUESABTDO;
} else if (loe) {
	submitValue = LOESCHENDO;
} else {
	submitValue = (chg) ? AENDERNUPD : BEARBEITEN;
}
inp = (neu || chg);
if (typeText == null) {
				 if (neuUser) {typeText = "neue Userid";
	} else if (neuAbt) {typeText = "neue ABTEILUNG";
	}
}
trace += "K";
%>
<html>
<head>
	<title>VDoc Data</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<meta http-equiv="Expires" content="-780">
	<link rel="stylesheet" href="vdoc.css">
</head>
<body><% if (TRACE) {%>
getAuthType=<%=request.getAuthType()%><br>
getMethod=<%=request.getMethod()%><br>
getPathInfo=<%=request.getPathInfo()%><br>
getPathTranslated=<%=request.getPathTranslated()%><br>
getQueryString=<%=request.getQueryString()%><br>
getRemoteUser=<%=request.getRemoteUser()%><br>
getRequestedSessionId=<%=request.getRequestedSessionId()%><br>
getServletPath=<%=request.getServletPath()%><br>
getRequestURI=<%=request.getRequestURI()%><br>
isRequestedSessionIdFromCookie=<%=request.isRequestedSessionIdFromCookie()%><br>
isRequestedSessionIdFromURL=<%=request.isRequestedSessionIdFromURL()%><br>
isRequestedSessionIdValid=<%=request.isRequestedSessionIdValid()%><br>
RowNumber=<%=rowNumber%><br>
PUSER=<%=puser%><br>
CUSER=<%=cuser%><br>
chg=<%=submit%><br>
upd=<%=upd%><br>
Session=<%= response.encodeUrl("xxxxx.xxx?yyyy=222&zzz=111")%><br>
Pfad=<%=request.getContextPath()%><br>
AutoCommit=<%=db.getAutoCommit()%><br>
Transactions=<%=db.supportsTransactions()%><br>
SessionValue=<%=session.getValue("FULLNAME")%><br>
userpkey=<%= (String) session.getAttribute("userpkey") %><br>
username=<%= (String) session.getAttribute("username") %><br>
fullname=<%= (String) session.getAttribute("fullname") %><br>
<%}
if (TRACE && (trace != "")) {%>Trace: <%=trace%><br><%}
if (pmsg != "") {%><span class="hinweis"><%=pmsg%></span><br><%}
if (perr != "") {%><span class="fehler"><%=perr%></span><br><%}
if (nurHinweis) {
%> Aktualisieren Sie Ihre Anzeige <%
} else {
	try {
		ResultSet rs = db.getSQLRO("Select * from VDOCUSER where PUSER='" + puser + "'");
		if (rs.first()) {
			if (cuser == null) cuser = rs.getString("CUSER");
			type = rs.getString("USERTYPE");
		if (typeText == null) typeText = (type.equals("A")) ? "Abteilung" : "User";
%>
<form action="<%=request.getRequestURI()%>?puser=<%=puser%>&cuser=<%=cuser%>" method="post">
  <table border="0" cellspacing="0" cellpadding="0">
<!--
    <tr bgcolor="#FFFF00"> 
      <td><b><%=db.getUSERWERT(cuser,"USERID")%></b></td>
      <td nowrap> 
				<b><%=db.getUSERWERT(cuser,"FULLNAME")%></b>
      </td>
    </tr>
-->
<!--
    <tr> 
      <td bgcolor="#FFFFCC">PUSER</td>
      <td nowrap> 
				<%=rs.getString("PUSER")%>
      </td>
    </tr>
    <tr> 
      <td bgcolor="#FFFFCC">CUSER</td>
      <td nowrap> 
				<%=rs.getString("CUSER")%>
      </td>
    </tr>
-->
    <tr> 
      <td colspan="2" nowrap bgcolor="#3399FF" class="blue"><%=typeText%></td>
    </tr>
    <tr> 
      <td nowrap bgcolor="#FFFFCC">Name: </td>
      <td nowrap> 
        <%if (inp & type.equals("D")){%><input type="text" name="USERID" value="<%if (chg){%><%=rs.getString("USERID")%><%}%>" size="50" maxlength="60">
				<%} else {%><%=rs.getString("USERID")%>
					<input type="hidden" name="USERID" value="<%if (chg){%><%=rs.getString("USERID")%><%}%>">
				<%}%>
      	<% session.putValue("USERID",rs.getString("USERID")); %>      	
			</td>
    </tr>
    <tr> 
      <td bgcolor="#FFFFCC">Beschreibung: </td>
      <td nowrap> 
        <%if (inp){%><input type="text" name="FULLNAME" value="<%if (chg){%><%=rs.getString("FULLNAME")%><%}%>" size="50" maxlength="60">
				<%} else {%><%=rs.getString("FULLNAME")%>
				<%}%>
      	<% session.putValue("FULLNAME",rs.getString("FULLNAME")); %>				
      </td>
    </tr>
<!--
    <tr> 
      <td nowrap bgcolor="#FFFFCC">Type</td>
      <td nowrap> 
        <%if (inp){%><input type="text" name="USERTYPE" value="<%=rs.getString("USERTYPE")%>" size="8" maxlength="8">
      	<%} else {%><%=rs.getString("USERTYPE")%>
				<%}%>
      </td>
    </tr>
-->
  </table>
<!--	<input type="file" name="dokufile"> -->
  <p>
    <input type="submit" name="submit" value="<%=submitValue%>">
	<%if (neu || chg || loe) {%>
    <input type="submit" name="submit" value="<%=ABBRUCH%>">
	<%} else {%>
    <input type="submit" name="submit" value="<%=NEUESUSER%>">
    <input type="submit" name="submit" value="<%=NEUESABT%>">
		<%if (db.getCKEYCount(puser).equals("0")){%><input type="submit" name="submit" value="<%=LOESCHEN%>"><% } %>
	<% } %>
  </p>
</form>
<!--
<%= db.getCKEYCount(puser) %>
-->
	<%} else {%>
	Keine Daten vorhanden<br>Aktualisieren Sie Ihre Anzeige.
	<%}
		rs.close();
	} catch (Exception e) {
		%><%= e.toString() %><br><%
	}
} 
%>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>