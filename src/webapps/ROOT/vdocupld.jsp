<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocforcelogin.jsp"%>
<%@include file="vdocbean.jsp"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%
String action = request.getParameter("action");
String ckey = request.getParameter("ckey");
String text = request.getParameter("text");
text = (text != null) ? text : "";
final boolean TRACE = false;
String trace = "";
trace += "<br>getContentLength=" + request.getContentLength();
trace += "<br>getContentType=" + request.getContentType();
trace += "<br>getMethod=" + request.getMethod();
trace += "<br>-------------------------------------------------";
java.util.Enumeration values = request.getParameterNames();
while (values.hasMoreElements()){
   String name = (String) values.nextElement();
   trace += "<br>Parameter=" + name + "=" + request.getParameterValues(name)[0];
}

Vector paramOrder;
java.util.Hashtable parameters;

if(request.getMethod().equals("POST")) { // && request.getContentType().equals("multipart/form-data")) {
	parameters=HttpUtils.parsePostData(request.getContentLength(),request.getInputStream());
	Enumeration myEnum=parameters.elements();
	while (myEnum.hasMoreElements()) {
		trace += "<br>" + myEnum.nextElement();
	}
%>
<jsp:include page='UploadServlet' flush='true'/>
<%
	trace += "<br>Ausgabe nach receive";
}
trace += "<br>neu";
/*
// ServletInputStream input = request.getInputStream();
//java.util.Hashtable hash = HttpUtils.parsePostData(request.getContentLength(),input);
      //PrintWriter out = response.getWriter();
      out.println("<html><head><title>VDocRecv</title></head><body>");
      if (request.getMethod().equals("POST")
      && request.getContentType().startsWith("multipart/form-data")) {
         int index = request.getContentType().indexOf("boundary=");
         if (index < 0) {
            out.println("can't find boundary type");
            return;
         }
         String boundary = request.getContentType().substring(index+9);
         ServletInputStream instream = request.getInputStream();
//       InputStream instream = request.getInputStream();
         byte[] tmpbuffer = new byte[1024];
         int length=0;
         String inputLine=null;
         boolean moreData=true;

         //Skip until form data is reached
//       length = instream.readLine(tmpbuffer,0,tmpbuffer.length);
//       inputLine = new String (tmpbuffer,0,0,length);
//-------------------------------------------------------
//out.println("<!-- ");
File to_file = new File("/tmp/vdoc/TRANSFER.TXT");
FileOutputStream to = null;
try {
   to = new FileOutputStream(to_file);
   int loop = 10000;
   while ((length = instream.readLine(tmpbuffer,0,tmpbuffer.length)) != -1) {// Read until EOF
      out.println("<br>Gelesen=" + length + " loop=" + loop);
      to.write(tmpbuffer,0,length);                            // Write
      if (loop-- == 0) break;
   }
/*
   while (moreData) {
            length=0;
            inputLine="";
            length = instream.readLine(tmpbuffer,0,tmpbuffer.length);
            if (length >= 0) {
               inputLine = new String (tmpbuffer,0,0,length);
               out.println("<br>Punkt: 0.0 length=" + length + ":" + inputLine); // TRACE
            } else {
               moreData=false;
            }
   }
*/
/*
}
catch (IOException e) {
   out.println("<br>IO-Fehler:" + e.toString());
}
finally {
   if (to != null) try {to.close();} catch (IOException e) {;}
}
}
out.println("</body></html>");
*/
%>
<html>
<head>
	<title>VDoc Upload</title>
	<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
	<script>
		function sendtest(obj) {
			var fehler = false;
			if (obj.TEXT != null && obj.TEXT.value == "") fehler = true;
			if (obj.DIR.value == "") fehler = true;
			if (fehler) {
				alert("Sie muessen eine Datei auswaehlen\nund eine Beschreibung eingeben.");
			}
			return !(fehler);
		}
	</script>
</head>
<body>
<% if (TRACE) { %><%= trace %><% } %>
<% if (action == null){%>
	<h1>Upload ist nur aus VDoc m&ouml;glich!</h1>
<%} else if (!action.equals("crt") && !action.equals("upd")){%>
		<h1>Upload wurde falsch aufgerufen!</h1>
<%} else {%>
	<% if (action.equals("crt")){ %>
		<h2>1. Geben Sie eine Dokumentenbeschreibung ein und<br>
		 2. w&auml;hlen Sie das zu &uuml;bertragende Dokument aus</h2>
	<%} else if (action.equals("upd")){ %>
		<h1>Zur&uuml;ckschreiben ge&auml;ndertes Dokument</h1>
	<%}%>
<form action="servlet/UploadServlet" method="post" enctype="multipart/form-data" onSubmit="return sendtest(this);">
<input type="hidden" name=":respto" value="../vdocdata.jsp?submit=upld&ckey=<%=ckey%>">
<input type="hidden" name=":Directory" value="<%=request.getParameter("at")%>">
<input type="hidden" name=":action" value="<%=request.getParameter("action")%>">
<input type="hidden" name="action" value="<%=request.getParameter("action")%>">
<input type="hidden" name="userpkey" value="<%=session.getAttribute("userpkey")%>">
	<% if (action.equals("crt")){ %>
<input type="text" name="TEXT" value="<%= text %>" size="50" maxlength="100"> Bezeichnung<br>
	<%}%>
<input type="file" name="DIR" size="50"><br>
<input type="submit" name=":submit" value="Senden">
</FORM>
<%}%>
</body>
</html>
<%@include file="vdocbeanclose.jsp.inc"%>
