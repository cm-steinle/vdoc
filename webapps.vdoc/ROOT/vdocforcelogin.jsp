<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%
//String aut = request.getHeader("Authorization");
String _username = (String) session.getAttribute("username");
if (_username == null) {
	// String _page = request.getRequestURI();
%>
<jsp:forward page='vdoclogin.jsp'/>
<% } %>