<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<html>
<head>
<title>H&auml;nel VDoc</title>
<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
<script language="JavaScript" type="text/javascript">
var currentAdmin = <%= (session.getAttribute("usertype").equals("X")) ? "true" : "false" %>;
</script>
</head>
<frameset rows="70,*" cols="*" frameborder="YES">
  <frame name="head" scrolling="AUTO" src="vdochead.jsp" frameborder="YES" marginwidth="0" marginheight="0" >
  <frameset cols="280,*" rows="*" frameborder="YES">
    <frameset rows="42,*" frameborder="YES" cols="*">
    	<frame name="tabs" src="vdoctabs3.jsp" frameborder="NO" scrolling="No" marginwidth="0" marginheight="0">
    	<frame name="menu" src="about:blank"   frameborder="NO" scrolling="auto" marginwidth="0" marginheight="0">
    </frameset>
    <frameset rows="394,*" frameborder="YES" cols="*">
      <frame name="list" scrolling="AUTO" src="vdochead.jsp" marginwidth="0" marginheight="0">
      <frame name="data" scrolling="AUTO" src="about:blank" marginwidth="0" marginheight="0">
    </frameset>
  </frameset>
</frameset>
<noframes>
<body bgcolor="#FFFFFF">
<font size="5" face="Verdana, Arial, Helvetica, sans-serif"><b>Ihr Browser unterst&uuml;tzt
keine Frames! </b></font>
</body>
</noframes>
</html>
