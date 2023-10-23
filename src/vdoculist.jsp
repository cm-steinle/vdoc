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
		 + " where USERTYPE='U' order by FULLNAME";
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
			userid = (userid.equals("")) ? "&nbsp;" : userid;
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
if (TRACE) db.setTrace(TRACE);
StringBuilder ptxt = newSB4();
String popup = "";
int puser = 0;
int cuser = 0;
try {puser = Integer.parseInt(request.getParameter("pkey"));} catch (Exception e) {};
ResultSet rs;
%>
<!DOCTYPE html>
<html>
<head>
	<title>VDoc AbteilungsListe</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<meta http-equiv="Expires" content="-780">
  <link rel="stylesheet" href="js/ng/ctxmenu/contextmenu.css" media="screen" title="no title">
	<script type="text/javascript" src="dhtml.js"></script>	
	<link rel="stylesheet" href="vdoc.css">
	<style type="text/css">
	TH {
		text-align : center;
		vertical-align : bottom;
		white-space : nowrap;
	}
	TD {
		text-align : center;
	}
	TD.user {
		text-align : left;
		white-space : nowrap;
	}
</style>
	<script language="JavaScript" src="vdoclist.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript">
//-----------------------------------------------------------
//   Den geclonten TabellenKopf immer anzeigen
//-----------------------------------------------------------
var divKopf;
var docKopf;
var tabKopf;
var kopfStyle;
var docBody;
function adjust(){
  divKopf = getElem("id","kopf"   ,null);
  docKopf = getElem("id","docKopf",null);
  tabKopf = getElem("id","tabKopf",null);
  if (!divKopf || !docKopf || !tabKopf) return;
  if (!docKopf.getElementsByTagName("th")) return;
  if (!tabKopf.getElementsByTagName("th")) return;
 for(i = 0; i < docKopf.getElementsByTagName("th").length; i++){
   var pLen = tabKopf.getElementsByTagName("th")[i].offsetWidth;
   docKopf.getElementsByTagName("th")[i].width = pLen;
 }
 docKopf.width = tabKopf.offsetWidth;
 kopfStyle = DivObjStyle('kopf');
 docBody = document.body;
 posCheck();
}
var lastPos = 0;
var currPos = 0;
function posCheck(){
	currPos = docBody.scrollTop;
	if (lastPos == 0 && currPos > 0){
		kopfStyle.visibility = 'visible';
	}
	if (currPos == 0 && lastPos > 0){
		kopfStyle.visibility = 'hidden';
	}
	if (currPos != lastPos){
		kopfStyle.top = currPos;
		lastPos = currPos;
	}
	setTimeout("posCheck()",1);
}
//-->
</script>
</head>
<body ng-controller="contextCtrl" bgcolor="#FFFFFF" onload="adjust()">
<%
String KopfText[] = {"<a href=\"javascript:pop('C',0000000000)\" noonmousedown=\"pop('C',0000000000)\" context-menu='PopUpC'>Name","Userid"}; 
String thead = VDocTablU(puser,KopfText);
%>
<div id="kopf" style="position: absolute; top: 0px; visibility: hidden;">
<table border="0" cellspacing="2" cellpadding="0" id="docKopf"><%= thead %></table>
</div>
<table border="0" cellspacing="2" cellpadding="0" id="tabKopf"><%= thead %>
<% rs = db.getSQLRO(userSelect());
while (rs.next()){cuser = rs.getInt("CUSER");
String pUser = rs.getString("PUSER");
String popUser = "<a href=\"javascript:pop('U','" + rs.getString("PUSER") + "')\" noonmousedown=\"pop('U','" + rs.getString("PUSER") + "')\" context-menu='PopUpU'>";%>
<tr bgcolor="#DDEEEE"><td class='user'><%= popUser %><%= rs.getString("FULLNAME") %></a></td><td class='user'><%= rs.getString("USERID") %> <%= cuser %></td>
<% for (int i=1;i<=abteilSpalten;i++) {
	String checked = (isUserInAbt(pUser,Integer.toString(abteilIDs[i]))) ? "X" : "&nbsp;";
%>
<td><%=checked%></td>
<% } %>
</tr>
<%} rs.close();%>
</table>

<!-- 
<div id="popC" style="position: absolute;">
<APPLET MAYSCRIPT 
	CODE			=	"PopupMenuApplet.class"
	CODEBASE	=	"."
	NAME			=	"PopUpC"
	WIDTH			= "0"
	HEIGHT		= "0"
>
<PARAM NAME="BGCOLOR"	VALUE="lightgray">
<PARAM NAME="TEXT"		VALUE="blue">
<PARAM NAME="DATA"		VALUE="
{Aktualisieren*script=location.reload(true)}
{neuen User anlegen*script=crtUser()}
">
</APPLET>
</div>
 -->
 <div id="popC" style="position: absolute;">
    <nav id="PopUpC" class="ng-hide">
      <ul class="context-menu">
        <li ng-click="reload()">Aktualisieren</li>
        <li ng-click="crtUser()">neuen User anlegen</li>
      </ul>
    </nav>
</div>
 
 
<!-- 
<div id="popU" style="position: absolute;">
<APPLET MAYSCRIPT 
	CODE			=	"PopupMenuApplet.class"
	CODEBASE	=	"."
	NAME			=	"PopUpU"
	WIDTH			= "0"
	HEIGHT		= "0"
>
<PARAM NAME="BGCOLOR"	VALUE="lightgray">
<PARAM NAME="TEXT"		VALUE="blue">
<PARAM NAME="DATA"		VALUE="
{User bearbeiten*script=chgUser()}
{User l&ouml;schen*script=delUser()}
">
</APPLET>
</div>
 -->
 <div id="popU" style="position: absolute;">
    <nav id="PopUpU" class="ng-hide">
      <ul class="context-menu">
        <li ng-click="chgUser()">User bearbeiten</li>
        <li ng-click="delUser()">User l&ouml;schen</li>
      </ul>
    </nav>
</div>
 
 
<script src="js/ng/angular.min.js"></script>
<script src="js/ng/ctxmenu/contextmenu.js"></script>
<script src="js/ng/ctxmenu/app.js"></script> 
 
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>
