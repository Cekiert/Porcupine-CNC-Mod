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
//Porcupine CNC Mod https://github.com/Cekiert/Porcupine-CNC-Mod
//Developed by: Christopher Ekiert, 2023 and released under
//GNU Lesser General Public License v2.1
//
//
//
//This software depends on libraries
//developed by others they are covered under 
//their own Licenses 
#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <avr/wdt.h>

LiquidCrystal_I2C lcd(0x27,16,2);  //I have used I2C scan program, so address is correct.
bool ledstate = LOW;
byte cncmode = 0; //pulses from cnc range 0-255 was byte
byte cncval = 0; //pulses from cnc range 0-255 was byte
byte vala = 0; //stores 1 or 0
byte valb = 0; //stores 1 or 0
byte valaa = 0; //stores 1 or 0
byte valbb = 0; //stores 1 or 0
int pottargetlow = 0;//stores 0-1023
int pottargethigh = 1023;//stores 0-1023
int Dcycle = 0; //3 bytes
String Dspin = "Spin Off"; //Spindle status
String Dcool = "    "; //mist when on 4 bytes
String Dair = "   "; //Air when on 3 bytes
unsigned long ledpremills = 0; //4 bytes mills
unsigned long pulpremills = 0; //4 bytes mills
const int interval = 500; //used for display updates/led flash was 3000
const int pulsetimeout = 1000;
  
void setup()
{
  //does running the spindle in reverse ground out the frying driver boards?
  //my machine doesnt have spindle power leads ground to frame
  pinMode(13, OUTPUT); //setup led
  //setup relays
  pinMode(2, OUTPUT); //relay 1: spindle speed increase Pot(relay 1+2 required)
  digitalWrite(2, HIGH); //relay 1: spindle speed increase Pot(relay 1+2 required)
  pinMode(3, OUTPUT); //relay 2: spindle speed increase Pot(relay 1+2 required)
  digitalWrite(3, HIGH); //relay 2: spindle speed increase Pot(relay 1+2 required)
  //
  pinMode(4, OUTPUT); //relay 3: spindle speed decrease Pot(relay 3+4 required)
  digitalWrite(4, HIGH); //relay 3: spindle speed decrease Pot(relay 3+4 required)
  pinMode(5, OUTPUT); //relay 4: spindle speed decrease Pot(relay 3+4 required)
  digitalWrite(5, HIGH); //relay 4: spindle speed decrease Pot(relay 3+4 required)
  //
  pinMode(6, OUTPUT); //relay 5: unused
  digitalWrite(6, HIGH); //relay 5: unused
  pinMode(7, OUTPUT); //relay 6: mist
  digitalWrite(7, HIGH); //relay 6: mist
  pinMode(8, OUTPUT); //relay 7: unused
  digitalWrite(8, HIGH); //relay 7: unused
  pinMode(9, OUTPUT); //relay 8: Compressor Relay
  digitalWrite(9, HIGH); //relay 8: Compressor Relay
  pinMode(A0,INPUT); //cnc m64 p2(value)
  pinMode(A1,INPUT); //cnc m64 p3(mode)
  pinMode(A3,INPUT); //pot wiper
  lcd.init();
  lcd.backlight();
  lcd.print(F(" Porcupine Mod"));
  delay(interval);
  lcd.clear();
  wdt_enable(WDTO_8S); //start watchdog
}

void loop()
{
  UpdateDisplay(); //updates the display and keeps led flashing
  ReadLPTPort(); //Checks LPT port for data
  CheckCMDCool(); //see if a command is ready related to cooling
  CheckCMDSpinHigh(); //See if a command is ready related to spindle speed 100-55%
  CheckCMDSpinLow(); //See if a command is ready related to spindle speed 50-0%
  CheckPot(); //see if pot needs to be trimmed
  SpinStatus(); //checks the spin status
  wdt_reset(); //resets watchdog timer
}


void SpinStatus(){
  if(Dcycle >= 5){
    Dspin = "Spin ON ";
  }
  if(Dcycle == 0){
    Dspin = "Spin OFF";
  }
}

void ReadLPTPort(){
//B: Buffer Incoming Data From CNC
  unsigned long currentmills = millis();
  valb = digitalRead(A0);
  vala = digitalRead(A1);
  if(vala != valaa){
    vala = valaa;
    if (cncval != 0){
      //getting a new command but still have the last one
      lcd.clear();
      lcd.setCursor(1,0);
      lcd.print(F("Error:123"));
      lcd.setCursor(1,1);
      lcd.print(F("Mode:"));
      lcd.print(cncmode);
      lcd.print(F(" Val:"));
      lcd.print(cncval);
      delay(10000);
    } else {
      //a0 just pulsed
      cncmode = cncmode + 1;
      pulpremills = currentmills;
      delay(300);
    }
  }
  if(valb != valbb){
    valb = valbb;
    if (cncmode == 0){
      //setting a value to illegal mode
      lcd.clear();
      lcd.setCursor(1,0);
      lcd.print(F("Error:456"));
      lcd.setCursor(1,1);
      lcd.print(F("Mode:"));
      lcd.print(cncmode);
      lcd.print(F(" Val:"));
      lcd.print(cncval);
      delay(10000);
    } else {
      //a1 just pulsed
      cncval = cncval + 1;
      pulpremills = currentmills;
      delay(300);
    }
  }  
}


void UpdateDisplay(){
  //A:Flash LED / Update Display
  unsigned long currentmills = millis();
  if (currentmills - ledpremills >= interval){
    ledpremills = currentmills;
    if (ledstate == LOW){
      ledstate = HIGH;
      //update display D1
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print(Dspin);
      lcd.setCursor(13,0);
      lcd.print(Dair);
      lcd.setCursor(0,1);
      lcd.print(F("Speed:"));
      lcd.setCursor(6,1);
      lcd.print(Dcycle);
      lcd.setCursor(12,1);
      lcd.print(Dcool);
    } else {
      ledstate = LOW;
    }
    digitalWrite(13, ledstate);
  }
}

void CheckCMDCool(){
  //Checks for commands related to cooling
  unsigned long currentmills = millis();
  if (currentmills - pulpremills >= pulsetimeout && cncmode != 0){
    if(cncmode == 1 && cncval == 2){
      //mql coolant on
      digitalWrite(7, LOW); //turn on relay 6
      Dcool = "Mist"; //save for display
    }
    if(cncmode == 1 && cncval == 1){
      //mql coolant off
      digitalWrite(7, HIGH); //turn off relay #6
      Dcool = "    "; //save for display  
    }
    if(cncmode == 4 && cncval == 2){
      //aircompressor on
      digitalWrite(9, LOW); //turn on relay #8
      Dair = "Air"; //save for display
    }
    if(cncmode == 4 && cncval == 1){
      //aircompressor off
      digitalWrite(9, HIGH); //turn off relay #8
      Dair = "   "; //save for display
    }
  }
}


void CheckCMDSpinHigh(){
  unsigned long currentmills = millis();
  if (currentmills - pulpremills >= pulsetimeout && cncmode != 0){
    if(cncmode == 3 && cncval == 1){
      //set spindle speed to 100%
      //todo: set motorized pot +-10 to read 1023
      pottargetlow = 1013;
      pottargethigh = 1023;
    }
    if(cncmode == 3 && cncval == 2){
      //set spindle speed to 95%
      //todo: set motorized pot +-10 to read 973
      pottargetlow = 963;
      pottargethigh = 983;
    }
    if(cncmode == 3 && cncval == 3){
      //set spindle speed to 90%
      //todo: set motorized pot +-10 to read 922
      pottargetlow = 912;
      pottargethigh = 932;
    }
    if(cncmode == 3 && cncval == 4){
      //set spindle speed to 85%
      //todo: set motorized pot +-10 to read 870
      pottargetlow = 860;
      pottargethigh = 880;
    }
    if(cncmode == 3 && cncval == 5){
      //set spindle speed to 80%
      //todo: set motorized pot +-10 to read 819
      pottargetlow = 809;
      pottargethigh = 829;
    }
    if(cncmode == 3 && cncval == 6){
      //set spindle speed to 75%
      //todo: set motorized pot +-10 to read 768
      pottargetlow = 758;
      pottargethigh = 778;
    }
    if(cncmode == 3 && cncval == 7){
      //set spindle speed to 70%
      //todo: set motorized pot +-10 to read 717
      pottargetlow = 707;
      pottargethigh = 727;
    }
    if(cncmode == 3 && cncval == 8){
      //set spindle speed to 65%
      //todo: set motorized pot +-10 to read 666
      pottargetlow = 656;
      pottargethigh = 676;
    }
    if(cncmode == 3 && cncval == 9){
      //set spindle speed to 60%
      //todo: set motorized pot +-10 to read 614
      pottargetlow = 604;
      pottargethigh = 624;
    }
    if(cncmode == 3 && cncval == 10){
      //set spindle speed to 55%
      //todo: set motorized pot +-10 to read 563
      pottargetlow = 553;
      pottargethigh = 573;
    }
    if(cncmode == 3 && cncval == 11){
      //set spindle speed to 50%
      //todo: set motorized pot +-10 to read 512
      pottargetlow = 502;
      pottargethigh = 522;
    }
  }  
}

void CheckCMDSpinLow(){
  //C: Process A Command Sent from the cnc
  unsigned long currentmills = millis();
  if (currentmills - pulpremills >= pulsetimeout && cncmode != 0){
    if(cncmode == 3 && cncval == 12){
      //set spindle speed to 45%
      //todo: set motorized pot +-10 to read 461
      pottargetlow = 451;
      pottargethigh = 471;
    }
    if(cncmode == 3 && cncval == 13){
      //set spindle speed to 40%
      //todo: set motorized pot +-10 to read 410
      pottargetlow = 400;
      pottargethigh = 420;
    }
    if(cncmode == 3 && cncval == 14){
      //set spindle speed to 35%
      //todo: set motorized pot +-10 to read 358
      pottargetlow = 348;
      pottargethigh = 368;
    }
    if(cncmode == 3 && cncval == 15){
      //set spindle speed to 30%
      //todo: set motorized pot +-10 to read 307
      pottargetlow = 297;
      pottargethigh = 317;
    }
    if(cncmode == 3 && cncval == 16){
      //set spindle speed to 25%
      //todo: set motorized pot +-10 to read 256
      pottargetlow = 246;
      pottargethigh = 266;
    }
    if(cncmode == 3 && cncval == 17){
      //set spindle speed to 20%
      //todo: set motorized pot +-10 to read 205
      pottargetlow = 195;
      pottargethigh = 215;
    }
    if(cncmode == 3 && cncval == 18){
      //set spindle speed to 15%
      //todo: set motorized pot +-10 to read 154
      pottargetlow = 144;
      pottargethigh = 164;
    }
    if(cncmode == 3 && cncval == 19){
      //set spindle speed to 10%
      //todo: set motorized pot +-10 to read 102
      pottargetlow = 92;
      pottargethigh = 112;
    }
    if(cncmode == 3 && cncval == 20){
      //set spindle speed to 5%
      //todo: set motorized pot +-10 to read 51
      pottargetlow = 41;
      pottargethigh = 61;
    }
    if(cncmode == 3 && cncval == 21){
      //set spindle speed to 0%
      //todo: set motorized pot +-10 to read 0
      pottargetlow = 0;
      pottargethigh = 10;
    }
  //clear buffer
  cncmode = 0;
  cncval = 0;
  }
}



void CheckPot(){
     //E: Adjust potentiometer
    //todo: read position 3x average reading, if we have a new setting set each pass till target reached
    //when target speed is reached. compare current value to set range and update display as it changes
    //
    //
    //
    //
    int potspeedd = 6000;
    int potspeedc = 4000;
    int potspeedb = 600;
    int potspeeda = 300;
    int potspeeddif = 100;
    int potval = analogRead(A3); //read new pot value
    Dcycle = map(potval , 0, 1023, 0, 100);
    if(potval > pottargethigh){//average pot value is too high
      //lower pot
      digitalWrite(2, LOW);//activate relay 3 to drive pot
      digitalWrite(3, LOW);//activate relay 4 to drive pot
      if(potval - pottargethigh > 666){
        delay(potspeedd);//let the pot motor tweak towards a correction
      }
      if(potval - pottargethigh > 333 && potval - pottargethigh <=666){//big steps
        delay(potspeedc);//let the pot motor tweak towards a correction
      }
      if(potval - pottargethigh > 200 && potval - pottargethigh <= 333){//medium steps
        delay(potspeedb);//let the pot motor tweak towards a correction
      }
      if(potval - pottargethigh <= 200){//fine tune
        delay(potspeeda);//let the pot motor tweak towards a correction
      }
      digitalWrite(2, HIGH);//turn the pot motor off
      digitalWrite(3, HIGH);//turn the pot motor off
      delay(500);//let the motor stop before maybe swapping direction in the next cycle
    }
    if(potval < pottargetlow){//average pot value is too low
      //raise pot
      digitalWrite(4, LOW);//activate relay 1 to drive pot
      digitalWrite(5, LOW);//activate relay 2 to drive pot
      if(pottargetlow - potval > 666){
        delay(potspeedd - potspeeddif);//let the pot motor tweak towards a correction
      }
      if(pottargetlow - potval > 333 && pottargetlow - potval <= 666){
        delay(potspeedc - potspeeddif);//let the pot motor tweak towards a correction
      }
      if(pottargetlow - potval > 200 && pottargetlow - potval <= 333){//medium steps
        delay(potspeedb - potspeeddif);//let the pot motor tweak towards a correction
      }
      if(pottargetlow - potval <= 200){//fine tune
        delay(potspeeda - potspeeddif);//let the pot motor tweak towards a correction
      }
      digitalWrite(4, HIGH);//turn the pot motor off
      digitalWrite(5, HIGH);//turn the pot motor off
      delay(500);//let the motor stop before maybe swapping direction in the next cycle
    } 
    if(potval < pottargethigh && potval > pottargetlow){
      //the motor reached its happy position lets let the operator control the pot without fighting
      pottargetlow = 0;
      pottargethigh = 1023;
    } 
}
