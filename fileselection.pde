void fileSelects(File selection) {
  if (selection == null) {
    //println("Window was closed or the user hit cancel.");
  } else {
    Savefile = selection.getAbsolutePath();
    draw();
  }
}

 void fileSelected(File selection) {
  if (selection == null) {
    //println("Window was closed or the user hit cancel.");
  } else {
    filewritten = 0;
    modifyclick = 0;
    Savefile = "";
    Originalfile = selection.getAbsolutePath(); 
    draw();
  }
 }

void filefinder(File selection) {
  if (selection == null) {
    //println("Window was closed or the user hit cancel.");
  } else {
    PrintWriter cnchost;
    cnchost = createWriter("data/cnchost.dat");
    cnchost.println(selection.getAbsolutePath());
    cnchost.flush();
    cnchost.close();
    cnchost=null;
    Open_CNCUSBcontroller_App(1);
  }
} 
 
 
boolean doesFileExist(String filePath) {
  return new File(dataPath(filePath)).exists();
}
