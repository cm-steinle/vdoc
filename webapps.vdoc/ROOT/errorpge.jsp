<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%-- ***************************************************************************
*
*		errorpge.jsp
*
*                                        aus JSP (Turau) S.81
*************************************************************************** --%>
<%@ page isErrorPage="true" errorPage="errorpge.jsp"
	import="java.io.*,java.util.*"
	session="false" 
%>
<html>
<head>
	<title>Error Page</title>
</head>
<body>
<%-- ---------------------------------------------------------------------------
		getStackTraceAsString
--------------------------------------------------------------------------- --%>
<%!
	public String getStackTraceAsString(Throwable e) {
		ByteArrayOutputStream bytes = new ByteArrayOutputStream();
		PrintWriter writer = new PrintWriter(bytes, true);
		e.printStackTrace(writer);
		return bytes.toString();
	} 
%>
<h3>Eine Ausnahme der Klasse <%= exception %> ist aufgetreten</h3>
<%
	String erklaerung = exception.getMessage();
	if (erklaerung != null && erklaerung.length() > 0) {
%>
		<b>Ursache:</b><br><%= erklaerung %><p>
<%}%>
<b>Die Aufrufhierarchie:</b>
<pre><% exception.printStackTrace(new PrintWriter(out)); %></pre>
<%-- ---------------------------------------------------------------------------
		Das implizite Objekt request
--------------------------------------------------------------------------- --%>
<h2 align="center">Das implizite Objekt request</h2>
<h3>HTTP-Header</h3>
<%
	Enumeration hn = request.getHeaderNames();
	for (;hn.hasMoreElements();) {
		String s = (String)hn.nextElement();
		out.println(s + " : " + request.getHeader(s) + "<br>");
	}
%>
<%-- ---------------------------------------------------------------------------
		Cookies
--------------------------------------------------------------------------- --%>
<h3>Cookies</h3>
<%
	Cookie[] cookies = request.getCookies();
	int anzahl = cookies.length;
	String anzahlText = (anzahl == 1) ? "ein Cookie" : anzahl + " Cookies";
%>
Insgesamt <%= anzahlText %>
<ol>
<% for (int i = 0; i < anzahl; i++) { %>
	<li>Cookie<br></li>
	Name: <%= cookies[i].getName() %>=<%= cookies[i].getValue() %><br>
<% } %>
</ol>
<%-- ---------------------------------------------------------------------------
		Parameter
--------------------------------------------------------------------------- --%>
<h3>Parameter</h3>
<%
	Enumeration pn = request.getParameterNames();
	for (;pn.hasMoreElements();) {
		String pN = (String)pn.nextElement();
		Object pV = request.getParameter(pN);
%>
<%= pN %>: <%= pV %><br>
<%}%>
<%-- ---------------------------------------------------------------------------
		Sonstiges
--------------------------------------------------------------------------- --%>
<h3>Sonstiges</h3>
HTTP-Methode: <%= request.getMethod() %><br>
Querystring: <%= request.getQueryString() %><br>
RemoteUser: <%= request.getRemoteUser() %><br>
Servername: <%= request.getServerName() %><br>
Character Encoding: <%= request.getCharacterEncoding() %><br>
URL: <%= HttpUtils.getRequestURL(request) %><br>
<hr>
<%-- ---------------------------------------------------------------------------
		Das implizite Objekt pageContext
--------------------------------------------------------------------------- --%>
<h2 align="center">Das implizite Objekt pageContext</h2>
<%!
	String table (int scope, PageContext pc) {
		Enumeration e;
		e = pc.getAttributeNamesInScope(scope);
		if (e == null || !e.hasMoreElements()) return "Keine Objekte";
		StringBuilder erg = new StringBuilder();
		erg.append("<table border='1' cellpadding='3' cellspacing='0'>");
		erg.append("<tr><th>Attribut</th>");
		erg.append("<th>Klasse</th><th>Oberklasse</th>");
		erg.append("<th>Interfaces</th></tr>");
		for (;e.hasMoreElements();) {
			String aName = (String) e.nextElement();
			Object aValue = pc.getAttribute(aName,scope);
			if (aValue != null) {
				Class cl = aValue.getClass();
				Class superCl = cl.getSuperclass();
				Class[] interfaces = cl.getInterfaces();
				erg.append("<tr>");
					erg.append("<td>" + aName + "</td>");
					erg.append("<td>" + cl.getName() + "</td>");
					erg.append("<td>" + superCl.getName() + "</td>");
					erg.append("<td>");
					if (interfaces.length == 0) {
						erg.append("&nbsp;");
					} else {
						for (int i=0; i < interfaces.length-1; i++) {
							erg.append(interfaces[i].getName() + ", ");
						}
						erg.append(interfaces[interfaces.length-1].getName());
					}
			} else {
				erg.append("<tr><td>" + aName + "</td><td>no value</td><td>&nbsp;");
			}
			erg.append("</td></tr>");
		}
		erg.append("</table>");
		return erg.toString();
	}
%>
<h3>Request Scope</h3>
<%= table(javax.servlet.jsp.PageContext.REQUEST_SCOPE,pageContext) %>
<h3>Page Scope</h3>
<%= table(javax.servlet.jsp.PageContext.PAGE_SCOPE,pageContext) %>
<h3>Session Scope</h3>
<%-- table(javax.servlet.jsp.PageContext.SESSION_SCOPE,pageContext) --%>
<h3>Application Scope</h3>
<%= table(javax.servlet.jsp.PageContext.APPLICATION_SCOPE,pageContext) %>
<hr>
<%-- ---------------------------------------------------------------------------
		Das implizite Objekt application
--------------------------------------------------------------------------- --%>
<h2 align="center">Das implizite Objekt application</h2>
Der JSP-Server
<%= application.getServerInfo() %>
verwendet Servlet-Version:
<%= application.getMajorVersion() + "." + application.getMinorVersion() %>
<br>
<hr>
<% 
	String dateiName = "/test.txt";
	out.println("<h3>" + dateiName + " anzeigen.</h3>");
	BufferedReader in;
	try {
		in = new BufferedReader(new InputStreamReader(application.getResourceAsStream(dateiName)));
		String zeile;
		out.println("<pre>");
		while ((zeile = in.readLine()) != null)
			out.println(zeile);
		in.close();
		out.println("</pre>");
	} catch (Exception e) {
		application.log("Datei " + dateiName + " existiert nicht!");
	}
%>
<hr>
<%-- ---------------------------------------------------------------------------
		Das implizite Objekt config
--------------------------------------------------------------------------- --%>
<h2 align="center">Das implizite Objekt config</h2>
<h3>Initialisierungsparameter</h3>
<ol>
<li>Die Context-Initialisierungsparameter</li>
<p>Diese Parameter sehen alle Komponenten der aktuellen Webanwendung</p>
<% 
	boolean gefunden = false;
	String parName;
	Object parWert;
	Enumeration e = application.getInitParameterNames();
	for (;e.hasMoreElements();) {
		gefunden = true;
		parName = (String) e.nextElement();
		parWert = application.getInitParameter(parName);
		out.println("<br>" + parName + ": " + parWert);
	}
	if (!gefunden) {
		out.println("Keine Initialisierungsparameter");
	}
%>
<p><li>Die Initialisierungsparameter</li></p>
<p>Diese Parameter sieht nur diese JSP-Seite.</p>
<%
	gefunden = false;
	e = config.getInitParameterNames();
	for (;e.hasMoreElements();) {
		gefunden = true;
		parName = (String) e.nextElement();
		parWert = config.getInitParameter(parName);
		out.println("<br>" + parName + ": " + parWert);
	}
	if (!gefunden) {
		out.println("Keine Initialisierungsparameter");
	}
%>
</ol>
</body>
</html>
