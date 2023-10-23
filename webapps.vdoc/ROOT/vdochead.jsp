<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.*"%>
<% 
Locale.setDefault(Locale.GERMAN);
DateFormat   df =   DateFormat.getDateTimeInstance(DateFormat.FULL,DateFormat.FULL);
NumberFormat nf = NumberFormat.getInstance(); 
%>
<html>
<head>
<title>VDoc Headline</title>
<meta http-equiv="Refresh" content="600" URL="javascript:location.href=location.href">
<meta http-equiv="Content-Type" content="text/html; charset=charset=iso-8859-1">
<script language="JavaScript" src="dhtml.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript">
<!--
function ZeitAnzeigen() {
var Wochentagname =  new Array("So","Mo","Di","Mi","Do","Fr","Sa");

 var Jetzt = new Date();
 var Tag = Jetzt.getDate();
 var Monat = Jetzt.getMonth() + 1;
 var Jahr = Jetzt.getYear();
 if(Jahr < 999) Jahr += 1900;
 var Stunden = Jetzt.getHours();
 var Minuten = Jetzt.getMinutes();
 var Sekunden = Jetzt.getSeconds();
 var WoTag = Jetzt.getDay();
 var Vortag  = ((Tag < 10) ? "0" : "");
 var Vormon  = ((Monat < 10) ? ".0" : ".");
 var Vorstd  = ((Stunden < 10) ? "0" : "");
 var Vormin  = ((Minuten < 10) ? ":0" : ":");
 var Vorsek  = ((Sekunden < 10) ? ":0" : ":");
 var Datum = Vortag + Tag + Vormon + Monat  + "." + Jahr;
 var Uhrzeit = Vorstd + Stunden + Vormin + Minuten + Vorsek + Sekunden;
 var Gesamt = Wochentagname[WoTag] + ", " + Datum + ", " + Uhrzeit;

 if(DHTML) {
   if(NS) setCont("id","Uhr",null,"<span class=\"Uhr\">" + Gesamt + "<\/span>");
   else   setCont("id","Uhr",null,Gesamt);
 }
 else return;

 window.setTimeout("ZeitAnzeigen()",1000);
}
//-->
</script>
<style type="text/css">	<!--
	#RestDerSeite { position:absolute; top:50px; left:10px; }
	.Uhrx { font-family:Arial; font-size:24px; color:blue; }
	.RestDerSeite { font-family:Arial; color:black; }
.HeadLine {  font-size: 14pt; font-weight: bold; font-family: Verdana, Arial, Helvetica, sans-serif}
.InfoLine {  font-size: 10pt; font-weight: bold; font-family: Verdana, Arial, Helvetica, sans-serif}
.Uhr      {  font-size: 10pt; font-weight: bold; font-family: Verdana, Arial, Helvetica, sans-serif}
#Uhr      {	 position: inherit;		top:0px;		left:0px;	}
.version  {  color : #3366CC; font-weight : bold; text-align: right;}
-->
</style>
</head>
<body bgcolor="#FFFFFF" leftmargin=0 topmargin=0 onLoad="window.setTimeout('ZeitAnzeigen()',1000)">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td class="HeadLine"> 
      <div align="right">H&auml;nel</div>
    </td>
    <td bgcolor="#FFFFFF">&nbsp;&nbsp;&nbsp;&nbsp;</td>
    <td class="HeadLine" nowrap> 
      <div align="left">Dokumenten Verwaltung</div>
    </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td width="12.0%" bgcolor="#00CC66">&nbsp;</td>
    <td width="1.99%" bgcolor="#FFFFFF">&nbsp;</td>
    <td width="33.0%" bgcolor="#FF3300">&nbsp;</td>
    <td width="35.0%" bgcolor="#3366CC">&nbsp;</td>
    <td width="16.0%" bgcolor="#3399FF" class="version">Version 3.0.8 &nbsp;</td>
    <td width="1.99%" bgcolor="#FFFF00">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td bgcolor="#FFFF00">&nbsp;</td>
    <td>&nbsp;</td>
    <td nowrap><span class="InfoLine" id="Uhr" title="Das aktuelle Datum + Zeit auf Ihrem Rechner">&nbsp;</span></td>
    <td nowrap><span class="InfoLine" title="<%= (String) session.getAttribute("fullname") %>">Angemeldet: <%= (String) session.getAttribute("username") %></span></td>
    <td>&nbsp;</td>
  </tr>
</table>
</body>
</html>
