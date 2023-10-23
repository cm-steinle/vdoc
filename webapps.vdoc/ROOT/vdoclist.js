//------------------------------------------------------------------------------
//	Browsertyp feststellen
//------------------------------------------------------------------------------
userAgent = navigator.userAgent.toLowerCase();
n4 = document.layers;
ieWin = (document.all && userAgent.indexOf("mac")<0);
ieMac = (document.all && !ieWin && userAgent.indexOf("icab")<0);
w3c = document.documentElement;
aol = (userAgent.indexOf("aol")>-1);


var isNN4 = false;
var isIE4 = false;
var isNEW = false;
if (parseInt(navigator.appVersion) >= 5) {
	isNEW = true
	//alert("New Browser=" + navigator.appVersion);
} else if (parseInt(navigator.appVersion) >= 4) {
	if (navigator.appName.indexOf("Netscape") != -1) {
		isNN4 = true;
	//alert("Netscape=" + navigator.appVersion);
	}
	if (navigator.appName.indexOf("Microsoft") != -1) {
		isIE4 = true;
		//isNN4 = true;
		//alert("Microsoft=" + navigator.appVersion);
	}
}
//------------------------------------------------------------------------------
//	Maus-Position merken
//------------------------------------------------------------------------------
var new_x = 0;
var new_y = 0;
function mouseXY(e) {
	if (isNN4 || isNEW) {
		new_x = e.pageX;
		new_y = e.pageY;
	}
	if (isIE4) {
		new_x = window.event.x+document.body.scrollLeft;
		new_y = window.event.y+document.body.scrollTop;
	}
	setTimeout("drag_it()",0);
}
if (isNN4){
	document.captureEvents(Event.MOUSEMOVE);
}
document.onmousemove = mouseXY;
//------------------------------------------------------------------------------
//	popups positionieren
//------------------------------------------------------------------------------
function drag_it() {
	 window.status = "X=" + new_x + " y=" + new_y;
	 return;
//
	if (isNN4) {
		document.layers.xx.moveTo(new_x+10,new_y);
	}
	if (isIE4) {
		with (document.all.xx.style) {
			pixelLeft = new_x;
			pixelTop  = new_y;
		}
	}
	if (isNEW) {
		var element = document.getElementById('xx').style;
		element.left = new_x + 10;
		element.top  = new_y;
	}
//
}
var currentAdmin = top.currentAdmin;
var appletPopUp = null;
var currentPKEY = null;
var currentDIR = null;
var currentCanR = null;
var currentOwner = null;
var currentFreigeber = null;

function popshow(obj){
	if (obj != null) {appletPopUp = obj;}
	if (appletPopUp != null) {
		appletPopUp.popup();
		//appletPopUp = null;
	}
}
function pop(typ,pkey,dir,pcanr,powner, pfreigeber) {
	currentPKEY = pkey;
	currentDIR = dir;
	currentCanR = (pcanr != null) ? pcanr : 0;
	currentOwner = (powner != null) ? powner : 0;
	currentFreigeber = (pfreigeber != null) ? pfreigeber : 0;
    if (angular) return;
    
	var PopUpX = "PopUp" + typ
	var popX = "pop" + typ
	
	if (isNN4) {
		var obj = eval(("document.layers." + popX));
		obj.moveTo(1,1);
		appletPopUp = eval("document.PopUp" + typ);	
		setTimeout("popshow()",1);
	}
	if (isIE4) {
		var obj = eval("document.all." + popX);
		obj.style.left = new_x;
		obj.style.top  = new_y + 10;
		appletPopUp = eval("document.PopUp" + typ);
		setTimeout("popshow(appletPopUp)",1);
	}
	if (isNEW) {
		var obj = eval("document.getElementById('" + popX + "')");
		obj.style.left = new_x;
		obj.style.top  = new_y + 10;
		appletPopUp = eval("document.getElementById('PopUp" + typ + "')");		
		setTimeout("popshow()",1);
	}	
}
//------------------------------------------------------------------------------
//	In eine bestimmte Directory wechseln
//------------------------------------------------------------------------------
function showDir() {
	location.href="vdoclist.jsp?pkey=" + currentPKEY;
}
//------------------------------------------------------------------------------
//	Eine Directory zur Liste aufbereiten
//------------------------------------------------------------------------------
function listDir() {
	parent.data.location="vdocdrck.jsp?pkey=" + currentPKEY;
}
//------------------------------------------------------------------------------
//	Eine ListOptionen erfragen
//------------------------------------------------------------------------------
function listOpts() {
	parent.data.location="vdoclopt.jsp?pkey=" + currentPKEY;
}
//------------------------------------------------------------------------------
//	Ein neues Verzeichnis anlegen
//------------------------------------------------------------------------------
function crtDir() {
	if (isAdmin(true)) parent.data.location="vdocdata.jsp?submit=neues+Verzeichnis&pkey=" + currentPKEY + "&ckey=" + currentPKEY;
}
//------------------------------------------------------------------------------
//	Ein Verzeichnis aendern
//------------------------------------------------------------------------------
function chgDir() {
	if (isAdmin(true)) parent.data.location="vdocdata.jsp?submit=Bearbeiten&pkey=" + currentPKEY ;
}
//------------------------------------------------------------------------------
//	Ein Verzeichnis loeschen
//------------------------------------------------------------------------------
function delDir() {
	if (isAdmin(true) || isOwner())parent.data.location="vdocdata.jsp?submit=Loeschen&pkey=" + currentPKEY ;
}
//------------------------------------------------------------------------------
//	Verzeichnis Berechtigungen
//------------------------------------------------------------------------------
function authDir() {
	if (isAdmin() || isOwner()) parent.data.location="vdocauth.jsp?pkey=" + currentPKEY ;
}
//------------------------------------------------------------------------------
//	Einen neuen User anlegen
//------------------------------------------------------------------------------
function crtUser() {
	parent.data.location="vdocuuser.jsp?action=neuer+User";
}
//------------------------------------------------------------------------------
//	Einen User aendern
//------------------------------------------------------------------------------
function chgUser() {
	parent.data.location="vdocuuser.jsp?action=aendern&puser=" + currentPKEY;
}
//------------------------------------------------------------------------------
//	Einen User loeschen
//------------------------------------------------------------------------------
function delUser() {
	parent.data.location="vdocuuser.jsp?action=loeschen&puser=" + currentPKEY;
}
//------------------------------------------------------------------------------
//	Ein Dokument anzeigen
//------------------------------------------------------------------------------
function showDoc() {
	if (currentCanR != null && currentCanR == 1){
		parent.data.location="vdocactn.jsp?action=showdate&pkey=" + currentPKEY + "&redir="+currentDIR;
		// parent.data.location=currentDIR;
	} else {alert("Das Dokument ist noch nicht freigegeben oder\nSie haben keine ausreichende Leseberechtigung!");}
}
//------------------------------------------------------------------------------
//	Dokumentbeschreibung aendern
//------------------------------------------------------------------------------
function chgDoc() {
	if (isAdmin() || isOwner()) parent.data.location="vdocdata.jsp?submit=Bearbeiten&pkey=" + currentPKEY ;
}
//------------------------------------------------------------------------------
//	Wiedervorlage aendern
//------------------------------------------------------------------------------
function chgWvlg() {
	if (isAdmin() || isFreigeber() || isOwner()) parent.data.location="vdocdata.jsp?submit=Wiedervorlage&pkey=" + currentPKEY ;
}
//------------------------------------------------------------------------------
//	Ein Dokument zum bearbeiten abholen
//------------------------------------------------------------------------------
function getDoc() {
	//if (isOwner()) location.href="servlet/VDocDown?getfile=" + currentDIR ;
	//if (isOwner()) window.open(currentDIR,"");
	if (isOwner()) parent.data.location="vdocupdt.jsp?pkey=" + currentPKEY + "&action=get";
}
//------------------------------------------------------------------------------
//	Ein Dokument nach Bearbeitung zurueckschreiben
//------------------------------------------------------------------------------
function putDoc(ckey,pfad) {
	if (isOwner()) parent.data.location="vdocupdt.jsp?pkey=" + currentPKEY + "&ckey=" + ckey + "&at=" + pfad + "&action=put";
}
//------------------------------------------------------------------------------
//	Ein Dokument aus und einschecken
//------------------------------------------------------------------------------
function qikDoc(ckey,pfad) {
	if (isOwner()) parent.data.location="vdocupdt.jsp?pkey=" + currentPKEY + "&ckey=" + ckey + "&at=" + pfad + "&action=qik";
}
//------------------------------------------------------------------------------
//	Ein Dokument auf den Server stellen
//------------------------------------------------------------------------------
function crtDoc(ckey,pfad) {
	if ((currentCanR != null && currentCanR == 1) || isAdmin()){
		parent.data.location="vdocupld.jsp?pkey=" + currentPKEY + "&ckey=" + ckey + "&at=" + pfad + "&action=crt";
	} else {alert("Das Verzeichnis ist noch nicht freigegeben oder\nSie haben keine ausreichende Schreibberechtigung!");}
}
//------------------------------------------------------------------------------
//	Ein Dokument loeschen
//------------------------------------------------------------------------------
function delDoc() {
	if (isAdmin() || isOwner()) parent.data.location="vdocdata.jsp?submit=Loeschen&pkey=" + currentPKEY ;
}
//------------------------------------------------------------------------------
//	Dokument Berechtigungen
//------------------------------------------------------------------------------
function authDoc() {
	if (isAdmin() || isOwner()) parent.data.location="vdocauth.jsp?pkey=" + currentPKEY ;
}
//------------------------------------------------------------------------------
//	EigentuemerTest
//------------------------------------------------------------------------------
function isOwner() {
	if (currentOwner != null && currentOwner == 1){return true;}
	alert("Diese Funktion kann nur vom Eigentuemer genutzt werden!");
	return false;
}
//------------------------------------------------------------------------------
//	FreigeberTest
//------------------------------------------------------------------------------
function isFreigeber(info) {
	if (currentFreigeber != null && currentFreigeber == 1){return true;}
	if (info) alert("Diese Funktion kann nur vom Freigeber genutzt werden!");
	return false;
}

//------------------------------------------------------------------------------
//	AdminTest
//------------------------------------------------------------------------------
function isAdmin(info) {
	if (currentAdmin != null && currentAdmin == true){return true;}
	if (info) alert("Diese Funktion kann nur vom Administrator genutzt werden!");
	return false;
}
//------------------------------------------------------------------------------
//	Ein Dokument freigeben
//------------------------------------------------------------------------------
function freeDoc(pkey) {
	parent.data.location="vdocactn.jsp?action=frg&pkey=" + pkey ;
}
//------------------------------------------------------------------------------
//	VDirVVcrt einen VDir-Bereich hinzufuegen
//------------------------------------------------------------------------------
function VDirVVcrt(forw) {
	location.href="vdirverw.jsp?action=SVcrt&ckey=" + currentPKEY + "&svdir=" + "." + "&type=V&forw=" + forw ;
}
//------------------------------------------------------------------------------
//	VDirSVadd eine Server-Dir hinzufuegen
//------------------------------------------------------------------------------
function VDirSVadd(forw) {
	location.href="vdirverw.jsp?action=SVadd&ckey=" + currentPKEY + "&svdir=" + currentDIR + "&type=V&forw=" + forw ;
}
//------------------------------------------------------------------------------
//	VDirSWadd ein Server-Dokument hinzufuegen
//------------------------------------------------------------------------------
function VDirSWadd(forw) {
	location.href="vdirverw.jsp?action=SWadd&ckey=" + currentPKEY + "&svdir=" + currentDIR + "&type=W&forw=" + forw ;
}
//------------------------------------------------------------------------------
//	VDirSVadd eine Server-Dir hinzufuegen
//------------------------------------------------------------------------------
function VDirVVdel(forw) {
	location.href="vdirverw.jsp?action=VVdel&pkey=" + currentPKEY + "&forw=" + forw ;
}
//------------------------------------------------------------------------------
//	VDirSWadd ein Server-Dokument hinzufuegen
//------------------------------------------------------------------------------
function VDirVWdel(forw) {
	location.href="vdirverw.jsp?action=VWdel&pkey=" + currentPKEY + "&forw=" + forw ;
}
