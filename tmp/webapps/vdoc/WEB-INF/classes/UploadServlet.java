//package yoonforh.upload;

/**
 * UploadServlet.java
 * Copyright (c) 1998 Yoon Kyung Koo. All rights reserved.
 *
 * contact via yoonforh@moon.daewoo.co.kr
 *
 * HISTORY
 *  first release ver 1.0 1998/07/14
 *    first working version
 *  revision 1.0a 1998/11/06
 *       change Vector with Hashtable to enhance performance
 *  revision 1.0z 1999/03/06
 *    add work around of a bug
 *       in JSDK 2.0's javax.servlet.ServletInputStream.readLine() method
 *
 * NOTE
 *    if you want to get info. about Upload CGI standard, refer to RFC 1867
 *
 * @version 1.0z 1999/03/06
 * @author Yoon Kyung Koo
 */


import java.io.*;
import java.util.*;
import java.net.*;

import javax.servlet.*;
import javax.servlet.http.*;

// import sun.security.x509.*;

/**
 * UploadServlet class
 */
public class UploadServlet extends HttpServlet {
   // absolute path where file uploaded
   // NOTE:do not use '\', always use '/' as directory discriminator
   //final static String fileLocation="../../docs";
	 String fileLocation;
	 final static String DIRECTORY = ":Directory";
	 final static String ACTION = ":action";
   final static boolean DEBUG=false;
   final static boolean LOGGING=false;
   Hashtable table=new Hashtable();
   PrintWriter log = null;

   protected void finalize() throws Throwable {
      closeLog();
   }

    public void doPost (HttpServletRequest req, HttpServletResponse res)
   throws ServletException, IOException
    {
      ServletOutputStream out = res.getOutputStream();
      log = openLog("/tmp/upload.log");
			fileLocation = req.getRealPath("docs");
			
      res.setContentType("text/html");
        int contentLength=req.getContentLength();

      // RFC 1867
      String contentType = req.getContentType();
      int ind = contentType.indexOf("boundary=");
      if (ind == -1) {
         out.println("IND is less than 0");
         writeLog("IND is less than 0");
         return;
      }
      String boundary = contentType.substring(ind+9);

      if (boundary == null) {
         out.println("boundary is null");
         writeLog("boundary is null");
         return;
      }

      String boundaryString = "--"+boundary;

      ServletInputStream in = req.getInputStream();

      byte[] buffer = new byte[1024];

      table.clear();

      int result=readLine(in, buffer, 0, buffer.length);

outer:   while (true) {

         if (result<=0) {
            out.println("Error. Stream truncated");
            writeLog("Error. Stream truncated");
            break;
         }

         String line = new String(buffer, 0, result);

         if (!line.startsWith(boundaryString)) {
            out.println("Error. MIME boundary missing.");
            writeLog("Error. MIME boundary missing.");
            break;
         }

         result=readLine(in, buffer, 0, buffer.length);
         if (result<=0) {
            if (DEBUG)
               out.println("Error. boundary but without contents");
            break;
         }

         line = new String(buffer, 0, result);
         StringTokenizer tokenizer=new StringTokenizer(line, ";\r\n");
         String token=tokenizer.nextToken();
         String upperToken = token.toUpperCase();
         if (!upperToken.startsWith("CONTENT-DISPOSITION")) {
            out.println("Format error. Content-Disposition expected.");
            writeLog("Format error. Content-Disposition expected.");
            break;
         }
         String disposition = upperToken.substring(21);
         if (!disposition.equals("FORM-DATA")) {
            out.println("I don't know how to handle ["+disposition+"] disposition.");
            writeLog("I don't know how to handle ["+disposition+"] disposition.");
            break;
         }
         if (tokenizer.hasMoreElements())
            token=tokenizer.nextToken();
         else {
            out.println("Format error. NAME expected.");
            writeLog("Format error. NAME expected.");
            break;
         }
         int nameStart=token.indexOf("name=\"");
         int nameEnd=token.indexOf("\"", nameStart+7);
         if (nameStart<0 || nameEnd<0) {
            out.println("Format error. NAME expected.");
            writeLog("Format error. NAME expected.");
            break;
         }
         String name=token.substring(nameStart+6, nameEnd);
         if (tokenizer.hasMoreElements()) {
            token=tokenizer.nextToken();
            int tokenStart=token.indexOf("filename=\"");
            int tokenEnd=token.indexOf("\"", tokenStart+11);
            if (tokenStart<0 || tokenEnd<0) {
               out.println("Format error. FILENAME expected.");
               writeLog("Format error. FILENAME expected.");
               break;
            }
            String filename=token.substring(tokenStart+10, tokenEnd);
            int lastindex=-1;
            if ((lastindex=filename.lastIndexOf('/'))<0)
               lastindex=filename.lastIndexOf('\\');
            if (lastindex>=0)
               filename=filename.substring(lastindex+1);
            FileOutputStream f_out;
            String directory=getValue(DIRECTORY);
						String pfad;
						try {
							if (directory==null) {
								pfad = fileLocation + File.separatorChar;
							} else {
								pfad = fileLocation + File.separatorChar + directory + File.separatorChar;
							}
							appendValue(":fileLocation",fileLocation,false);
							appendValue(":pfad", pfad, false);
							File filePfad = new File(pfad);
							File file 		= new File(pfad + filename);
							if (!file.exists()) {
								if (getValue(ACTION).equals("crt")){
									if (!filePfad.exists()) {	// gibt es die Directory?
										if (!filePfad.mkdirs()) {
											out.println("Pfad nicht angelegt: " + pfad);
											break;
										}
									}
								} else {
									out.println("Aktion=crt wurde erwartet");
									break;	// kein action=crt
								}
							} else if (!getValue(ACTION).equals("upd")){
									out.println("Aktion=upd wurde erwartet");
									break;	// kein action=crt
							}
							f_out=new FileOutputStream(pfad + filename);
						} catch (Exception e) {
							if (directory==null)
							out.println("Cannot open file "+fileLocation+'/'+filename);
							else
							out.println("Cannot open file "+fileLocation+'/'+directory+'/'+filename);
							writeLog("exception:"+e.toString());
							break;
						}

            appendValue(name, filename, true);
            result=readLine(in, buffer, 0, buffer.length);
            if (result<=0) {
               out.println("Error. Stream truncated 1");
               writeLog("Error. Stream truncated 1");
               break;
            }
            int size=0;
            try {
               byte[] tmpbuffer=new byte[buffer.length];
               int tmpbufferlen=0;
               boolean isFirst=true;
inner:            while ( (result=readLine(in, buffer, 0, buffer.length))>0) {
                  if (isFirst) { // ignore all proceeding \r\n
                     if (result==2 && buffer[0]=='\r' && buffer[1]== '\n')
                        continue;
                  }
                  String tmp=new String(buffer, 0, result);
                  if (DEBUG)
                     out.println("read result:"+result+"("+tmp+")<BR>");
                  if (tmp.startsWith(boundaryString)) {
                     if (DEBUG)
                        out.println("substract 2");
                     writeLog("substract 2");
                     if (!isFirst) {
                        size+=tmpbufferlen-2;
                        f_out.write(tmpbuffer, 0, tmpbufferlen-2);
                     }
                     continue outer;
                  }
                  else {
                     if (!isFirst) {
                        size+=tmpbufferlen;
                        f_out.write(tmpbuffer, 0, tmpbufferlen);
                     }
                  }
                  writeLog("before arraycopy, size="+size+",result="+result+",buffer length="+buffer.length);
                  System.arraycopy(buffer, 0, tmpbuffer, 0, result);
                  writeLog("after arraycopy, size="+size+",result="+result+",buffer length="+buffer.length);
                  tmpbufferlen=result;
                  isFirst=false;
               }
            } catch (IOException ie) {
               if (log != null)
                  ie.printStackTrace(log);
               out.println("IO Error while write to file:"+ie.toString());
               writeLog("IO Error while write to file:"+ie.toString());
            } catch (Exception e) {
               if (log != null)
                  e.printStackTrace(log);
               out.println("Error while write to file:"+e.toString());
               writeLog("Error while write to file:"+e.toString());
            } finally {
               if (DEBUG)
                  out.println("size:"+size);
               f_out.close();
            }
            result=readLine(in, buffer, 0, buffer.length);
         }
         else { // no more elements
            result=readLine(in, buffer, 0, buffer.length);
            if (result<=0) {
               out.println("Error. Stream truncated 2");
               writeLog("Error. Stream truncated 2");
               break;
            }
            result=readLine(in, buffer, 0, buffer.length);
            if (result<=0) {
               out.println("Error. Stream truncated 3");
               writeLog("Error. Stream truncated 3");
               break;
            }
            String value = new String(buffer, 0, result-2); // exclude \r\n
            appendValue(name, value, false);
         }
         result=readLine(in, buffer, 0, buffer.length);
      } // end of while
     	printResult(out);
      table.clear();
    }

    void appendValue(String name, String value, boolean isFile) {
      UploadData data=new UploadData(name, value, isFile);
      table.put(name, data);
    }
    String getValue(String name) {
      UploadData data=(UploadData) table.get(name);
      if (data==null)
         return null;
      return data.value;
    }
    void printResult(ServletOutputStream out) throws IOException {
      /*
       * Hashtable : elements() returns values' Enum,
       *       and keys() returns keys' Enum.
       */
			boolean fileUploaded = false;
			Enumeration parms=table.elements();
			while (parms.hasMoreElements()) {
				UploadData value = (UploadData) parms.nextElement();
				if (value.isFile) {fileUploaded = true;}
			}
			//------------------------------------------------------------------------
			//	Antwort umleiten wenn :respto gesetzt ist
			//------------------------------------------------------------------------
			String respto=getValue(":respto");
			if (fileUploaded && respto != null) {
  	    out.println("<HTML><HEAD>");
      	out.println("<TITLE>VDoc Upload Result</TITLE>");
				out.print("<meta http-equiv='Refresh' content='0; URL=" + respto);
				String und = (respto.lastIndexOf('?') < 0) ? "?" : "&";
				parms=table.elements();
				while (parms.hasMoreElements()) {
					UploadData value = (UploadData) parms.nextElement();
					if (!value.name.startsWith(":")) {
						out.print(und + value.name + "=" + URLEncoder.encode(value.value));
						und = "&";
					}
				}
				out.println("'>");
				out.println("</HEAD><BODY bgcolor='#FFFFFF'><H1>Upload beendet</H1></BODY></HTML>");
			} else {
			//------------------------------------------------------------------------
			//	Antwort selbst erstellen
			//------------------------------------------------------------------------
	      Enumeration enum=table.elements();
	      out.println("<HTML><HEAD>");
	      out.println("<TITLE>VDoc Upload Result</TITLE>");
	      out.println("</HEAD><BODY bgcolor='#FFFFFF'>");
	      out.println("<H1>Upload Result</H1>");
	      out.println("<TABLE>");
	      out.println("<TR><TH>NAME</TH><TH>VALUE</TH><TH>FILE</TH></TR>");
	      while (enum.hasMoreElements()) {
	         UploadData data = (UploadData) enum.nextElement();
	         out.println("<TR>");
	         out.println("<TD>"+data.name+"</TD>");
	         out.println("<TD>"+data.value+"</TD>");
	         out.println("<TD>"+(data.isFile?"file":"")+"</TD>");
	         out.println("</TR>");
	      }
	      out.println("</TABLE>");
	      out.println("<HR><A HREF=\"/docs\">Uploaded file lists</A>");
	      out.println("<HR><A HREF=\"/\" TARGET=\"_top\">Home</A>");
	      out.println("</BODY></HTML>");
			}
    }
    public String getServletInfo() {
      return "A servlet that uploads a file";
    }

   private PrintWriter openLog(String filename) {
      if (!LOGGING)
         return null;
      try {
         return new PrintWriter(
            new BufferedWriter(new FileWriter(filename)));
      }
      catch (IOException ie) {
         System.err.println("Error:"+ie.toString());
         return null;
      }
      catch (Exception e) {
         System.err.println("Error:"+e.toString());
         return null;
      }
   }

   private void writeLog(String string) {
      if (log ==null)
         return;
      // writing operation
      log.println(string);
      // print() method never throws IOException,
      // so we should check error while printing
      if (log.checkError()) {
         System.err.println("File write error.");
      }
   }

   private void closeLog() {
      if (log !=null)
         log.close();
   }

    /**
    * to fix JSDK 2.0's bug
     */
    int readLine(ServletInputStream in, byte[] b, int off, int len)
      throws IOException {
      if (len <= 0) {
          return 0;
      }
      int count = 0, c;
      while ((c = in.read()) != -1) {
          b[off++] = (byte)c;
          count++;
          if ((c == '\n') || (count==len)) {
            break;
          }
      }
      return count > 0 ? count : -1;
    }
}

class UploadData {
   String name;
   String value;
   boolean isFile;

   UploadData(String name, String value, boolean isFile) {
      this.name=name;
      this.value=value;
      this.isFile=isFile;
   }
}
