<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocbean.jsp"%>
<%@page import='java.io.*, java.util.*, java.sql.*,
                javax.naming.*, javax.naming.directory.*' %>
<!-- %@include file='prop-auth.jsp' %-->
<html><head><title>HTTP Login Page</title>
<meta http-equiv="Content-Type" content="text/html; Charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
  <!-- Hide script from older browsers
    if (self.parent.frames.length != 0)
      self.parent.location=document.location;
  // end hiding contents -->
</SCRIPT>
</head><body>
<%
	String auth = request.getHeader("Authorization");
	if (request.getParameter("force") != null) {
		auth = null;
		session.removeAttribute("fullname");
		// if (request.getSession(false) != null) {session.invalidate();}
	}
	if (auth != null) {
		auth = decodeBase64(auth.substring(6));
    String username = auth.substring(0,auth.indexOf(':'));
    String password = auth.substring(1+auth.indexOf(':'));
    if (db.validateUser(username, password)) {
			ResultSet rs = db.getSQLRO("Select * from VDOCUSER where USERID='" + username + "' and PASSWORD='" + password + "'");
      rs.next();
			session.setAttribute("userpkey",rs.getString("PUSER"));
			session.setAttribute("username",rs.getString("USERID"));
			session.setAttribute("fullname",rs.getString("FULLNAME"));
			session.setAttribute("usertype",rs.getString("USERTYPE"));
			rs.close();
			response.sendRedirect("/");
      return;
    } else { %>
      <h2>Invalid credentials!</h2>
<%	}
	} else if (session.getAttribute("fullname") != null) {
		response.sendRedirect("/vdoctest.jsp?x=2");
		return;
	}
%>

<H3>SimpleForum Login</H3>
Please authenticate using your browser.

<%
   response.setStatus(response.SC_UNAUTHORIZED);
   response.setHeader("WWW-Authenticate", "Basic Realm=\"VDoc\"");
%>

</body></html>

<%!
    /**
      * The base64 method was posted to the SERVLET-INTEREST
      * newsgroup (SERVLET-INTEREST@JAVA.SUN.COM). It is
      * assumed to be public domain.
      */
    static final char[] b2c=
    {
        'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
        'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
        'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
        'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
    };

    static final char pad = '=';
    static byte[] c2b = null;

    /**
      * Decode a base64 encoded string.
      * @param s The base64 encoded string
      * @return The decoded string
      */
    public static String decodeBase64(String s)
    {
        if (c2b==null) {
            c2b = new byte[256];
            for (byte b=0;b<64;b++) c2b[(byte)b2c[b]]=b;
        } // end if

        byte[] nibble = new byte[4];
        char[] decode = new char[s.length()];
        int d=0;
        int n=0;
        byte b;
        for (int i=0;i<s.length();i++) {
            char c = s.charAt(i);
            nibble[n] = c2b[(int)c];

            if (c==pad) break;

            switch(n) {
            case 0:
                n++;
                break;

            case 1:
                b=(byte)(nibble[0]*4 + nibble[1]/16);
                decode[d++]=(char)b;
                n++;
                break;

            case 2:
                b=(byte)((nibble[1]&0xf)*16 + nibble[2]/4);
                decode[d++]=(char)b;
                n++;
                break;

            default:
                b=(byte)((nibble[2]&0x3)*64 + nibble[3]);
                decode[d++]=(char)b;
                n=0;
                break;
            }
        }
        String decoded = new String(decode,0,d);
        return decoded;
    }
%>
<%@include file="vdocbeanclose.jsp.inc"%>
