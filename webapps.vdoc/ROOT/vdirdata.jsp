<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%@include file="vdocbean.jsp"%>
<%@include file="vdocbase.jsp"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%!//===========================================================================
//
//	V e r e i n b a r u n g e n
//
//==============================================================================
//int abteilSpalten = 0;
//------------------------------------------------------------------------------
//	SubDirectory expandieren + sortieren
//------------------------------------------------------------------------------
private File[] listFiles(String parentID) {
	File subdir = new File(parentID); 
	File[] allfiles = subdir.listFiles(
		new FileFilter() {
			public boolean accept(File f) {
				return f.isDirectory() && !f.isHidden() && f.canRead();
			}
		}
	);
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
String parentID = request.getParameter("id");
String userPKEY = (String) session.getAttribute("userpkey");
String userPfad = getUserAbts(userPKEY);
boolean canAdmin = isAdmin(userPKEY);
Hashtable roots;
Enumeration myEnum;
if (parentID == null) {%>     
<tree	
	bg_color = "#FFFFFF"
	ICONS_PERMANENT = "1"
	root_closeable = "1"
	crosses = "1"
	get_doc = "vdirdata.jsp"
	eval = "TreeSel"  
	NODE_HEIGHT = "16"
	image0 = "icons/drive.gif"
	image1 = "icons/file.gif"
	image2 = "icons/folder.gif"
	image3 = "icons/folder_o.gif"
	>
<%  roots	= db.VDirExpand("0","V");
		myEnum	= roots.elements();
		while (myEnum.hasMoreElements()) {
    	Hashtable ht = (Hashtable) myEnum.nextElement();
			String child = (Integer.parseInt((String)ht.get("SUBS")) != 0) ? "child='1'" : ""; // ist das ein Directory?%>
       <item id="<%=ht.get("PKEY")%>" text='<%=ht.get("TEXT")%>' action="1,'<%=ht.get("PKEY")%>'" IM0="0" <%=child%>/>
<%  } %>
</tree>
<menu on_menu='onMenu'  on_menu_pre='loadMenu'>
	<menuitem name='Open item'/>
	<menuitem name='Close item'/>
	<separator/>
	<menuitem name='Delete item'/>
</menu>
<% } else {
	// SubDirectory expandieren + sortieren
	roots = db.VDirExpand(parentID,"V");
	TreeSet sorter = new TreeSet(roots.keySet());
	for (Iterator it = sorter.iterator();it.hasNext();) {
		Hashtable ht = (Hashtable) roots.get((String) it.next());
		if (!canAdmin && !leseBerechtigung((String)ht.get("PKEY"),userPfad)) continue;
		String child = (Integer.parseInt((String)ht.get("SUBS")) != 0) ? "child='1'" : ""; // ist das ein Directory?%>
    <item id="<%=ht.get("PKEY")%>" text='<%=ht.get("TEXT")%>' action="1,'<%=ht.get("PKEY")%>'" IM0="3" im1='2' <%=child%>/>
<%}

}%>
<%@include file="vdocbeanclose.jsp.inc"%>