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
typeInit(pkey);
//------------------------------------------------------------------------------
//	H T M L
//------------------------------------------------------------------------------
%>
<html>
<head>
	<title><%=typeText%></title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<link rel="stylesheet" href="vdoc.css">	
</head>
<body>
	<form action="vdocdrck.jsp" method="post">
	<input type="hidden" name="pkey" value="<%=pkey%>">
	Start-Verzeichnis: <%=textDir%>
  <table border="0" cellspacing="0" cellpadding="0">
  	 <tr>
      <td class="blue" nowrap>Suchen Dateiname oder Bezeichnung &nbsp;</td>
	 	<td class="blue" nowrao><input type="text" name="suchDirText" value="" size="40"></b></td>
    </tr>
  </table>
  <br>
  <table border="0" cellspacing="0" cellpadding="0">
    <tr>
	 	<td>&nbsp;</td>
	 	<td><b><%=typeText%></b></td>
    </tr>
    <tr class="blue"> 
      <td nowrap><input type="checkbox" name="listOptA" value="a" checked="checked" ></td>
      <td nowrap>leere Verzeichnisse ausblenden &nbsp;</td>
    </tr>
<% if (typeApp.equals(vdocApp)){%>
    <tr class="blue"> 
      <td nowrap><input type="checkbox" name="listOptE" value="e"></td>
      <td nowrap>nur eigene Dokumente anzeigen &nbsp;</td>
    </tr>
    <tr class="blue"> 
      <td colspan="2" nowrap><hr size="1" color="#FFFFFF" noshade></td>
    </tr>
    <tr class="blue"> 
      <td nowrap><input type="checkbox" name="listOptB" value="b"></td>
      <td nowrap>freigegebene Dokumente &nbsp;</td>
    </tr>
    <tr class="blue"> 
      <td nowrap><input type="checkbox" name="listOptC" value="c"></td>
      <td nowrap>noch nicht freigegebene Dokumente &nbsp;</td>
    </tr>
    <tr class="blue"> 
      <td nowrap><input type="checkbox" name="listOptD" value="d"></td>
      <td nowrap>noch nicht gesehene Dokumente &nbsp;</td>
    </tr>
    <tr class="blue"> 
      <td colspan="2" nowrap><hr size="1" color="#FFFFFF" noshade></td>
    </tr>
    <tr class="blue"> 
      <td nowrap><input type="checkbox" name="listOptV" value="v"></td>
      <td nowrap>Wiedervorlagefrist abgelaufen &nbsp;</td>
    </tr>
    <tr class="blue"> 
      <td nowrap><input type="checkbox" name="listOptW" value="w"></td>
      <td nowrap>Wiedervorlagen RestMonate &nbsp;</td>
    </tr>
    <tr class="blue"> 
      <td colspan="2" nowrap><hr size="1" color="#FFFFFF" noshade></td>
    </tr>
    <tr class="blue"> 
      <td nowrap><input type="checkbox" name="listOptS" value="s"></td>
      <td nowrap>sortieren Dateiname(alphabetisch) &nbsp;</td>
    </tr>
<%}%>
	</table>
	<input type="submit" name=":submit"    value="Liste starten">&nbsp;
	<input type="reset" value="Abbrechen" onClick="location.href='leer.htm'">
	</FORM>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>