/* DHTML-Bibliothek */

var DHTML = 0, DOM = 0, MS = 0, NS = 0, OP = 0;

function DHTML_init() {

 if (window.opera) {
     OP = 1;
 }
 if(document.getElementById) {
   DHTML = 1;
   DOM = 1;
 }
 if(document.all && !OP) {
   DHTML = 1;
   MS = 1;
 }
if (window.netscape && window.screen && !DOM && !OP){
   DHTML = 1;
   NS = 1;
 }
}

function getElem(p1,p2,p3) {
 var Elem;
 if(DOM) {
   if(p1.toLowerCase()=="id") {
     if (typeof document.getElementById(p2) == "object")
     Elem = document.getElementById(p2);
     else Elem = void(0);
     return(Elem);
   }
   else if(p1.toLowerCase()=="name") {
     if (typeof document.getElementsByName(p2) == "object")
     Elem = document.getElementsByName(p2)[p3];
     else Elem = void(0);
     return(Elem);
   }
   else if(p1.toLowerCase()=="tagname") {
     if (typeof document.getElementsByTagName(p2) == "object" 
     || (OP && typeof document.getElementsByTagName(p2) == "function")){
        if (p3 != null) Elem = document.getElementsByTagName(p2)[p3];
		  else Elem = document.getElementsByTagName(p2);
	  }
     else Elem = void(0);
     return(Elem);
   }
   else return void(0);
 }
 else if(MS) {
   if(p1.toLowerCase()=="id") {
     if (typeof document.all[p2] == "object")
     Elem = document.all[p2];
     else Elem = void(0);
     return(Elem);
   }
   else if(p1.toLowerCase()=="tagname") {
     if (typeof document.all.tags(p2) == "object"){
        if (p3 != null) Elem = document.all.tags(p2)[p3];
		  else            Elem = document.all.tags(p2);
	  }
     else Elem = void(0);
     return(Elem);
   }
   else if(p1.toLowerCase()=="name") {
     if (typeof document[p2] == "object")
     Elem = document[p2];
     else Elem = void(0);
     return(Elem);
   }
   else return void(0);
 }
 else if(NS) {
   if(p1.toLowerCase()=="id" || p1.toLowerCase()=="name") {
   if (typeof document[p2] == "object")
     Elem = document[p2];
     else Elem = void(0);
     return(Elem);
   }
   else if(p1.toLowerCase()=="index") {
    if (typeof document.layers[p2] == "object")
     Elem = document.layers[p2];
    else Elem = void(0);
     return(Elem);
   }
   else return void(0);
 }
}

function getCont(p1,p2,p3) {
   var Cont;
   if(DOM && getElem(p1,p2,p3) && getElem(p1,p2,p3).firstChild) {
     if(getElem(p1,p2,p3).firstChild.nodeType == 3)
       Cont = getElem(p1,p2,p3).firstChild.nodeValue;
     else
       Cont = "";
     return(Cont);
   }
   else if(MS && getElem(p1,p2,p3)) {
     Cont = getElem(p1,p2,p3).innerText;
     return(Cont);
   }
   else return void(0);
}

function getAttr(p1,p2,p3,p4) {
   var Attr;
   if((DOM || MS) && getElem(p1,p2,p3)) {
     Attr = getElem(p1,p2,p3).getAttribute(p4);
     return(Attr);
   }
   else if (NS && getElem(p1,p2)) {
       if (typeof getElem(p1,p2)[p3] == "object")
        Attr=getElem(p1,p2)[p3][p4]
       else
        Attr=getElem(p1,p2)[p4]
         return Attr;
       }
   else return void(0);
}

function setCont(p1,p2,p3,p4) {
   if(DOM && getElem(p1,p2,p3) && getElem(p1,p2,p3).firstChild)
     getElem(p1,p2,p3).firstChild.nodeValue = p4;
   else if(MS && getElem(p1,p2,p3))
     getElem(p1,p2,p3).innerText = p4;
   else if(NS && getElem(p1,p2,p3)) {
     getElem(p1,p2,p3).document.open();
     getElem(p1,p2,p3).document.write(p4);
     getElem(p1,p2,p3).document.close();
   }
}
// 1. Funktion fuer den Zugriff aufs Dokument
function DivObjDocument(div_id) 
{
    if (!div_id || div_id.length==0) {
       div_obj = document;
    }
    else {
       if (document.getElementById) {
          div_obj = document; // W3C
       }   
       else if (document.layers) {
          div_obj = eval("document."+div_id+".document");
       }
       else if (document.all) {
          div_obj = eval("document.all."+div_id+".document");
       }   
    }   
    return div_obj;
}     

// 2. Funktion fuer den Zugriff aufs Style Sheet
function DivObjStyle(div_id)
{
    if (!div_id || div_id.length==0)
    {
       if (document.getElementById) {
           div_obj = document.style;
       }    
       else if (document.layers) {
           div_obj = document;
       }
       else if (document.all) {
           div_obj = document.all.style;
       }
    }
    else {   
       if (document.getElementById) {
          div_obj = document.getElementById(div_id).style;
       }    
       else if (document.layers) {
          div_obj = eval("document."+div_id);
       }
       else if (document.all) {
          div_obj = eval("document.all."+div_id+".style");
       }
    }   
    return div_obj;
}
DHTML_init();
