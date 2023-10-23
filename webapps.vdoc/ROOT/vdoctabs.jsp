<%@ page contentType="text/html; charset=ISO-8859-1"%>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
<script language="JavaScript" type="text/javascript">
function tabSwitch(v)
{ if (v == "#") return;
   parent.frames.menu.location = v;
}
</script>
</head>
<body leftmargin=0 marginwidth=0 topmargin=0 marginheight=0 bgcolor="#CECECE">
<applet
   width="100%"
   height="20"
   codebase="java"
   code="com.scand.jtabbar.Tabbar.class"
   archive="jtabbar.jar"
   name="app"
   MAYSCRIPT>

<param name="BGCOLOR" value="#EEEEEE">

<param name=ACTTAB_HEIGHT value=22>
<param name=INACTTAB_HEIGHT value=20>
<param name="ON_SELECT" value="tabSwitch">

<param name="ITEM0" value="vdocmenu2.jsp"> <param name="TEXT0" value="VDoc&nbsp;&nbsp;">
<% String usertype = (String) session.getAttribute("usertype");if (usertype.equals("X")) { %>
<param name="ITEM1" value="vdirmenu.jsp"> <param name="TEXT1" value="VDir&nbsp;&nbsp;">
<param name="ITEM2" value="vdocumenu.jsp"><param name="TEXT2" value="Abteilungen">
<param name="ITEM3" value="vstatistik.jsp"><param name="TEXT3" value="Statistik">
<%}%>
</applet>
</body>
</html>
