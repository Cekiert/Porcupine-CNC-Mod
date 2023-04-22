 void catchMtwo(String lin){
   //look for m2 so we turn off spindle, air, mql
   if (lin.equals("M2") == true){
     //print("M2 detected \n");
     //output.println("M2 detected");
     if (requestmql == 1){ //if mql was used
       //turn off mql and compressor
       //print("turn off mql \n");
       insertfile("data/mist/mist_OFF.dat");
       //print("turn off spindle \n");
       insertfile("data/spindle_speed/spindle_speed_0.dat");
       //print("turn off compressor \n");
       insertfile("data/air_compressor/air_compressor_OFF.dat");
     } else { //without mql
       //print("turn off spindle \n");
       insertfile("data/spindle_speed/spindle_speed_0.dat");
     }
   }
 }
 
 void catchtraveltype(String lin){
   String[] mql = split(lin, ' ');
   //G0 travel mql off
   //G1 cutting mql on
   if(requestmql == 1){
     if (mql.length > 1){
       if (mql[0].equals("G0") == true){
         if(cool == 0){
           //coolant already off
         } else {
           //print("turn off coolant \n");
           insertfile("data/mist/mist_OFF.dat");
           cool = 0;
         }
       }
       if (mql[0].equals("G1") == true){
          if(cool == 0){
            //print("turn on coolant \n");
            insertfile("data/mist/mist_ON.dat");
            cool = 1;
          } else {
            //coolant already on
          }
        }
      }
    }
 }
 
 void catchSpindle(String sval){
        //spindle speed change
        int speed = int(sval);
        if (hasseenspin == 0 && requestmql == 1){
          hasseenspin = 1;
          //print("turn on air compressor \n");
          insertfile("data/air_compressor/air_compressor_ON.dat");
        }
        if (speed > 9700) {
           //print("set rpm to: 100 percent \n");
           insertfile("data/spindle_speed/spindle_speed_100.dat");
        }
        if (speed <= 9700 && speed > 9200) {
           //print("set rpm to: 95 percent \n");
           insertfile("data/spindle_speed/spindle_speed_95.dat");
        }
        if (speed <= 9200 && speed > 8700) {
           //print("set rpm to: 90 percent \n");
           insertfile("data/spindle_speed/spindle_speed_90.dat");
        }
        if (speed <= 8700 && speed > 8200) {
           //print("set rpm to: 85 percent \n");
           insertfile("data/spindle_speed/spindle_speed_85.dat");
        }
        if (speed <= 8200 && speed > 7700) {
           //print("set rpm to: 80 percent \n");
           insertfile("data/spindle_speed/spindle_speed_80.dat");
        }
        if (speed <= 7700 && speed > 7200) {
           //print("set rpm to: 75 percent \n");
           insertfile("data/spindle_speed/spindle_speed_75.dat");
        }
        if (speed <= 7200 && speed > 6700) {
           //print("set rpm to: 70 percent \n");
           insertfile("data/spindle_speed/spindle_speed_70.dat");
        }
        if (speed <= 6700 && speed > 6200) {
           //print("set rpm to: 65 percent \n");
           insertfile("data/spindle_speed/spindle_speed_65.dat");
        }
        if (speed <= 6200 && speed > 5700) {
           //print("set rpm to: 60 percent \n");
           insertfile("data/spindle_speed/spindle_speed_60.dat");
        }
        if (speed <= 5700 && speed > 5200) {
           //print("set rpm to: 55 percent \n");
           insertfile("data/spindle_speed/spindle_speed_55.dat");
        }
        if (speed <= 5200 && speed > 4700) {
           //print("set rpm to: 50 percent \n");
           insertfile("data/spindle_speed/spindle_speed_50.dat");
        }
        if (speed <= 4700 && speed > 4200) {
           //print("set rpm to: 45 percent \n");
           insertfile("data/spindle_speed/spindle_speed_45.dat");
        }
        if (speed <= 4200 && speed > 3700) {
           //print("set rpm to: 40 percent \n");
           insertfile("data/spindle_speed/spindle_speed_40.dat");
        }
        if (speed <= 3700 && speed > 3200) {
           //print("set rpm to: 35 percent \n");
           insertfile("data/spindle_speed/spindle_speed_35.dat");
        }
        if (speed <= 3200 && speed > 2700) {
           //print("set rpm to: 30 percent \n");
           insertfile("data/spindle_speed/spindle_speed_30.dat");
        }
        if (speed <= 2700 && speed > 2200) {
           //print("set rpm to: 25 percent \n");
           insertfile("data/spindle_speed/spindle_speed_25.dat");
        }
        if (speed <= 2200 && speed > 1700) {
           //print("set rpm to: 20 percent \n");
           insertfile("data/spindle_speed/spindle_speed_20.dat");
        }
        if (speed <= 1700 && speed > 1200) {
           //print("set rpm to: 15 percent \n");
           insertfile("data/spindle_speed/spindle_speed_15.dat");
        }
        if (speed <= 1200 && speed > 700) {
           //print("set rpm to: 10 percent \n");
           insertfile("data/spindle_speed/spindle_speed_10.dat");
        }
        if (speed <= 700 && speed > 1) {
           //print("set rpm to: 5 percent \n");
           insertfile("data/spindle_speed/spindle_speed_5.dat");
        }
        if (speed == 0) {
           //print("set rpm to: 0 percent \n");
           insertfile("data/spindle_speed/spindle_speed_0.dat");
        }
        //print("set rpm to: " + sval + "\n"); //insert the correct speed here
 }
 
 void modify(){
   lines = loadStrings(Originalfile);
   output = createWriter(Savefile);
   for (int i = 0; i < lines.length; i++){
      //detect spindle speed S attribute-G1 Z0.600 F1500.0 S10000
      String[] parts = split(lines[i], " S");
      if (parts.length > 1){
        catchSpindle(parts[1]);
      }
      catchtraveltype(lines[i]); //mql only needs to run during g1
      catchMtwo(lines[i]); //catch the end of file to turn off mql compressor spindle
      //print(lines[i] + "\n");
      if(uselinenum == 0){
         output.println(lines[i]);
      } else {
        gcodelinenum = gcodelinenum + 2;
        if(gcodelinenum < 100000){
          //its a valid number
        } else {
          // it too high to be a valid line number reset
          gcodelinenum = 2;
        }
        if(gcodelinenum < 10){ //add 4 zeros
          output.println("N0000" + gcodelinenum + " " + lines[i]);
        }
        if(gcodelinenum < 100 && gcodelinenum > 9){ //add 3 zero
          output.println("N000" + gcodelinenum + " " + lines[i]);
        }
        if(gcodelinenum < 1000 && gcodelinenum > 99){ //add 2 zero
          output.println("N00" + gcodelinenum + " " + lines[i]);
        }
        if(gcodelinenum < 10000 && gcodelinenum > 999){// add 1 zero
          output.println("N0" + gcodelinenum + " " + lines[i]);
        }
        if(gcodelinenum < 100000 && gcodelinenum > 9999){// add 0 zero
          output.println("N" + gcodelinenum + " " + lines[i]);
        }
        
      }
      //output.println(lines[i]); // doesnt need a newline
    }
    output.flush();
    output.close();
    filewritten = 1;
    draw();
  }
