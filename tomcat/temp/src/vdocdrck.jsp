<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocbean.jsp"%>
<%@include file="vdocbase.jsp"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.net.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
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
private int getAbtStart() throws Exception  {
	ResultSet rs;
	int zahl;
	rs = db.getSQLRO(
			 "Select PUSER from VDOCUSER"
	   + " where PUSER != CUSER AND CUSER=0"
		 + " AND USERTYPE='A'");
	rs.next();
	zahl = rs.getInt("PUSER");
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
	text[0] = " ";
	for (int i = 1;i < text.length;i++){text[i] = "";}
	Stack stck = new Stack();
	int zahl = 0;
	int zahlen[] = new int[10];
	StringBuilder ptxt = newSB2();
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
			text[level] += "\n<th colspan='" + zahlen[level] +"'>" + userid + "</th>";
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
					text[level] += "\n<th rowspan='" +(maxLvl-level+1)+ "'>" + rs.getString("USERID") + "</th>";
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
			ptxt.append("\n<tr class='dir'>");
			if (i==0) {for (int x=0;x<xtraTH.length;x++){ptxt.append("<th rowspan=" + (maxLvl+1)+">"+xtraTH[x]+"</th>");}}
			ptxt.append(text[i] + "</tr>");
		}
	}
return ptxt.toString();
}
//------------------------------------------------------------------------------
//	ListenSelection
//------------------------------------------------------------------------------
private String listxSelect(String pkey, String suchDirText) {
	String psql;
	psql = "Select a.*, c.USERID as CRTUSERID, coalesce(u.USERID, a.UPDUSER) as UPDUSERID"
		  + ", coalesce(f.USERID, a.FRGUSER) as FRGUSERID"
	     + ", coalesce(s.DIR, a.DIR) as SDIR"
            + ", " + wvlgSql("a")
	     + " from VDOCDIR AS a"
	     + " left outer join VDOCUSER AS c"
	     + " on a.CRTUSER = c.PUSER"
	     + " left outer join VDOCUSER AS f"
		  + " on a.FRGUSER = f.PUSER"
	     + " left outer join VDOCUSER AS u"
	     + " on a.UPDUSER = u.PUSER"
	     + " left outer join VDOCDIR AS s"
	     + " on a.CKEY = s.PKEY and a.TYPE='" + typeDoc + "'"
	     + " where a.CKEY=" + pkey
	     + " and (a.TYPE='" + typeDir + "' OR a.DIR like '%" + suchDirText + "%' OR a.TEXT like '%" + suchDirText + "%')"
	     + " order by TYPE desc,DIR,TEXT";
	return psql;
}
//------------------------------------------------------------------------------
//	ListenSelection Sortiert
//------------------------------------------------------------------------------
/*
// aus explainextended.com/2010/04/18/hierarchical-query-in-mysql-limiting-parents
select a.*
from (
select pkey from VDOCDIR
where (pkey = 1490 or ckey = 1490) and type='D'
order by pkey
) q
join VDOCDIR a
on a.ckey = q.pkey
where a.dir like '%fire2%'
order by a.ckey, a.pkey, a.dir
*/
private String listsSelect(String pkey, String suchDirText) {
//db.setTrace(true);
	String dirs = db.VDocDirs(pkey);
	db.log("VDocDirs=" + dirs);
//db.setTrace(false);
	String psql;
	psql = "Select a.*, c.USERID as CRTUSERID, coalesce(u.USERID, a.UPDUSER) as UPDUSERID"
	+ ", coalesce(f.USERID, a.FRGUSER) as FRGUSERID"
	+ ", coalesce(s.DIR, a.DIR) as SDIR"
       + ", " + wvlgSql("a")
	+ " from VDOCDIR AS a"
	     + " left outer join VDOCUSER AS c"
	     + " on a.CRTUSER = c.PUSER"
	     + " left outer join VDOCUSER AS f"
		  + " on a.FRGUSER = f.PUSER"
	     + " left outer join VDOCUSER AS u"
	     + " on a.UPDUSER = u.PUSER"
	     + " left outer join VDOCDIR AS s"
	     + " on a.CKEY = s.PKEY and a.TYPE='" + typeDoc + "'"
	     + " where a.TYPE = 'F' and (a.DIR like '%" + suchDirText + "%' OR a.TEXT like '%" + suchDirText + "%')"
	     + " and a.ckey in " + dirs
	     + " order by a.DIR, a.TEXT";
	return psql;
}

//------------------------------------------------------------------------------
//	authSql	USERTYPE='A' = Abteilung
//------------------------------------------------------------------------------
private String authSql(String pkey) {
	String p1,p2,p3,p4;
	p1 = "Select u.PUSER,USERID,coalesce(l.CANR,'') as CANR from VDOCUSER AS u";
	p2 = " left outer join VDOCAUTH AS l";
	p3 = " on l.PKEY=" + pkey + " and u.PUSER = l.PUSER";
	p4 = " where u.USERTYPE = 'A'";
	return p1 + p2 + p3 + p4;
}
//------------------------------------------------------------------------------
//	authHdr
//------------------------------------------------------------------------------
private String authHdr(String pkey) {
	StringBuilder presp = newSB4();
	ResultSet rs = null;
	try {
		rs = db.getSQLRO(authSql(pkey));
		rs.beforeFirst();
		while (rs.next()) {presp.append("<td nowrap>" + rs.getString("USERID") + "</td>");}
	} catch (Exception e){
		presp = null;
		presp.append("Fehler: " + e.toString());
	} finally {
		try {rs.close();} catch (Exception e){}
	}
	return presp.toString();
}
//------------------------------------------------------------------------------
//	authDet	Detail (neu)
//------------------------------------------------------------------------------
private String authDet(String pkey) {
  StringBuilder presp = newSB4();
	for (int i=1;i<=abteilSpalten;i++) {
		String txt = (isAbtCanr(pkey,Integer.toString(abteilIDs[i]))) ? "X" : "&nbsp;";
		presp.append("<td>" + txt + "</td>");
	}
	return presp.toString();
}
//------------------------------------------------------------------------------
//	authDet	Detail
//------------------------------------------------------------------------------
private String authDetx(String pkey) {
  StringBuilder presp = newSB4();
	ResultSet rs = null;
	try {
		rs = db.getSQLRO(authSql(pkey));
		rs.beforeFirst();
		while (rs.next()) {
			String txt = rs.getString("CANR");
			if (txt.equals("")) txt="&nbsp;";
			presp.append("<td>" + txt + "</td>");
		}
	} catch (Exception e){
		presp = null;
		presp.append("Fehler: " + e.toString());
	} finally {
		try {rs.close();} catch (Exception e){}
	}
	return presp.toString();
}
//============================================================================%>
<%
//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
if (TRACE) db.setTrace(TRACE);
String userPKEY = (String) session.getAttribute("userpkey");
String userPfad = getUserAbts(userPKEY);
String docSelect = (String) session.getAttribute("docSelect");
String pkey = request.getParameter("pkey");
String suchDirText = request.getParameter("suchDirText");
if (suchDirText == null) suchDirText = "";
String[] listOpts = request.getParameterValues("listopt");
final boolean canAdmin = isAdmin(userPKEY);
boolean canRead  = false;
boolean canWrite = false;
boolean listOpt  = true; //Anzeigen
boolean listOptA = (request.getParameter("listOptA") != null) ? true : false; //leere Verzeichnisse ausblenden
boolean listOptB = (request.getParameter("listOptB") != null) ? true : false; //freigegebene Dokumente
boolean listOptC = (request.getParameter("listOptC") != null) ? true : false; //nicht freigegebene Dokumente
boolean listOptD = (request.getParameter("listOptD") != null) ? true : false; //nicht gesehene Dokumente
boolean listOptE = (request.getParameter("listOptE") != null) ? true : false; //nur eigene Dokumente
boolean listOptS = (request.getParameter("listOptS") != null) ? true : false; //sortieren Dir alphabetisch
boolean listOptV = (request.getParameter("listOptV") != null) ? true : false; //Ablauffrist abgelaufen
boolean listOptW = (request.getParameter("listOptW") != null) ? true : false; //Wiedervorlagen anzeigen
listOptA = (suchDirText.length() > 0) ? true : listOptA;
listOptA = (listOptS) ? true : listOptA;
typeInit(pkey);

SimpleDateFormat sdfDateTime = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
SimpleDateFormat sdfDate     = new SimpleDateFormat("yyyy.MM.dd");

String psql = "";
psql = "Select a.*, c.USERID as CRTUSERID, coalesce(u.USERID, a.UPDUSER) as UPDUSERID"
     + ", coalesce(f.USERID, a.FRGUSER) as FRGUSERID"
     + ", " + wvlgSql("a")
     + " from VDOCDIR AS a"
     + " left outer join VDOCUSER AS c"
     + " on a.CRTUSER = c.PUSER"
     + " left outer join VDOCUSER AS f"
     + " on a.FRGUSER = f.PUSER"
     + " left outer join VDOCUSER AS u"
     + " on a.UPDUSER = u.PUSER"
     + " where a.PKEY=" + pkey
     + " order by TYPE, DIR, TEXT";
ResultSet rs = null;
//------------------------------------------------------------------------------
//	Abteilungskopf
//------------------------------------------------------------------------------
String KopfText[] = {
"#1#"
,"#2#"
,"erstellt am"
,(typeApp.equals(vdocApp)) ? "von/Frg" : ""
,(listOptV || listOptW) ? "WV" : ""
};
String saveHead = (typeApp.equals(vdocApp)) ? VDocTablU(getAbtStart(),KopfText) : VDocTablU(-1,KopfText);
String thead = "";
String th1 = "";
String th2 = "";
boolean einHeadGezeigt = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>VDoc Druck</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<link rel="stylesheet" href="vdoc.css">
	<style type="text/css">
	TH {
		font-weight : normal;
		white-space : nowrap;
	}
	TD {
		text-align : center;
	}
	.dir {
		font-weight : normal;
		background-color : #DDDDDD;
	}
	.dirb {
		font-weight : bold;
		text-align : left;
	}
	.doc, .docb {
		font-weight : normal;
		text-align : left;
		vertical-align : top;
	}
</style>
</head>
<body>
<%if (listOpts != null && listOpts.length != 0)  // T E S T 
	{	for (int i = 0; i< listOpts.length; i++)
		{%><br><%= listOpts[i] %><%
		}
	} 
%>
<table border="1" cellspacing="0" cellpadding="0">
<%
	try {	// gibt es das Dokument?
		String docs = "";
		String pfad = "";
		String lvl = " ";
		Stack slvl = new Stack();
		Stack stck = new Stack();
		rs = db.getSQLRO(psql);
		stck.push(rs);
		slvl.push(lvl);
		while (!stck.empty()){
			rs = (ResultSet) stck.pop();
			lvl = (String) slvl.pop();
			while (rs.next()){
				String doctype = (rs.getString("TYPE").equals(typeDir)) ? "dir" : "doc";
				listOpt = (listOptB | listOptC | listOptD) ? false : true;
				if (!canAdmin) {
					if (!rs.getString("PKEY").equals(pkey)) {
						if (typeApp.equals(vdirApp) && rs.getString("TYPE").equals(typeDir)) {
							if (!leseBerechtigung(rs.getString("PKEY"),userPfad)) {continue;}
						}
					}
				}
			 	if (doctype.equals("dir")){
thead = saveHead; 
th1 = " class='"+doctype+"b'>" + "<a href='vdoclist.jsp?pkey="+rs.getString("PKEY")+"' target='list'>"+lvl+rs.getString("DIR")+"</A>";
thead = subst(thead,">#1#",th1);
th2 = " class='"+doctype+"b'>" + rs.getString("TEXT");
thead = subst(thead,">#2#",th2);
			  if (!listOptA){%><%= thead %><%thead = "";einHeadGezeigt=true;}
			  } else { 
					while (true) { // docSelect Anfang
						canRead = canAdmin;
                                         canWrite = (rs.getString("CRTUSER").equals(userPKEY));
						String trStyle = "";
						boolean pFrg;
						String tempPKEY = rs.getString("PKEY");
            boolean wvlgin = rs.getInt("WVLGIN") > 0;
						boolean wvlg = rs.getBoolean("WVLG");
						if (docSelect != null) {
							if (!leseBerechtigung(rs.getString("PKEY"),docSelect)) break;
						}
						if (isOrange(tempPKEY)){
							trStyle = " style='background-color: #FFDD99;'";
						}						
						pFrg = (rs.getLong("FRGDATE")==0) ? false : true;
						pFrg = (typeApp.equals(vdirApp))  ? true  : pFrg;
						if (pFrg) { // Dokument freigegeben
							if (!canRead) canRead = leseBerechtigung(rs.getString("PKEY"),userPfad);
							if (canRead	 && isGreen(tempPKEY) && !db.hasUserDocSeen(tempPKEY,userPKEY)) {
								trStyle = " style='background-color: LightGreen;'";
								if (listOptD) listOpt = true;
							} else { // Dokument wurde schon gesehen
								if (listOptB) listOpt = true;
                                                       if ((canWrite || canAdmin) && wvlg) {
                                                          trStyle = " bgcolor='aqua'";
                                                       } 
							}
						} else { // Dokument noch nicht freigegeben
							if (listOptC) listOpt = true;
							trStyle = " style='background-color: Red;'";
						}
						String erstelltAm = "";
						String lastDocDate = db.getLastDocDate(rs.getString("PKEY"));
						erstelltAm = (rs.getLong(lastDocDate)==0) ? "?" : sdfDate.format(rs.getDate(lastDocDate));
				if (listOptE && !rs.getString("CRTUSER").equals(userPKEY)) listOpt = false;
        if (listOpt && listOptV) listOpt = wvlg; else if (listOpt && listOptW) listOpt = wvlgin;  // nur Ablauffrist abgelaufen anzeigen
				if (listOpt){
					if (!canRead) canRead = (rs.getString("CRTUSER").equals(userPKEY)); // CRTUser darf immer
					if (!canRead) canRead = (rs.getString("FRGUSER").equals(userPKEY)); // FRGUser darf immer
					if (listOptA){%><%= thead %><%thead = "";einHeadGezeigt=true;}%>
				<tr class="<%= doctype %>"<%=trStyle%>>
				<td class="<%= doctype %>b">
					<% if (canRead){
						pfad = (typeApp.equals(vdocApp)) ? db.getPfad(rs.getString("CKEY")) : db.VDirPfad(rs.getString("CKEY")) ;
						docs = (typeApp.equals(vdocApp)) ? "docs/" : "";
					%>
					<a href='vdocactn.jsp?action=showdate&pkey=<%=rs.getString("PKEY")%>&redir=<%=docs%><%=pfad%>/<%=rs.getString("DIR")%>' target='_blank'><%}%>
						<%= rs.getString("DIR") %>
					<% if (canRead){%></a><%}%></td>
				<td class="<%= doctype %>b"><%= rs.getString("TEXT") %></td>
				<td nowrap><%= erstelltAm %></td>
				<% if (typeApp.equals(vdocApp)) { %>
				<td nowrap><%if (!pFrg){%><b><%}%><%=rs.getString("CRTUSERID")%> / <%=(rs.getString("FRGUSERID").equals("0")) ? "" : rs.getString("FRGUSERID")%><%if (!pFrg){%></b><%}%></td>
        <td><% if (listOptV || listOptW){%><%=rs.getString("WVLGMM") %><% } %></td>
					<%=authDet(rs.getString("PKEY"))%>
				<% } %>
				</tr>
			<%}
			  break;} // docSelect Ende
			 }
	 		 	if (rs.getString("TYPE").equals(typeDir)){
					stck.push(rs);
					slvl.push(lvl);
					lvl = "." + lvl;
					if (listOptS)	rs = db.getSQLRO(listsSelect(rs.getString("PKEY"),suchDirText));
					else		rs = db.getSQLRO(listxSelect(rs.getString("PKEY"),suchDirText));
				}
			}
			rs.close();
		}
	} catch (Exception e){
		msg(e.toString());
	} finally {
		try {rs.close();} catch (Exception e){}
	}
%>
</table>
<%if (typeApp.equals(vdocApp) && !einHeadGezeigt)%><h2>Kein Dokument f&uuml;r diese Selektion gefunden</h2>
<%= trace() + msg()%>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>
