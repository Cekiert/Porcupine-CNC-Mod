//Porcupine CNC Mod v1
//
//Disclaimer: Use at your own risk, I am
//not responsible for any damage, pain, or
//injury caused by using this. before attempting
//please consider if you have the skill set to
//safely work with electricity. Incase that
//warning is ignored make 100% sure the cnc box
//is unplugged prior to modifying the hardware
//even so be careful near capacitors, as they
//could still carry a very strong charge.
//Also never unplug energized stepper motors, as
//you can fry your stepper motor drivers. there
//is always the chance this code might not function
//or a bad electrical connection causing broken endmills.
//keep this in mind, use at your own risk
//
// This software's purpose is to add 
//functionality to CNC machines with a 
//JP-382c main board. Due to manufacturing 
//patterns in China this could compromise of
//several brands of CNC machines. to 
//complicate matters JP-382c boards are not 
//all the same.
//This hardware and software solution is
//tested and used on a China zone CNC 4 axis. The
//control box is labeled as 3 axis td. it also a
//tool height probe. You can check compatibility by
//testing to see if you detect output from the jp-382
//board's lpt port while connected via USB. As the 
//software outputs #2, and #3 in "CNC USB Controller"
//are changed on and off, you will find ground at lpt
//pin 24 and 12vdc signal at pin 16 and pin 1
//
//generated code from this software is being 
//sent to the cnc machine via planet cnc's USB 
//CNC controller software. This might work
//with additional host software options but currently 
//remains untested.
//
//A bit of background on these machines, they shipped with
//questionable software/licenses. Mach3 and Planet CNC's
//USB CNC Controller. In the case of Planet CNC's it appears
//China Zone CNC used the code from Planet CNC's DIY Board
//and Planet CNC being upset that a commerical product was
//cutting in on his product, that and possibly with a hacked
//license. I choose to buy a license from Planet CNC, but as
//a warning they say the unoffical boards will reset. Its been
//2 years, it hasnt reset on me. but I went through a few extra
//steps. edit your host file setting planet-cnc.com as 127.0.0.1
//install a software firewall, windows users "zone alarm" works
//great. Dont let USB CNC Controller access to the internet via
//zone alarm. Most importantly buy a software license and help
//support the developer. I have no affilation with planet-cnc.com
//but I am happy with thier software.
//
//Porcupine CNC Mod
//Developed by: Christopher Ekiert, 2023 and released under
//GNU Lesser General Public License v2.1
//
//
//
//This software depends on on code
//developed by others, special thanks to
//the following software developers 
/**
 * ControlP5 library
* GNU Lesser General Public License v2.1
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlP5
 */
import controlP5.*;
ControlP5 cp5;
PFont font;
CheckBox checkbox;
PImage img;
int myColor = color(255);
int c1,c2;

float n,n1;

String[] lines;
PrintWriter output;
int cool = 0;
int requestmql = 0;//does the user want to use mql
int hasseenspin = 0; //the air compressor only turns on once
String out;
int buttonaenable = 0;
int buttonbenable = 0;
int buttoncenable = 0;
int buttondenable = 0;
int filewritten = 0;
int modifyclick = 0;
String Originalfile = "";
String Savefile = "";
String cnchostloc = "";
int gcodelinenum = 0;
int uselinenum = 1; // val 1 adds line numbers to output file


void setup() {
  surface.setTitle("Porcupine CNC Mod");
  font = createFont("helvetica", 13);
    size(800,400);
  noStroke();
  img = loadImage("/data/Porcupine.png");
  cp5 = new ControlP5(this);
  cp5.addButton("Load_File")
     .setValue(0)
     .setPosition(40,70)
     .setSize(200,19)
     .setFont(font)
     ;
  
  cp5.addButton("Save_File")
     .setValue(100)
     .setPosition(40,95)
     .setSize(200,19)
     .setFont(font)
     ;
     
  cp5.addButton("Modify_File")
     .setValue(100)
     .setPosition(40,150)
     .setSize(200,19)
     .setFont(font)
     ;
  cp5.addButton("Open_CNCUSBcontroller_App")
     .setValue(100)
     .setPosition(70,180)
     .setSize(230,19)
     .setFont(font)
     ;
     cp5.getController("Open_CNCUSBcontroller_App").setVisible(false);
       checkbox = cp5.addCheckBox("checkBox")
                .setPosition(40, 125)
                .setSize(20, 20)
                .setItemsPerRow(3)
                .setSpacingColumn(30)
                .setSpacingRow(20)
                .setFont(font)
                .addItem("",1)
                ;
                
      cp5.addCheckBox("nline")
                .setPosition(240, 125)
                .setSize(20, 20)
                .setItemsPerRow(3)
                .setSpacingColumn(30)
                .setSpacingRow(20)
                .setFont(font)
                .addItem(" ",1)
                ;
 }
 
 
 
 void draw() {
  background(myColor);
  myColor = lerpColor(c1,c2,n);
  n += (1-n)* 0.1;
  textSize(30);
  text("Porcupine CNC Mod Gcode Translator",20,40);
  textSize(15);
  text("Status:",7,200);
  text("Add MQL to Gcode file?",70,140);
  text("Add Line Numbers to gcode file?",270,140);
  stroke(20);
  noFill();
  rect(7, 205, 786, 180);
 if(uselinenum == 0){
    textSize(15);
    fill(0,408,612,816);
    text("Add line numbers is turned off",130,225);
  }
  if(uselinenum == 1){
    textSize(15);
    fill(0,408,612,816);
    text("Add line numbers is turned on",130,225);
    fill(255,0,0);
    text('\u2713',230,140);
    fill(0,408,612,816);
  }
  if(requestmql == 0){
    textSize(15);
    fill(0,408,612,816);
    text("MQL is turned off",10,225);
  }
  if(requestmql == 1){
    textSize(15);
    fill(0,408,612,816);
    text("MQL is turned on",10,225);
    fill(255,0,0);
    text('\u2713',30,140);
    fill(0,408,612,816);
  }
  if(Originalfile.equals("") == false){
    textSize(15);
    fill(0,408,612,816);
    text("File to edit Selected:",10,275);
    text(Originalfile,10,250);
  }
  if(Savefile.equals("") == false){
  textSize(15);
    fill(0,408,612,816);
    text("Save Location Selected:",10,325);
    text(Savefile,10,300);
  }
  if(modifyclick == 1){
    textSize(15);
    fill(0,408,612,816);
    text("Modifying file in process...",10,350);
  }
  if(filewritten == 1){
    textSize(15);
    fill(0,408,612,816);
    text("Modified file has been written",10,375);
    cp5.getController("Open_CNCUSBcontroller_App").setVisible(true);
  }
  image(img, 600,20,180,180);
}




 
 void insertfile(String gcodefile){
   String[] liner = loadStrings(gcodefile);
   for (int i = 0; i < liner.length; i++){
     //copy the entire file into the new gcode file line by line
     if(uselinenum == 0){
       output.println(liner[i]);
     } else {
       gcodelinenum = gcodelinenum + 2;
       if(gcodelinenum < 100000){
         //its a valid number
       } else {
         // it too high to be a valid line number reset
         gcodelinenum = 2;
       }
       if(gcodelinenum < 10){ //add 4 zeros
          output.println("N0000" + gcodelinenum + " " + liner[i]);
        }
        if(gcodelinenum < 100 && gcodelinenum > 9){ //add 3 zero
          output.println("N000" + gcodelinenum + " " + liner[i]);
        }
        if(gcodelinenum < 1000 && gcodelinenum > 99){ //add 2 zero
          output.println("N00" + gcodelinenum + " " + liner[i]);
        }
        if(gcodelinenum < 10000 && gcodelinenum > 999){// add 1 zero
          output.println("N0" + gcodelinenum + " " + liner[i]);
        }
        if(gcodelinenum < 100000 && gcodelinenum > 9999){// add 0 zero
          output.println("N" + gcodelinenum + " " + liner[i]);
        }
     }
   }
 }
 
 
