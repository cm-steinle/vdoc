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
	get_doc = "userdata2.jsp"
	eval = "TreeSel"  
	NODE_HEIGHT = "16"
	image0 = "icons/drive.gif"
	image1 = "icons/file.gif"
	image2 = "icons/folder.gif"
	image3 = "icons/folder_o.gif"
	>
<%  roots	= db.UserExpand("0","A");
		myEnum	= roots.elements();
		while (myEnum.hasMoreElements()) {
    	Hashtable ht = (Hashtable) myEnum.nextElement();
			String child = (Integer.parseInt((String)ht.get("SUBS")) != 0) ? "child='1'" : ""; // ist das ein Directory?%>
       <item id="<%=ht.get("PKEY")%>" text='<%=ht.get("DIR")%> <%=ht.get("TEXT")%>' action="1,'<%=ht.get("PKEY")%>'" IM0="0" <%=child%>/>
<%  } %>
</tree>
<menu on_menu='onMenu'  on_menu_pre='loadMenu'>
	<menuitem name='Open item'/>
	<menuitem name='Close item'/>
</menu>
<% } else {
	// SubDirectory expandieren + sortieren
	roots = db.UserExpand(parentID,"A");
	TreeSet sorter = new TreeSet(roots.keySet());
	for (Iterator it = sorter.iterator();it.hasNext();) {
		Hashtable ht = (Hashtable) roots.get((String) it.next());
	//	if (!canAdmin && !leseBerechtigung((String)ht.get("PKEY"),userPfad)) continue;
		String child = (Integer.parseInt((String)ht.get("SUBS")) != 0) ? "child='1'" : ""; // ist das ein Directory?%>
    <item id="<%=ht.get("PKEY")%>" text='<%=ht.get("DIR")%> <%=ht.get("TEXT")%>' action="1,'<%=ht.get("PKEY")%>'" IM0="3" im1='2' <%=child%>/>
<%}

}%>
<%@include file="vdocbeanclose.jsp.inc"%>
