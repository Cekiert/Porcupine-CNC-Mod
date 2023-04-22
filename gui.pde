void checkBox(float[] a) {
  if(requestmql == 0){
    requestmql = 1;
  }else {
    requestmql = 0;
  }
  draw();
}

void nline(float[] a) {
  if(uselinenum == 0){
    uselinenum = 1;
  }else {
    uselinenum = 0;
  }
  draw();
}

public void Load_File(int theValue) {
  if(buttonaenable == 1){
    //println(buttonaenable);
    selectInput("Select a file to process:", "fileSelected");
  }
  if(buttonaenable == 0){
    buttonaenable = 1;
    //println("debouce");
  }
}

public void Open_CNCUSBcontroller_App(int theValue){
      if(buttondenable == 1){
        //println(buttondenable);
        if (Savefile.equals("") == true){
        }else{
          boolean fileExists = doesFileExist("cnchost.dat");
          if (!fileExists) {
            //println("file doesmt exist");
            selectInput("Find CNCUSBController.exe:", "filefinder");
          } else {
            String[] loca = loadStrings(dataPath("") + "/cnchost.dat");
            String planetcncloc = loca[0];
            PrintWriter batfile;
            batfile = createWriter("data/launch.bat");
            batfile.println("\"" + planetcncloc + "\" \"" + Savefile + "\"");
            batfile.flush();
            batfile.close();
            batfile=null;
            launch("\""+ dataPath("") +"/launch.bat\"");
          }
        }
      }
      if(buttondenable == 0){
        buttondenable = 1;
        //println("debouce");
      }
}

public void Save_File(int theValue) {
    if(buttonbenable == 1){
      //println(buttonbenable);
      selectInput("Save AS:", "fileSelects");
    }
    if(buttonbenable == 0){
      buttonbenable = 1;
      //println("debouce");
    }
}

public void Modify_File(int theValue) {
    if(buttoncenable == 1){
    //println(buttoncenable);
      if (Originalfile.equals("") == false && Savefile.equals("") == false ){
        //println("file locations detected");
        modifyclick = 1;
        draw();
        modify();
      } else {
        //println("files not selected");
      }
    }
    if(buttoncenable == 0){
      buttoncenable = 1;
      //println("debouce");
    }
}
