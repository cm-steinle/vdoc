<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<%@include file="vdocbase.jsp"%>
<%@ page import="java.util.*"%>
<%!//===========================================================================
//
//      V e r e i n b a r u n g e n
//
//==============================================================================
int abteilSpalten = 0;
int abteilIDs[] = new int[100];
//------------------------------------------------------------------------------
//      User Abfrage
//------------------------------------------------------------------------------
private String userSelect() {
        return "Select PUSER,CUSER,USERTYPE,USERID,FULLNAME from VDOCUSER"
                 + " where USERTYPE='U' order by USERID";
}
//------------------------------------------------------------------------------
//      SQL-Statement zusammenbauen
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
//      Abteilungs/User Tree-Struktur erstellen
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
        //      maximal Level ermitteln
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
        //                      abteilIDs[abteilSpalten] = rs.getInt("PUSER");
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

private String inpFld(String i, String name) {
        return i + "_" + name;
}
private String authCrt(String pkey) {
        String psql, presp="";
        //psql = "Select u.PUSER, l.* from VDOCUSER AS u";
        psql = "Select u.PUSER from VDOCUSER AS u";
        psql += " left outer join VDOCAUTH AS l";
        psql += " on l.PKEY=" + pkey + " and u.PUSER = l.PUSER";
        psql += " where u.USERTYPE in ('A','U')";
        psql += " and l.PUSER is null";
        ResultSet rs = null, rn = null;
        try {
presp += "A";
                rn = db.getSQLRU("select * from VDOCAUTH where PKEY=" + pkey);
                rn.beforeFirst();
presp += "B";
                rs = db.getSQLRO(psql);
presp += "C";
                while (rs.next()) {

presp += "D";
                        presp += rs.getString("PUSER") + "<br>";
                        rn.moveToInsertRow();
presp += "E";
                        rn.updateString("PKEY",pkey);
presp += "F";
                        rn.updateString("PUSER",rs.getString("PUSER"));
                        rn.updateNull("CANR");
                        rn.updateNull("CANW");
                        rn.updateLong("SHOWDATE",0);
presp += "G";
                        rn.insertRow();
presp += "H";
                }
presp += "I";
        } catch (Exception e) {
                presp += e.toString() + "<br>";
        } finally {
                try {rs.close();} catch (Exception e){}
                try {rn.close();} catch (Exception e){}
        }
        return presp;
}
//============================================================================%>
<%
//==============================================================================
//
//      A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
db.setTrace(TRACE);
final String SPEICHERN  = "Speichern";
final String ABBRUCH  = "Abbrechen";

String trace = "";
String typeText = "Berechtigungen Verwalten";
String type;
String puser = "0";
String crtUser = "???"; // Ersteller
String frgUser = "???"; // Freigabe User
String wvlgin = "0"; // Wiedervorlage in x Jahren
String psql = "";
ResultSet rs = null;

String pkey = request.getParameter("pkey");
String submit = request.getParameter("submit");
String rows = request.getParameter("rows");
String frguser = request.getParameter("frguser");
//------------------------------------------------------------------------------
//      Tracen
//------------------------------------------------------------------------------
if (TRACE) {
        trace += "pkey=" + pkey + "<br>";
        trace += "submit=" + submit + "<br>";
        trace += "rows=" + rows + "<br>";
}
//------------------------------------------------------------------------------
//      Submit verarbeiten
//------------------------------------------------------------------------------
if (submit != null && submit.equals(SPEICHERN)) {
db.log("Submit verarbeiten anfang speichern");
        int rowCount = 0;
        try {rowCount = Integer.parseInt("0" + rows);} catch (Exception e) {}
        trace += authCrt(pkey);
db.log("anf select * from VDOCAUTH where PKEY=" + pkey);
        ResultSet rn = db.getSQLRO("select * from VDOCAUTH where PKEY=" + pkey);
db.log("end select * from VDOCAUTH where PKEY=" + pkey);
        while (rn.next()) {
                String onOff = request.getParameter(inpFld(rn.getString("PUSER"),"canr"));
                String canr;
db.log("anf rn.getString('SHOWDATE')" );
                String showdate = (rn.getLong("SHOWDATE")==0) ? "?" : rn.getString("SHOWDATE");
db.log("end rn.getString('SHOWDATE')=" + showdate);
                if (onOff == null) {
                        //rn.updateNull("CANR");
                        canr = " = null";
                } else {
                        //rn.updateString("CANR","X");
                        canr = " = 'X'";
                }
                //rn.updateRow();
db.log("anf Start UPDATE VDOCAUTH SET CANR" + canr + " where PKEY=" + rn.getString("PKEY") +" and PUSER=" + rn.getString("PUSER"));
                ResultSet ru = db.getSQLRU("UPDATE VDOCAUTH SET CANR" + canr + " where PKEY=" + rn.getString("PKEY") +" and PUSER=" + rn.getString("PUSER"));
        }
        rn.close();
        // ---------------------------------
        // Wiedervorlage
        // ---------------------------------
        int wvlgArr[] = new int[10];
        wvlgArr[1] = (request.getParameter("wvlgin1") == null) ? 0 : 1;
        wvlgArr[2] = (request.getParameter("wvlgin2") == null) ? 0 : 2;
        wvlgArr[3] = (request.getParameter("wvlgin3") == null) ? 0 : 3;
        wvlgArr[4] = (request.getParameter("wvlgin4") == null) ? 0 : 4;
        wvlgArr[5] = (request.getParameter("wvlgin5") == null) ? 0 : 5;
        int neuWvlgin = 0;
        for (int e : wvlgArr) if (e > neuWvlgin) neuWvlgin = e;
        db.getSQLRU("UPDATE VDOCDIR SET WVLGIN=" + neuWvlgin + " where PKEY=" + pkey);
        // ---------------------------------
        // FreigabeUser
        // ---------------------------------
        String frgUSER = " = '" + frguser + "'";
db.log("Start UPDATE VDOCDIR SET FRGUSER" + frgUSER + ", FRGDATE=0 where PKEY=" + pkey + " and FRGUSER <> " + frguser);
        ResultSet ru = db.getSQLRU("UPDATE VDOCDIR SET FRGUSER" + frgUSER + ", FRGDATE=0 where PKEY=" + pkey + " and FRGUSER <> " + frguser);
        for (int i = 0; i < rowCount; i++){
//              if (TRACE) trace += request.getParameter(inpFld(i,"puser")) + "=" + request.getParameter(inpFld(i,"canr")) + "<br>";

        }
db.log("Submit verarbeiten end");
}
//------------------------------------------------------------------------------
//      Anzeige aufbereiten
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
                wvlgin = rs.getString("WVLGIN");
        }
%>
<%
//------------------------------------------------------------------------------
//      H T M L
//------------------------------------------------------------------------------
%>
<html>
<head>
        <title><%=typeText%></title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
        <link rel="stylesheet" href="vdoc.css">
</head>
<body>
<%
//------------------------------------------------------------------------------
//      Dokument Infos
//------------------------------------------------------------------------------
%>
<%if (TRACE) {%><%=trace%><%}%>
  <table>
    <tr>
      <th colspan="2" nowrap class="blue"><%=typeText%> </th>
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
<%
} catch (Exception e) {
%><%= e.toString() %><br><%
} finally {
        try {rs.close();} catch (Exception e){}
}
//------------------------------------------------------------------------------
//      Freigabe durch - und Wiedervorlage in x Jahren
//------------------------------------------------------------------------------
%>
<form method="post">
<input type="hidden" name="pkey" value="<%= pkey %>">
        <table>
        <tr><th class='blue'>Freigabe durch</th>
        <td><select name="frguser">freigabe" size="1">
        <option value='0'>?</option>
<%
psql = "Select u.PUSER,USERID,coalesce(l.CANR,'') as CANR from VDOCUSER AS u";
psql += " left outer join VDOCAUTH AS l";
psql += " on l.PKEY=" + pkey + " and u.PUSER = l.PUSER";
psql += " where (u.USERTYPE='U' and (u.PUSER <> " + crtUser +" or u.SELFFRG=true)) or u.USERTYPE='X' or (u.USERTYPE='U' and u.USERID='MH disab')";
psql += " order by u.USERID";
rs = db.getSQLRO(psql);
i=0;
rs.beforeFirst();
while (rs.next()) {%>
<option value='<%=rs.getString("PUSER")%>' <%if (rs.getString("PUSER").equals(puser)) {%>selected<%}%>><%=rs.getString("USERID")%></option>
<%i++;}
rs.close();
%></select></td><td>&nbsp;</td>

<th class='blue'>Aktualisierung:</th>
<td><input type="checkbox" name="wvlgin1" <%if (wvlgin.equals("1")) {%>checked<%}%>></td><td>j�hrlich</td>
<td><input type="checkbox" name="wvlgin2" <%if (wvlgin.equals("2")) {%>checked<%}%>></td><td>alle 2 Jahre</td>
<td><input type="checkbox" name="wvlgin3" <%if (wvlgin.equals("3")) {%>checked<%}%>></td><td>alle 3 Jahre</td>
<td><input type="checkbox" name="wvlgin4" <%if (wvlgin.equals("4")) {%>checked<%}%>></td><td>alle 4 Jahre</td>
<td><input type="checkbox" name="wvlgin5" <%if (wvlgin.equals("5")) {%>checked<%}%>></td><td>alle 5 Jahre</td>

</tr></table>
        <br>
<%
//------------------------------------------------------------------------------
//      Abteilungen
//------------------------------------------------------------------------------
String KopfText[] = {}; %>
<table border=2><%= VDocTablU(0,KopfText) %>
<% for ( i=1;i<=abteilSpalten;i++) {
        String checked = (isAbtCanr(pkey,Integer.toString(abteilIDs[i]))) ? " checked" : "";
%>
<td><input type="checkbox" name="<%= inpFld(Integer.toString(abteilIDs[i]),"canr") %>"<%= checked %>><input type="hidden" name="<%= inpFld(Integer.toString(abteilIDs[i]),"puser") %>" value="<%= abteilIDs[i]%>"></td>
<% } %>
</tr>
</table>
<br>
<%
//------------------------------------------------------------------------------
//      Benutzer
//------------------------------------------------------------------------------
%>
        <table>
        <tr class='blue'><th>Benutzer</th></tr>
        <tr><td><table>
<%
psql = "Select u.PUSER,u.FULLNAME,USERID,coalesce(l.CANR,'') as CANR from VDOCUSER AS u";
psql += " left outer join VDOCAUTH AS l";
psql += " on l.PKEY=" + pkey + " and u.PUSER = l.PUSER";
psql += " where u.USERTYPE='U' and u.PUSER <> " + crtUser;
psql += " order by u.USERID";
rs = db.getSQLRO(psql);
rs.beforeFirst();
while (rs.next()) {%>
<tr>
<th bgcolor=#9999FF><%=rs.getString("USERID")%>
        <input type="hidden" name="<%=inpFld(rs.getString("PUSER"),"puser")%>" value="<%= rs.getString("PUSER")%>">
</th>
<td bgcolor=#cccccc><input type="checkbox" name="<%=inpFld(rs.getString("PUSER"),"canr")%>" <%if (rs.getString("CANR").equals("X")) {%>checked<%}%>>
</td>
<td bgcolor=#eeeeee><%= rs.getString("FULLNAME")%>
</td>
</tr>
<%i++;}
rs.close();
%></table></td></tr></table>
        <br>
<%
//------------------------------------------------------------------------------
//      Submit
//------------------------------------------------------------------------------
%>
        <input type="hidden" name="rows" value="<%=i%>">
        <input type="submit" name="submit" value="<%= SPEICHERN %>">
        <!--input type="reset" name="submit" value="<%= ABBRUCH %>"-->
        <input type="reset" value="<%= ABBRUCH %>" onClick="location.href='leer.htm'">
</form>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>
