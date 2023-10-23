<%@ page contentType="text/html; charset=ISO-8859-1"%>
<%!//===========================================================================
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
//============================================================================%>