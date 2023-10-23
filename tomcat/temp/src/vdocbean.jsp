<%@ page contentType="text/html; charset=ISO-8859-1" session="true" %>
<%@ page isThreadSafe="false"%>
<%@ page errorPage="errorpge.jsp"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="de.readysoft.vdoc.VDocBean"%>
<jsp:useBean id="vdocdb" scope="session" class="de.readysoft.vdoc.VDocBean"> 
	<jsp:setProperty name="vdocdb" property="properties" value="dbprops.txt"/>
	<%
// 		vdocdb.connect();
		session.setMaxInactiveInterval(900);
	%>
</jsp:useBean>
<%!
final String TIMESTMP0 = "0000-00-00 00:00:00";

VDocBean db;
%>
<% db = vdocdb; %>
<%-- <% db.connect(); %> --%>
<% synchronized(db){db.setDocsPfad(request.getRealPath("/"));} %>
<% String vdocURI = URLEncoder.encode(request.getRequestURI() + "?" + request.getQueryString()); %>
<% vdocdb.logInfo("Uri=" + request.getRequestURI() + "?" + request.getQueryString()); %>