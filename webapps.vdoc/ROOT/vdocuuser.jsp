<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<%@include file="vdocbase.jsp"%>
<%@ page import="java.util.*"%>
<%!//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
int abteilSpalten = 0;
int abteilIDs[] = new int[100];
//------------------------------------------------------------------------------
//	User Abfrage
//------------------------------------------------------------------------------
private String userSelect() {
	return "Select PUSER,CUSER,USERTYPE,USERID,FULLNAME from VDOCUSER"
		 + " where USERTYPE='U' order by USERID";
}
//------------------------------------------------------------------------------
//	SQL-Statement zusammenbauen
//------------------------------------------------------------------------------
private String listSelect(int xkey) {
	return "Select PUSER,CUSER,USERTYPE,USERID,FULLNAME from VDOCUSER"
	   + " where PUSER != CUSER AND CUSER=" + xkey
		 + " AND USERTYPE='A' ORDER BY USERSORT";
}
private int levelCount(int xkey) throws Exception  {
	ResultSet rs;
	int zahl;
	rs = db.getSQLRO(
			 "Select count(*) as Zahl from VDOCUSER"
	   + " where PUSER != CUSER AND CUSER=" + xkey
		 + " AND USERTYPE='A'");
	rs.next();
	zahl = rs.getInt("Zahl");
	rs.close();
	return zahl;
}
//------------------------------------------------------------------------------
//	Abteilungs/User Tree-Struktur erstellen
//------------------------------------------------------------------------------
private String VDocTablU(int xkey, String xtraTH[])
	throws Exception  {
	int rowNum;
	int level = 0;
	int maxLvl = 0;
	String pSQL;
	String text[] = new String[10];
	for (int i = 0;i < text.length;i++){text[i] = "";}
	Stack stck = new Stack();
	int zahl = 0;
	int zahlen[] = new int[10];
	StringBuilder ptxt = newSB4();
	ResultSet rs;
	//----------------------------------------------------------------------------
	//	maximal Level ermitteln
	//----------------------------------------------------------------------------
	zahl = 0;
	pSQL=listSelect(xkey);
	rs = db.getSQLRO(pSQL);
	stck.push(rs);
	while (!stck.empty()){
		rs = (ResultSet) stck.pop();
		while (rs.next()){
			if (levelCount(rs.getInt("PUSER")) > 0){
				level++;
				maxLvl = (level > maxLvl) ? level : maxLvl;
				stck.push(rs);
				rs = db.getSQLRO(listSelect(rs.getInt("PUSER")));
			}
		}
		rs.close();
		level--;
	}
	//----------------------------------------------------------------------------
	//	
	//----------------------------------------------------------------------------
	String userid;
	abteilSpalten = 0;
	level=0;
	pSQL = listSelect(xkey);
	rs = db.getSQLRO(pSQL);
	stck.push(rs);
	while (!stck.empty()){
		rs = (ResultSet) stck.pop();
		rowNum = rs.getRow();
		if (rowNum != 0) {
			userid = rs.getString("USERID");
			userid = (userid.equals("")) ? "Abteilungen" : userid;
			text[level] += "\n<th colspan=" + zahlen[level] +">" + userid + "</th>";
			zahlen[level] = 0;
		}
		while (rs.next()){
			if (levelCount(rs.getInt("PUSER")) > 0){
				level++;
				stck.push(rs);
				rs = db.getSQLRO(listSelect(rs.getInt("PUSER")));
			} else {
				for (int i=0;i<=maxLvl;i++){zahlen[i]++;}
				if (level < maxLvl){
					//text[level] += "<td>&nbsp;</td>";
					//text[maxLvl] += "<td>" + rs.getString("USERID") + "</td>";
					text[level] += "\n<th rowspan=" +(maxLvl-level+1)+ ">" + rs.getString("USERID") + "</th>";
				} else {
					text[level] += "\n<th>" + rs.getString("USERID") + "</th>";
				}
				zahlen[level] = 0;
	//			abteilIDs[abteilSpalten] = rs.getInt("PUSER");
				abteilSpalten++;
				abteilIDs[abteilSpalten] = rs.getInt("PUSER");
			}
		}
		rs.close();
		level--;
	}
	//text[0] += "Spalten=" + abteilSpalten;
	for (int i=0;i<text.length;i++){
		if (text[i].length() > 0){
			ptxt.append("\n<tr class='blue'>");
			if (i==0) {for (int x=0;x<xtraTH.length;x++){ptxt.append("<th rowspan=" + (maxLvl+1)+">"+xtraTH[x]+"</th>");}}
			ptxt.append(text[i] + "</tr>");
		}
	}
return ptxt.toString();
}
//------------------------------------------------------------------------------
//	User den Abteilungen zuordnen
//	PUSER = USERID
//	CUSER = Abteilung
//------------------------------------------------------------------------------
private void uabtCrt(String puser,String abts) {
	String psql;
	psql = "Select * from VDOCUSER";
	psql += " where USERTYPE = 'A'";
	psql += " and PUSER in (" + abts + ")";
	ResultSet rs = null, rn = null;
	try {		
		ResultSet rx = db.getSQLRU("DELETE from VDOCUABT where PUSER=" + puser);
		if (abts.length() > 0) {
			rn = db.getSQLRU("select * from VDOCUABT where PUSER=" + puser);
			rn.beforeFirst();		
			rs = db.getSQLRO(psql);
			while (rs.next()) {
				rn.moveToInsertRow();
				rn.updateString("PUSER",puser);
				rn.updateString("CUSER",rs.getString("PUSER"));
				rn.insertRow();
			}
			rs.close();
			rn.close();
		}
	} catch (Exception e) {
		err(e.toString());
	}
	return;
}
//------------------------------------------------------------------------------
//	isUserInAbt gehoert der User in der Abteilung
//------------------------------------------------------------------------------
private boolean isUserInAbt(String puser, String pabt) {
	boolean checked = false;
	try {
		ResultSet rx = db.getSQLRO("select * from VDOCUABT where PUSER="+puser+" and CUSER="+pabt);
		while (rx.next()) checked = true;
		rx.close();
	} catch (Exception e) {
		err(e.toString());
	}
	return checked;
}
//============================================================================%>
<%
//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
// TRACE = true;
if (TRACE) db.setTrace(TRACE);
final String ABBRUCH  = "Abbrechen";
final String AENDERN = "aendern";
final String AENDERNDO  = "Speichern";
final String LOESCHEN  = "loeschen";
final String LOESCHENDO  = "jetzt Loeschen";
final String NEUESUSER  = "neuer User";
final String NEUESUSERDO  = "User anlegen";

String userPKEY = (String) session.getAttribute("userpkey");
String puser = request.getParameter("puser");
String cuser = request.getParameter("cuser");;
String submit = request.getParameter("submit");
String action = request.getParameter("action");
String abts = request.getParameter("abts");
String abteilungen = "";
String submitValue = "";
String chgFlds[] = {"FULLNAME","USERID","PASSWORD"};
String type = "";
String typeText = null;
int rowNumber = 0;
boolean ok = true;
boolean nurHinweis = false;
boolean neuUser = false;
boolean neuAbt = false;
boolean neu = false;
boolean aen = false;
boolean crtUser = false;
boolean crtAbt = false;
boolean crt = false;
boolean loe = false;
boolean delUser = false;
boolean delAbt = false;
boolean del = false;
boolean upd = false;
boolean inp = false;
if (ok && userPKEY == null){ok = false;err("Sie sind nicht angemeldet");}
if (ok && action == null){ok = false;err("Falscher Aufruf");}
if (ok && !action.equals(NEUESUSER) && !action.equals(AENDERN) && !action.equals(LOESCHEN)){ok = false;}
if (ok && action.equals(NEUESUSER)){neu = true;submitValue=NEUESUSERDO;}
if (ok && action.equals(AENDERN)){aen = true;submitValue=AENDERNDO;}
if (ok && action.equals(LOESCHEN)){loe = true;submitValue=LOESCHENDO;}
if (ok && neu){typeText="User anlegen";}
if (ok && aen){typeText="User &auml;ndern";}
if (ok && loe){typeText="User l&ouml;schen";}
if (!isErr()) {
	if (submit != null) {
		if (neu && submit.equals(NEUESUSERDO)) {crt = true;}
		if (aen && submit.equals(AENDERNDO))   {upd = true;}
		if (loe && submit.equals(LOESCHENDO))  {del = true;}
	}
}
//------------------------------------------------------------------------------
//	DB Aendern
//------------------------------------------------------------------------------
if (crt || upd || del) {
//------------------------------------------------------------------------------
//	Abteilungen ermitteln
//------------------------------------------------------------------------------
	if (crt || upd) {
		int abtCount = 0;
		try {abtCount = Integer.parseInt("0" + abts);} catch (Exception e) {}
		String komma = "";
		for (int i=1;i<=abtCount;i++){
			String onOff = request.getParameter(i + "_x");
			if (onOff != null){
				abteilungen += komma + request.getParameter(i + "_y");
				komma = ",";
			}
		}
		trace("abteilungen=" + abteilungen);
	}
	trace("B");
	ResultSet rs=null;
	try {
		trace("C");
		rs = db.getSQLRU("Select * from VDOCUSER where PUSER='" + puser + "'");
		rs.first();
		rowNumber=rs.getRow();
		if (upd) {
			trace("D");
			rs.first();
			for (int i = 0; i < chgFlds.length; i++){
				if (session.getValue(chgFlds[i]).equals(rs.getString(chgFlds[i]))){
					trace("d1");
					rs.updateString(chgFlds[i], request.getParameter(chgFlds[i]));
					trace("d2");
				} else {upd = false;}
			}
			if (upd) {
				trace("E");
				//rs.updateNull("UPDDATE");
				rs.updateRow();
				msg("Ge&auml;ndert");
			} else {
				trace("F");
				rs.cancelRowUpdates();
				err("Satz war inzwischen ge&auml;ndert. Bitte wiederholen.");
			}
			uabtCrt(puser,abteilungen);
		} else if (crt) {
			trace("G");
			rs.moveToInsertRow();
			for (int i = 0; i < chgFlds.length; i++){
				String text = request.getParameter(chgFlds[i]);
				if (text.length() > 0){
					rs.updateString(chgFlds[i], text);
				} else {
					err("Im Feld " + chgFlds[i] + " ist eine Eingabe erforderlich");
				}
			}
			if (isErr()) {
				err("Neuer User konnte nicht angelegt werden.");
			} else {
				rs.updateInt("PUSER",0);
				rs.updateInt("CUSER",0);
				rs.updateString("USERTYPE","U");
				rs.updateInt("USERSORT",0);
				trace("g1");
				rs.insertRow();
				trace("g2");
				ResultSet ri = db.getSQLRO("Select max(PUSER) as PUSER from VDOCUSER where CUSER='0'");
				ri.first();
				puser = ri.getString("PUSER");
				ri.close();
				trace("g3");
				msg("Angelegt mit Nr=" + puser);
				uabtCrt(puser,abteilungen);
			}
		} else if (del) {
			trace("del");
			if (db.isUserUsed(rs.getString("PUSER"))) {
				err("User kann nicht gel&ouml;scht werden");
			} else {
				rs.deleteRow();
				msg("User wurde gel&ouml;scht");
				uabtCrt(puser,"");
			}
		}
		if (!isErr()) nurHinweis = true;
	} catch (SQLException s) {
		trace("Hs");
		sqlErr(s);
	} catch (Exception e) {
		trace("H");
		err(e.toString());
	} finally {
		trace("I");
		sqlMsg(rs.getWarnings());
		try {rs.close();} catch (Exception e){}
	}
	if (nurHinweis) {
		aen = false;
		neu = false;
		loe = false;
	}
	trace("J");
}
trace("K");
trace("ok=" + ok);
trace("rowNumber=" + rowNumber);
trace("abts=" + abts);
trace("PUSER=" + puser);
trace("CUSER=" + cuser);
trace("action=" + action);
trace("submit=" + submit);
trace("neu=" + neu);
trace("aen=" + aen);
trace("upd=" + upd);
%>
<%
//------------------------------------------------------------------------------
//	H T M L
//------------------------------------------------------------------------------
%>
<html>
<head>
	<title>VDoc UserData</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<meta http-equiv="Expires" content="-780">
	<link rel="stylesheet" href="vdoc.css">
</head>
<body>
<%=err()%>
<%=msg()%>
<%
if (nurHinweis) {
%> Aktualisieren Sie Ihre Anzeige
<form> 
<input type="reset" value="     OK     " onClick="location.href='leer.htm'">
</form>
<%
} else {%>
<h1><%=typeText%></h1>
<%
	try {
		ResultSet rs = db.getSQLRO("Select * from VDOCUSER where PUSER='" + puser + "'");
		if (rs.first() || neu) {
%>
<%
//------------------------------------------------------------------------------
//	User Infos
//------------------------------------------------------------------------------
%>
<form method="post">
<input type="hidden" name="action" value="<%= action %>">
  <table border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="2" nowrap bgcolor="#3399FF" class="blue"><%=typeText%></td>
    </tr>
    <tr> 
      <td nowrap bgcolor="#FFFFCC">Userid: </td>
      <td nowrap> 
        <input type="text" name="USERID" value="<%= (neu) ? "" : rs.getString("USERID") %>" size="8" maxlength="8">
      	<% if (!neu) session.putValue("USERID",rs.getString("USERID")); %>      	
			</td>
    </tr>
    <tr> 
      <td nowrap bgcolor="#FFFFCC">Passwort: </td>
      <td nowrap> 
        <input type="password" name="PASSWORD" value="<%= (neu) ? "" : rs.getString("PASSWORD") %>" size="8" maxlength="8">
      	<% if (!neu) session.putValue("PASSWORD",rs.getString("PASSWORD")); %>      	
			</td>
    </tr>
    <tr> 
      <td bgcolor="#FFFFCC">Name, Vorname: </td>
      <td nowrap> 
        <input type="text" name="FULLNAME" value="<%= (neu) ? "" : rs.getString("FULLNAME") %>" size="40" maxlength="40">
      	<% if (!neu) session.putValue("FULLNAME",rs.getString("FULLNAME")); %>      			
      </td>
    </tr>
  </table>
  <p>
<%
//------------------------------------------------------------------------------
//	User den Abteilungen zuordnen
//------------------------------------------------------------------------------
String KopfText[] = {}; %>
<table border=2><%= VDocTablU(0,KopfText) %>
<% for (int i=1;i<=abteilSpalten;i++) {
	String checked = (isUserInAbt(puser,Integer.toString(abteilIDs[i]))) ? " checked" : "";
%>
<td><input type="checkbox" name="<%= i %>_x"<%= checked %>><input type="hidden" name="<%= i %>_y" value="<%= abteilIDs[i]%>"></td>
<% } %>
</tr>
</table>
<br>
<%
//------------------------------------------------------------------------------
//	Form Submit
//------------------------------------------------------------------------------
%>
	<%if (neu || aen || loe) {%>
		<input type="hidden" name="abts" value="<%=abteilSpalten%>">
    <input type="submit" name="submit" value="<%=submitValue%>">
	<% } %>
		<input type="reset" value="<%= ABBRUCH %>" onClick="location.href='leer.htm'">
  </p>
</form>
	<%} else {%>
	Keine Daten vorhanden<br>Aktualisieren Sie Ihre Anzeige.
	<form> 
	<input type="reset" value="     OK     " onClick="location.href='leer.htm'">
	</form>
	<%}
		rs.close();
	} catch (Exception e) {
		%><%= e.toString() %><br><%
	}
} // ende isErr() %>
<%=err()%>
<%=msg()%>
<% if (TRACE) {%>Trace: <%=trace()%><br><%}%>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>