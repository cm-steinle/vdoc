/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: Apache Tomcat/9.0.82
 * Generated at: 2023-10-23 08:23:05 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import java.sql.*;
import java.net.URLEncoder;
import de.readysoft.vdoc.VDocBean;
import java.io.*;
import java.util.*;

public final class vdocdata2_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent,
                 org.apache.jasper.runtime.JspSourceImports,
                 javax.servlet.SingleThreadModel {


final String TIMESTMP0 = "0000-00-00 00:00:00";

VDocBean db;

//===========================================================================
//
//	B a s i s r o u t i n e n 
//
//==============================================================================
boolean TRACE = false;
final String vdocGreen = "8";	// Anzahl Monate fuer gruene Zeilenanzeige
final String vdocApp = "VDoc";
final String vdocCSS = "vdoc";
final String vdocTop = "T";
final String vdocDir = "D";
final String vdocDoc = "F";
final String vdirApp = "VDir";
final String vdirCSS = "vdir";
final String vdirTop = "U";
final String vdirDir = "V";
final String vdirDoc = "W";
String typeApp = "";	// VDoc oder VDir Application
String typeTop = "";
String typeDir = "";
String typeDoc = "";
String typeCSS = "";
//------------------------------------------------------------------------------
//	typeXxx-Felder aufgrund pkey-TYPE initialisieren
//------------------------------------------------------------------------------
private void typeInit(String pkey){
	String pkeyType = "";
	try {
		pkeyType = db.getWERT(pkey,"TYPE");
	} catch (Exception e){
		err(e.toString());
	}
	if (pkeyType.equals(vdocDir) || pkeyType.equals(vdocDoc)) {
		typeTop = vdocTop;
		typeDir = vdocDir;
		typeDoc = vdocDoc;
		typeCSS = vdocCSS;
		typeApp = vdocApp;
	}
	if (pkeyType.equals(vdirDir) || pkeyType.equals(vdirDoc)) {
		typeTop = vdirTop;
		typeDir = vdirDir;
		typeDoc = vdirDoc;
		typeCSS = vdirCSS;
		typeApp = vdirApp;
	}
}
//------------------------------------------------------------------------------
// StringBuilder erzeugen
//------------------------------------------------------------------------------
private static final StringBuilder newSBx(int k){
  return new StringBuilder(1024 * k);
}
private static StringBuilder newSB(){
  return newSB1();
}
private static StringBuilder newSB1(){
  return newSBx(1);
}
private static StringBuilder newSB2(){
  return newSBx(2);
}
private static StringBuilder newSB4(){
  return newSBx(4);
}
private static StringBuilder newSB8(){
  return newSBx(8);
}
//------------------------------------------------------------------------------
//	Trace Daten Erfassen/Ausgeben)
//------------------------------------------------------------------------------
StringBuilder traceText = (TRACE) ? newSB4() : newSB();
private void trace(String text){
	if (TRACE) traceText.append("<br>" + text);
}
private String trace(){
	return trace(true);
}
private String trace(boolean del) {  // del loescht die Texte
	String text = traceText.toString();
	if (del) traceText.setLength(0);
	return text;
}
//------------------------------------------------------------------------------
//	Fehler Erfassen/Ausgeben)
//------------------------------------------------------------------------------
StringBuilder errText = newSB();
private void err(String text){
	errText.append(text + "<br>");
}
private String err(){
	return err(true);
}
private String err(boolean del){	// del loescht die Texte
	if (!isErr()) return "";
	String text = errText.toString();
	if (del) errText.setLength(0);
	return "<span class='fehler'><br>" + text + "</span>";
}
private boolean isErr(){
	return (errText.length() != 0);
}
//------------------------------------------------------------------------------
//	Nachrichten Erfassen/Ausgeben)
//------------------------------------------------------------------------------
StringBuilder msgText = newSB();
private void msg(String text){
	msgText.append(text + "<br>");
}
private String msg(){
	return msg(true);
}
private String msg(boolean del){	// del loescht die Texte
	if (!isMsg()) return "";
	String text = msgText.toString();
	if (del) msgText.setLength(0);
	return "<span class='hinweis'><br>" + text + "</span>";
}
private boolean isMsg(){
	return (msgText.length() != 0);
}
//------------------------------------------------------------------------------
//	SQLExceptions in err ausgeben
//------------------------------------------------------------------------------
private void sqlErr(SQLException s){
	err("SQLException");
	while (s != null) {
		err("SQLState : " + s.getSQLState());
		err("ErrorCode: " + s.getErrorCode());
		err("Nachricht: " + s.getMessage());
		s = s.getNextException();
	}
}
//------------------------------------------------------------------------------
//	SQLWarnings in msg ausgeben
//------------------------------------------------------------------------------
private void sqlMsg(SQLWarning w){
	if (w != null) msg("SQLWarning");
	while (w != null) {
		msg("SQLState : " + w.getSQLState());
		msg("ErrorCode: " + w.getErrorCode());
		msg("Nachricht: " + w.getMessage());
		w = w.getNextWarning();
	}
}
//------------------------------------------------------------------------------
//	subst(String in, String find, String newStr)
//------------------------------------------------------------------------------
public static String subst(String in, String find, String newStr){
    char[] working = in.toCharArray();
    StringBuilder sb = newSB();
	int startindex = in.indexOf(find);
	if (startindex<0) return in;
	int currindex=0;
	while (startindex > -1) {
		for(int i = currindex; i < startindex; i++){
			sb.append(working[i]);
		}//for
	 	currindex = startindex;
		sb.append(newStr);
		currindex += find.length();
		startindex = in.indexOf(find,currindex);
	}//while
	for (int i = currindex; i < working.length; i++){
		sb.append(working[i]);
	}//for
	return sb.toString();
  } //subst
//------------------------------------------------------------------------------
//	Abteilungszuordnung eines Users
//------------------------------------------------------------------------------
private String getUserAbts(String puser){
	String pfad = puser;
	try {
		ResultSet rx = db.getSQLRO("select CUSER from VDOCUABT where PUSER="+puser);
		while (rx.next()) pfad += "," + rx.getString("CUSER");
		rx.close();
	} catch (Exception e) {
		err(e.toString());
	}
	return pfad;
}
//------------------------------------------------------------------------------
//	isAbtCanr Darf die Abteilung das Dokument lesen?
//------------------------------------------------------------------------------
private boolean isAbtCanr(String pkey, String pabt) {
	boolean checked = false;
	ResultSet rx = null;
	try {
		rx = db.getSQLRO("select CANR from VDOCAUTH where PKEY="+pkey+" and PUSER="+pabt+" and CANR='X'");
		while (rx.next()) checked = true;
	} catch (Exception e) {
		err(e.toString());
	} finally {
		try {rx.close();} catch (Exception e){}
	}
	return checked;
}
//------------------------------------------------------------------------------
//	Leseberechtigung ermitteln
//------------------------------------------------------------------------------
private boolean leseBerechtigung(String pkey,String pfad) {
	ResultSet rs = null;
	boolean canRead = false;
	try {
		rs = db.getSQLRO("select count(*) from VDOCAUTH where PKEY=" + pkey + " and CANR='X' and PUSER in (" + pfad + ")");
		rs.next();
		canRead = (rs.getInt(1) == 0) ? false : true;
	} catch (Exception e){
	} finally {
		try {rs.close();} catch (Exception e){}
	}
	return canRead;
}
//------------------------------------------------------------------------------
//	isGreen ist das Dokument aelter als 8 Monate?
//------------------------------------------------------------------------------
private boolean isGreen(String pkey){
	ResultSet rs = null;
	boolean pbResp = false;
	int resp = 0;
	try {
		rs = db.getSQLRO("SELECT count(*) from VDOCDIR where PKEY=" + pkey
				+ " and ("
				+ "    (UPDDATE + INTERVAL " + vdocGreen + " MONTH) > NOW()"
				+ " or (CRTDATE + INTERVAL " + vdocGreen + " MONTH) > NOW()"
				+ ")");
		if (rs.next()) {
			resp = rs.getInt(1);
			pbResp = (resp != 0);
		}
	} catch (Exception e) {
	} finally {
	  try {rs.close();} catch (Exception e){}
	}
	return pbResp;
}
//------------------------------------------------------------------------------
//	isOrange hat das Dokument keine Berechtigung fuer C-Doc oder D-Doc?
//------------------------------------------------------------------------------
private boolean isOrange(String pkey){
	ResultSet rs = null;
	boolean pbResp = true; // Dokument hat keine Berechtigung für bestimmte Abtlg.
	int resp = 0;
	try {
		rs = db.getSQLRO("SELECT count(*) from VDOCAUTH where PKEY=" + pkey
				+ " and PUSER in (177,178) and CANR='X'");
		if (rs.next()) {
			resp = rs.getInt(1);
			pbResp = (resp == 0); 
		}
	} catch (Exception e) {
	} finally {
	  try {rs.close();} catch (Exception e){}
	}
	return pbResp;
}
//------------------------------------------------------------------------------
//	Ist der Admin angemeldet?
//------------------------------------------------------------------------------
private String userAdmin = null;
private boolean isAdmin(String userPKEY) {
	boolean admin = false;
	// if (userAdmin != null) {return userAdmin.equals(userPKEY);}
	try {
		admin = (db.getUSERWERT(userPKEY,"USERTYPE").equals("X")) ? true : false;
	} catch (Exception e){}
	userAdmin = (admin) ? userPKEY:"";
	return admin;
}
//------------------------------------------------------------------------------
//	Wiedervorlage (SQL-Fragment)
//------------------------------------------------------------------------------
private String wvlgSql(String prefix){
String prfx = (prefix == null || prefix.length() != 1) ? "" : prefix + ".";
String WVLGIN  = prfx + "WVLGIN";
String CRTDATE = prfx + "CRTDATE";
String UPDDATE = prfx + "UPDDATE";
 
String psql = "";
psql += " case";
psql += " when "+ WVLGIN +" = 0 then false";
psql += " when (if("+ CRTDATE +" > "+ UPDDATE +", "+ CRTDATE +", "+ UPDDATE +") + interval "+ WVLGIN +" year) < now() then true";
psql += " else false";
psql += " end as WVLG";
psql += ", ";
psql += " PERIOD_DIFF(";
psql += "EXTRACT(YEAR_MONTH from (if("+ CRTDATE +" > "+ UPDDATE +", "+ CRTDATE +", "+ UPDDATE +") + interval "+ WVLGIN +" year)),";
psql += "EXTRACT(YEAR_MONTH from now())";
psql += ") as WVLGMM";
return psql;
}
//============================================================================
//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
//int abteilSpalten = 0;

//============================================================================
  private static final javax.servlet.jsp.JspFactory _jspxFactory =
          javax.servlet.jsp.JspFactory.getDefaultFactory();

  private static java.util.Map<java.lang.String,java.lang.Long> _jspx_dependants;

  static {
    _jspx_dependants = new java.util.HashMap<java.lang.String,java.lang.Long>(3);
    _jspx_dependants.put("/vdocbeanclose.jsp.inc", Long.valueOf(1697119915000L));
    _jspx_dependants.put("/vdocbean.jsp", Long.valueOf(1697119915000L));
    _jspx_dependants.put("/vdocbase.jsp", Long.valueOf(1697119915000L));
  }

  private static final java.util.Set<java.lang.String> _jspx_imports_packages;

  private static final java.util.Set<java.lang.String> _jspx_imports_classes;

  static {
    _jspx_imports_packages = new java.util.HashSet<>();
    _jspx_imports_packages.add("java.sql");
    _jspx_imports_packages.add("javax.servlet");
    _jspx_imports_packages.add("java.util");
    _jspx_imports_packages.add("javax.servlet.http");
    _jspx_imports_packages.add("java.io");
    _jspx_imports_packages.add("javax.servlet.jsp");
    _jspx_imports_classes = new java.util.HashSet<>();
    _jspx_imports_classes.add("java.net.URLEncoder");
    _jspx_imports_classes.add("de.readysoft.vdoc.VDocBean");
  }

  private volatile javax.el.ExpressionFactory _el_expressionfactory;
  private volatile org.apache.tomcat.InstanceManager _jsp_instancemanager;

  public java.util.Map<java.lang.String,java.lang.Long> getDependants() {
    return _jspx_dependants;
  }

  public java.util.Set<java.lang.String> getPackageImports() {
    return _jspx_imports_packages;
  }

  public java.util.Set<java.lang.String> getClassImports() {
    return _jspx_imports_classes;
  }

  public javax.el.ExpressionFactory _jsp_getExpressionFactory() {
    if (_el_expressionfactory == null) {
      synchronized (this) {
        if (_el_expressionfactory == null) {
          _el_expressionfactory = _jspxFactory.getJspApplicationContext(getServletConfig().getServletContext()).getExpressionFactory();
        }
      }
    }
    return _el_expressionfactory;
  }

  public org.apache.tomcat.InstanceManager _jsp_getInstanceManager() {
    if (_jsp_instancemanager == null) {
      synchronized (this) {
        if (_jsp_instancemanager == null) {
          _jsp_instancemanager = org.apache.jasper.runtime.InstanceManagerFactory.getInstanceManager(getServletConfig());
        }
      }
    }
    return _jsp_instancemanager;
  }

  public void _jspInit() {
  }

  public void _jspDestroy() {
  }

  public void _jspService(final javax.servlet.http.HttpServletRequest request, final javax.servlet.http.HttpServletResponse response)
      throws java.io.IOException, javax.servlet.ServletException {

    if (!javax.servlet.DispatcherType.ERROR.equals(request.getDispatcherType())) {
      final java.lang.String _jspx_method = request.getMethod();
      if ("OPTIONS".equals(_jspx_method)) {
        response.setHeader("Allow","GET, HEAD, POST, OPTIONS");
        return;
      }
      if (!"GET".equals(_jspx_method) && !"POST".equals(_jspx_method) && !"HEAD".equals(_jspx_method)) {
        response.setHeader("Allow","GET, HEAD, POST, OPTIONS");
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "JSPs only permit GET, POST or HEAD. Jasper also permits OPTIONS");
        return;
      }
    }

    final javax.servlet.jsp.PageContext pageContext;
    javax.servlet.http.HttpSession session = null;
    final javax.servlet.ServletContext application;
    final javax.servlet.ServletConfig config;
    javax.servlet.jsp.JspWriter out = null;
    final java.lang.Object page = this;
    javax.servlet.jsp.JspWriter _jspx_out = null;
    javax.servlet.jsp.PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html; charset=ISO-8859-1");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			"errorpge.jsp", true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write('\r');
      out.write('\n');
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      de.readysoft.vdoc.VDocBean vdocdb = null;
      synchronized (session) {
        vdocdb = (de.readysoft.vdoc.VDocBean) _jspx_page_context.getAttribute("vdocdb", javax.servlet.jsp.PageContext.SESSION_SCOPE);
        if (vdocdb == null){
          vdocdb = new de.readysoft.vdoc.VDocBean();
          _jspx_page_context.setAttribute("vdocdb", vdocdb, javax.servlet.jsp.PageContext.SESSION_SCOPE);
          out.write(" \r\n");
          out.write("	");
          org.apache.jasper.runtime.JspRuntimeLibrary.introspecthelper(_jspx_page_context.findAttribute("vdocdb"), "properties", "dbprops.txt", null, null, false);
          out.write('\r');
          out.write('\n');
          out.write('	');

// 		vdocdb.connect();
		session.setMaxInactiveInterval(900);
	
          out.write('\r');
          out.write('\n');
        }
      }
      out.write('\r');
      out.write('\n');
      out.write('\r');
      out.write('\n');
 db = vdocdb; 
      out.write('\r');
      out.write('\n');
      out.write('\r');
      out.write('\n');
 synchronized(db){db.setDocsPfad(request.getRealPath("/"));} 
      out.write('\r');
      out.write('\n');
 String vdocURI = URLEncoder.encode(request.getRequestURI() + "?" + request.getQueryString()); 
      out.write('\r');
      out.write('\n');
 vdocdb.logInfo("Uri=" + request.getRequestURI() + "?" + request.getQueryString()); 
      out.write('\r');
      out.write('\n');
      out.write('\r');
      out.write('\n');
      out.write("\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write('\r');
      out.write('\n');

//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
String parentID = request.getParameter("id");
String userPKEY = (String) session.getAttribute("userpkey");
String userPfad = getUserAbts(userPKEY);
boolean canAdmin = isAdmin(userPKEY);
Hashtable roots;
Enumeration myEnum;
if (parentID == null) {
      out.write("     \r\n");
      out.write("<tree	\r\n");
      out.write("	bg_color = \"#FFFFFF\"\r\n");
      out.write("	ICONS_PERMANENT = \"1\"\r\n");
      out.write("	root_closeable = \"1\"\r\n");
      out.write("	crosses = \"1\"\r\n");
      out.write("	get_doc = \"vdocdata2.jsp\"\r\n");
      out.write("	eval = \"TreeSel\"  \r\n");
      out.write("	NODE_HEIGHT = \"16\"\r\n");
      out.write("	image0 = \"icons/drive.gif\"\r\n");
      out.write("	image1 = \"icons/file.gif\"\r\n");
      out.write("	image2 = \"icons/folder.gif\"\r\n");
      out.write("	image3 = \"icons/folder_o.gif\"\r\n");
      out.write("	>\r\n");
  roots	= db.VDocExpand("0","D");
		myEnum	= roots.elements();
		while (myEnum.hasMoreElements()) {
    	Hashtable ht = (Hashtable) myEnum.nextElement();
			String child = (Integer.parseInt((String)ht.get("SUBS")) != 0) ? "child='1'" : ""; // ist das ein Directory?
      out.write("\r\n");
      out.write("       <item id=\"");
      out.print(ht.get("PKEY"));
      out.write("\" text='");
      out.print(ht.get("DIR"));
      out.write(' ');
      out.print(ht.get("TEXT"));
      out.write("' action=\"1,'");
      out.print(ht.get("PKEY"));
      out.write("'\" IM0=\"0\" ");
      out.print(child);
      out.write("/>\r\n");
  } 
      out.write("\r\n");
      out.write("</tree>\r\n");
      out.write("<menu on_menu='onMenu'  on_menu_pre='loadMenu'>\r\n");
      out.write("	<menuitem name='Open item'/>\r\n");
      out.write("	<menuitem name='Close item'/>\r\n");
      out.write("</menu>\r\n");
 } else {
	// SubDirectory expandieren + sortieren
	roots = db.VDocExpand(parentID,"D");
	TreeSet sorter = new TreeSet(roots.keySet());
	for (Iterator it = sorter.iterator();it.hasNext();) {
		Hashtable ht = (Hashtable) roots.get((String) it.next());
	//	if (!canAdmin && !leseBerechtigung((String)ht.get("PKEY"),userPfad)) continue;
		String child = (Integer.parseInt((String)ht.get("SUBS")) != 0) ? "child='1'" : ""; // ist das ein Directory?
      out.write("\r\n");
      out.write("    <item id=\"");
      out.print(ht.get("PKEY"));
      out.write("\" text='");
      out.print(ht.get("DIR"));
      out.write(' ');
      out.print(ht.get("TEXT"));
      out.write("' action=\"1,'");
      out.print(ht.get("PKEY"));
      out.write("'\" IM0=\"3\" im1='2' ");
      out.print(child);
      out.write("/>\r\n");
}

}
      out.write('\r');
      out.write('\n');
 db.close(); 
      out.write('\r');
      out.write('\n');
      out.write('\r');
      out.write('\n');
    } catch (java.lang.Throwable t) {
      if (!(t instanceof javax.servlet.jsp.SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          try {
            if (response.isCommitted()) {
              out.flush();
            } else {
              out.clearBuffer();
            }
          } catch (java.io.IOException e) {}
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
        else throw new ServletException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
