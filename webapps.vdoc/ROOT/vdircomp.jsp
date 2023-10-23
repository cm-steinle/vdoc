<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocbean.jsp"%>
<%@include file="vdocbase.jsp"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.text.DateFormat"%>
<%!//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
//int abteilSpalten = 0;
//------------------------------------------------------------------------------
//	SubDirectory expandieren + sortieren
//------------------------------------------------------------------------------
private File[] listDirs(String parentID) {
	File subdir = new File(parentID); 
	File[] allfiles = subdir.listFiles(
		new FileFilter() {
			public boolean accept(File f) {
				return f.isDirectory() && !f.isHidden() && f.canRead();
			}
		}
	);
	return sortFiles(allfiles);
}
private File[] listFiles(String parentID) {
	File subdir = new File(parentID); 
	File[] allfiles = subdir.listFiles(
		new FileFilter() {
			public boolean accept(File f) {
				return !f.isHidden() && f.canRead();
			}
		}
	);
	return sortFiles(allfiles);
}
private File[] sortFiles(File[] allfiles) {
	if (allfiles == null) return allfiles;
	// SubDirectories sortieren
	Arrays.sort(allfiles, new Comparator() {
		public int compare(Object f1, Object f2) {
			return ((File) f1).compareTo((File) f2);
		}
		public boolean equals(Object f1, Object f2) {
			return ((File) f1).equals((File) f2);
		}
	});
	return allfiles;
}
//============================================================================%>
<%
//==============================================================================
//
//	A n w e i s u n g s F r a g m e n t e
//
//==============================================================================
TRACE = TRACE;
SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd HH:mm:ss");
Hashtable compFiles = new Hashtable();
Vector vdirs = new Vector(20);
//vdirs.addElement("DUMMY wegen Index 0");
String pkey = request.getParameter("pkey");
String serverPfad = "";
if (pkey != null) {
	try {
		serverPfad = db.VDirPfad(pkey);
	} catch (Exception e) {
		err(e.getMessage());
		err("Gestartet mit PKEY=" + pkey);
	}
}
File[] allfiles = null;
if (serverPfad != "") {
	allfiles = listFiles(serverPfad);
	if (allfiles != null) {
		for(int i = 0; i < allfiles.length; i++){
			int ct[] = new int[6];
			ct[0] = (allfiles[i].isDirectory()) ? 0 : 1; // ist das ein Directory?
			ct[1] = 0; // in Vdir
			ct[2] = 1; // auf Server
			ct[3] = 0; // kein pkey
			ct[4] = -1; // kein ckey
			ct[5] = i; // index von allfiles
			String key = (ct[0] == 0) ? "0" : "1";
			key += allfiles[i].getName();
			compFiles.put(key,ct);
		}
	}
	Hashtable roots;
	Enumeration enumm;
	roots = db.VDirExpand(pkey,"");
	if (roots.size() != 0) {
		enumm = roots.elements();
		TreeSet sorter = new TreeSet(roots.keySet());
		for (Iterator it = sorter.iterator();it.hasNext();) {
			Hashtable ht = (Hashtable) roots.get((String) it.next());
		//while (enumm.hasMoreElements()) {
	  //  Hashtable ht = (Hashtable) enumm.nextElement();
			int ct[] = new int[6]; 
			ct[0] = ht.get("TYPE").equals("V") ? 0 : 1; // ist das ein Directory?
			ct[1] = 1; // in VDir
			ct[2] = 0; // auf Server
			ct[3] = Integer.parseInt((String)ht.get("PKEY"));
			ct[4] = vdirs.size(); // index in VDirs
			ct[5] = -1; // index von allfiles
			vdirs.add(ht);
			String key = (ct[0] == 0) ? "0" : "1";
			key += ht.get("DIR");
			if (compFiles.containsKey(key)) {
				int cx[] = (int[]) compFiles.get(key);
				ct[1] += cx[1];
				ct[2] += cx[2];
				if (ct[1] > 1) {
					ct[3] = cx[3]; // den Anfangspkey  beibehalten
					ct[4] = cx[4]; // den Anfangsindex beibehalten
				}
				ct[5] = cx[5]; // den Anfangwert   beibehalten
			}
			compFiles.put(key,ct);
		}
	}
}
TreeSet sorter = new TreeSet(compFiles.keySet());
// TreeMap treemap = new TreeMap(compFiles);
// TreeSet sorted = new TreeSet(treemap.keySet());
// Iterator it = sorter.iterator();
String imgDir = "<img src='images/dir.gif' width='16' height='16' border='0' alt=''>";
String imgDoc = "<img src='images/file.gif' width='16' height='16' border='0' alt=''>";
//==============================================================================
//
//	H  T  M  L
//
//==============================================================================
%>
<html>
<head>
	<title>VDIR mit Server vergleichen</title>
	<meta http-equiv="Expires" content="-780">
	<link rel="stylesheet" href="vdoc.css">
	<script type="text/javascript" src="dhtml.js"></script>
	<script language="JavaScript" src="vdoclist.js" type="text/javascript"></script>
</head>
<BODY onload="currentAdmin=top.currentAdmin">
<%=err()%>
<table width="100%" border="0"><tr bgcolor="#C0C0C0"><td>Vergleich Inhalt von VDir mit Dateien auf Server</td></tr></table>
<table border="0" cellspacing="2" cellpadding="0">   
	<tr class="blue">
		<td colspan="3">in VDir <%= serverPfad %></td><td>vom</td><td width="3" rowspan="9999" bgcolor="#C0C0C0"><img src="images/trans.gif" width="1" height="1" border="0" alt=""></td><td colspan="2">auf Server <%= serverPfad %></td><td>ge&auml;ndert am</td>
	</tr>
<%for (Iterator it = sorter.iterator();it.hasNext();) {
		String key = (String) it.next();
		String key0,key1,key2;
		String pic1, pic2;
		String text1 = "&nbsp;";
		String date1 = "&nbsp;";
		String date2 = "&nbsp;";
		String href1 = null;
		String href2 = null;
		String pkey1 = null;
		key0 = key.substring(1); // das Sortkennzeichnen wieder wegnehmen
		int ct[] = (int[]) compFiles.get(key);
		key1 = key2 = "&nbsp;";
		pic1 = pic2 = "&nbsp;";
		if (ct[1] != 0) { // VDir Anzahl
			key1 = key0;
			pic1 = (ct[0] == 0) ? imgDir : imgDoc;
			if (ct[4] != ct[4]) {
				pkey1 = Integer.toString(ct[3]);
				text1 = db.getWERT(Integer.toString(ct[3]),"TEXT");
			} else {
				try {
				 Hashtable ht = (Hashtable) vdirs.get(ct[4]);
				 pkey1 = (String) ht.get("PKEY");
				 text1 = (String) ht.get("TEXT");
				 date1 = sdf.format((Timestamp) ht.get("CRTDATE"));
				} catch (Exception e) {
					pkey1 = Integer.toString(ct[4]);
					text1 = e.getMessage() + " + vdirs.size=" + vdirs.size();
				}
			}
			href1 = "javascript:pop('V" + ((ct[0] == 0) ? "V"    : "W") + "'," + pkey1 + ",'" + key1 + "')"; // V=Dir, W=Doc
		}
		if (ct[2] != 0) { // Server Anzahl
			key2 = key0;
			pic2 = (ct[0] == 0) ? imgDir : imgDoc;
			if (ct[5] >= 0) {date2 = sdf.format(new java.util.Date(allfiles[ct[5]].lastModified()));}
			if (ct[0] == 0 || ct[1] == 0) { // Dircetories duerfen mehrfach in VDir aufgenommen werden
				href2 = "javascript:pop('S" + ((ct[0] == 0) ? "V"    : "W") + "'," + pkey + ",'" + key2 + "')"; // V=Dir, W=Doc
			} 
		}	
		if (ct[1] <= 1){%>
		<tr bgcolor="#EEEEEE">
			<td><% if (href1 != null){ %><a href="<%= href1 %>"><%= pic1 %></a><% }else{ %><%= pic1 %><% } %></td><td><%= key1 %></td><td><%= text1 %></td><td nowrap><%= date1 %></td>
			<td><% if (href2 != null){ %><a href="<%= href2 %>"><%= pic2 %></a><% }else{ %><%= pic2 %><% } %></td><td><%= key2 %></td><td nowrap><%= date2 %></td>
		</tr>
 <% } else { // VDir wurde einer Server-Directory mehrfach zugeordnet %>
 <% if (TRACE) { %>
 <tr>
 <td>vdirs.size</td><td><%= vdirs.size() %></td><td>&nbsp;</td>
 <td>ct[1]=<%= ct[1] %></td><td>ct[4]=<%= ct[4] %></td><td>&nbsp;</td>
 </tr>
 <% } %>
		<%for (int i=0; i<ct[1];i++){
			try {
				Hashtable ht = (Hashtable) vdirs.get(ct[4]+i);
				text1 = (String) ht.get("TEXT");
				pkey1 = (String) ht.get("PKEY");
				date1 = sdf.format((Timestamp) ht.get("CRTDATE"));
				href1 = "javascript:pop('V" + ((ct[0] == 0) ? "V"    : "W") + "'," + pkey1 + ",'" + key1 + "')"; // V=Dir, W=Doc
			} catch (Exception e) {
				pkey1 = "-1"; // Integer.toString(ct[4]);
				text1 = "Fehler: " + e.getMessage(); // + " + vdirs.size=" + vdirs.size() + " Element=" + Integer.toString(ct[4]+i);
				href1 = null;
			}
		%>
		<tr bgcolor="#DDDDDD">
			<td><% if (href1 != null){ %><a href="<%= href1 %>"><%= pic1 %></a><% }else{ %><%= pic1 %><% } %></td><td><%= key1 %></td><td><%= text1 %></td><td nowrap><%= date1 %></td>
			<% if (i==0){%>
			<td rowspan="<%= ct[1] %>"><% if (href2 != null){ %><a href="<%= href2 %>"><%= pic2 %></a><% }else{ %><%= pic2 %><% } %></td><td rowspan="<%= ct[1] %>"><%= key2 %></td><td nowrap rowspan="<%= ct[1] %>"><%= date2 %></td>
			<% }%>
		</tr>
		<%}
	}
} %>
</table>
<div id="popSV" style="position: absolute;"><!-- Server Verzeichnis -->
<APPLET MAYSCRIPT
	CODE			=	"PopupMenuApplet.class"
	CODEBASE	=	"."
	ID    		=	"PopUpSV"
	WIDTH			= "0"
	HEIGHT		= "0"
>
<PARAM NAME="BGCOLOR"	VALUE="lightgray">
<PARAM NAME="TEXT"		VALUE="blue">
<PARAM NAME="DATA"		VALUE="
{in VDir aufnehmen*script=VDirSVadd('<%= vdocURI %>')}
">
</APPLET></div>
<div id="popSW" style="position: absolute;"><!-- Server Dokument -->
<APPLET MAYSCRIPT
	CODE			=	"PopupMenuApplet.class"
	CODEBASE	=	"."
	ID  			=	"PopUpSW"
	WIDTH			= "0"
	HEIGHT		= "0"
>
<PARAM NAME="BGCOLOR"	VALUE="lightgray">
<PARAM NAME="TEXT"		VALUE="blue">
<PARAM NAME="DATA"		VALUE="
{in VDir aufnehmen*script=VDirSWadd('<%= vdocURI %>')}
">
</APPLET></div>
<div id="popVV" style="position: absolute;"><!-- VDir Verzeichnis -->
<APPLET MAYSCRIPT
	CODE			=	"PopupMenuApplet.class"
	CODEBASE	=	"."
	ID  			=	"PopUpVV"
	WIDTH			= "0"
	HEIGHT		= "0"
>
<PARAM NAME="BGCOLOR"	VALUE="lightgray">
<PARAM NAME="TEXT"		VALUE="blue">
<PARAM NAME="DATA"		VALUE="
{aus VDir l&ouml;schen*script=VDirVVdel('<%= vdocURI %>')}
">
</APPLET></div>
<div id="popVW" style="position: absolute;"><!-- VDir Dokument -->
<APPLET MAYSCRIPT
	CODE			=	"PopupMenuApplet.class"
	CODEBASE	=	"."
	ID        = "PopUpVW"
	WIDTH			= "0"
	HEIGHT		= "0"
>
<PARAM NAME="BGCOLOR"	VALUE="lightgray">
<PARAM NAME="TEXT"		VALUE="blue">
<PARAM NAME="DATA"		VALUE="
{aus VDir l&ouml;schen*script=VDirVWdel('<%= vdocURI %>')}
">
</APPLET></div>
</BODY>
</html> 
<%@include file="vdocbeanclose.jsp.inc"%>