void x10() {
  Inc = 10;
  Btn_01.setColorBackground(color(0, 0, 150)); 
  Btn_1 .setColorBackground(color(0, 0, 150)) ;
  Btn_10 .setColorBackground(color(0, 150, 255)) ;
}
void x1() {
  Inc = 1;
  Btn_01.setColorBackground(color(0, 0, 150)); 
  Btn_1 .setColorBackground(color(0, 150, 255)) ;
  Btn_10 .setColorBackground(color(0, 0, 150)) ;
}
void x01() {
  Inc = 0.1;
  Btn_01.setColorBackground(color(0, 150, 255)); 
  Btn_1 .setColorBackground(color(0, 0, 150)) ;
  Btn_10 .setColorBackground(color(0, 0, 150)) ;
}



void Zup() {
  ArmMove(0, 0, Inc, FSpeed);
}
void Zdwn() {

  ArmMove(0, 0, -1*Inc, FSpeed);
}
void MouseDraw() {
  RunningFlag=0;
  DrawFlag = 1;
  Btn_01.hide();
  Btn_1 .hide();
  Btn_10 .hide();
  Btn_Dwn.hide();
  Btn_UP.hide();
}


void ClearDraw() {
  RunningFlag = 0;
  DrawFlag = 1;
  PointData.clear();
  PointData.add(new PVector(width*.5, width*.5, 10));// Set Center for reference point
  toggle_ShowBD.setValue(false);
}


void StartArmDraw() {

  FlagNeedStorge = 1;
  //myPort.write("M114\n"); // Storage calibrated starting point
  //delay(100);

  GetBoundary();
  if (PointData.size() > 0 ) {
    PointCount = 0;
    WaitFlag = 0;
    RunningFlag = 1;

    //PenUp for center to Start Point
    ArmMove(0, 0, PenZvalue, FSpeed);

    println("Start");
    DrawFlag = 0;
    Btn_Draw.hide();
    Btn_Run.hide();
    Btn_BOD.hide();
    Btn_TraceBD.hide();
    Btn_BackToCenter.hide();
    Btn_CLS.hide();
    Btn_Pause.show();
    toggle_One.hide();
    Btn_Save.hide();
    Btn_GCODE.hide();
    // Move arm from center to 1st point
    PVector move = CalcMove(PointData.get(0), PointData.get(1) );
    ArmMove(move.x, move.y, 0, FSpeed);

    //PenDown at Start point
    ArmMove(0, 0, -1*PenZvalue, FSpeed);

    PointCount = 2;
  }
}



void DrawBoundary() {
  GetBoundary();
  ArmMove(0, 0, +5.5, 5000); // PenUP
  PenStatus = 1;
  RunningFlag = 3;
  DrawFlag = 0;
  DrawBound = 0;
  toggle_ShowBD.setValue(true);
  Btn_Run.hide();
  Btn_CLS.hide();
  Btn_BOD.hide();
  Btn_TraceBD.hide();
  Btn_Save.hide();
  Btn_GCODE.hide();
}

void TraceBoundary() { // No Drawing
  GetBoundary();
  ArmMove(0, 0, PenZvalue, 5000); // PenUP
  PenStatus = 1;

  RunningFlag = 3;
  DrawFlag = 0;
  DrawBound = 1;
  toggle_ShowBD.setValue(true);
  Btn_Run.hide();
  Btn_CLS.hide();
  Btn_BOD.hide();
  Btn_TraceBD.hide();
  Btn_Save.hide();
  Btn_GCODE.hide();
}

void PauseOnAndOff() {

  if (RunningFlag == 1) {
    RunningFlag = 4;
    Btn_Pause .setColorBackground(color(200, 150, 200)) ;
    Btn_Cancel.show();
  } else {
    RunningFlag = 1;
    Btn_Pause .setColorBackground(color(0, 0, 150)) ;
    Btn_Cancel.hide();
  }
}

void CancelDraw() {

  //Force finish draw points and prepare redraw again
  PointCount = PointData.size();
  Btn_Pause .setColorBackground(color(0, 0, 150)) ;
  Btn_Cancel.hide();
  RunningFlag = 1;
}
void ArmBackToCenter() { // Prepare for Arm Draw same data again

  //  PVector TargetPoint=PointStrage;
  ArmMove(0, 0, -1* FinishZ+PenZvalue, 5000); // PenDown to UP level
  PenStatus = 1;


  PVector move = CalcMove(PointData.get(PointCount-1), PointData.get(0) );

  ArmMove(move.x, move.y, 0, FSpeed);
  Btn_BackToCenter.hide();
}

void fileLoad() {
  RunningFlag=0;

  selectInput("Select a Draw data:", "LoadCSV");
}

void LoadCSV(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    //exit();
  } else {

    println(selection);
    println("User selected " + selection.getAbsolutePath());
    getFile = (String) selection.getAbsolutePath();
    // Check file extension
    String ext = getFile.substring(getFile.lastIndexOf('.') + 1);
    //その文字列を小文字にする
    ext.toLowerCase();

    if (ext.equals("csv")) {
      PointData.clear();
      PointData.add(new PVector(width*.5, width*.5));// Set Center for reference point

      gotData= loadTable(getFile, "header");
      try {
        println("----------");
        for (int i=0; i< gotData.getRowCount(); i++) {
          println( gotData.getFloat(i, 0)+" , "+ gotData.getFloat(i, 1)+" , "+ gotData.getFloat(i, 2));

          PointData.add(new PVector(gotData.getFloat(i, 0), gotData.getFloat(i, 1), gotData.getFloat(i, 2)));
        }
      }  
      catch  (Exception e) {
        JOptionPane.showMessageDialog(frame, "The file is not drawing data");
      }
      surface.setTitle("DexArm Study ver "+version+" | "+selection.getName());
      MouseDraw();
    } else {  
      JOptionPane.showMessageDialog(frame, "The file is not drawing data");
    }
  }
}



void fileSave() {
  if (PointData.size()>1) {
    selectOutput("Select a file to write to:", "SaveCSV");
  }
}

void SaveCSV(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    //exit();
  } else {

    println(selection);
    println("User selected " + selection.getAbsolutePath());
    getFile = (String) selection.getAbsolutePath();

    // Check if overwrite csv
    String ext = getFile.substring(getFile.lastIndexOf('.') + 1);
    ext.toLowerCase();

    String SaveFile = getFile;
    if (!ext.equals("csv")) { 
      SaveFile=getFile+".csv";
    }

    fileWriter=createWriter(SaveFile);
    fileWriter.println("point data for DexArm one stroke drawing");
    for (int i=1; i<PointData.size()-1; i++) {
      String code=str(PointData.get(i).x)+","+str(PointData.get(i).y)+","+str(PointData.get(i).z);
      fileWriter.println(code);
    }
    fileWriter.flush();
    fileWriter.close();
    JOptionPane.showMessageDialog(frame, "File Saved");
  }
}
void SaveGCode() {

  if (PointData.size()>1) {
    String mes="Normal Draw";
    if (toggle_One.getBooleanValue()) {
      mes="One Stroke Draw";
    }
    selectOutput("Save "+mes+" mode as GCODE", "GCODE");
  }
}
void GCODE(File selection) {
  //output in G-code, it looks like you need to output in absolute coordinates.

  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    //exit();
  } else {
    println(selection);
    println("User selected " + selection.getAbsolutePath());
    getFile = (String) selection.getAbsolutePath();

    // Check if overwrite csv
    String ext = getFile.substring(getFile.lastIndexOf('.') + 1);
    ext.toLowerCase();

    String SaveFile = getFile;
    if (!ext.equals("gcode")) { 
      SaveFile=getFile+".gcode";
    }

    fileWriter=createWriter(SaveFile);

    //Build GCODE
    println("Start Build GCODE");
    fileWriter.println(";point data for DexArm one stroke drawing");
    fileWriter.println(";----------- Start Gcode -----------");
    fileWriter.println("M2000;custom:line mode");
    fileWriter.println("M888 P0;custom:header is write&draw");
    fileWriter.println(";-----------------------------------");
    fileWriter.println("G1 F"+str(FSpeed));
    fileWriter.println("M118 E1 Start Draw:"+selection.getName());

    //PenUP to 1st point
    fileWriter.println("G0 Z5");
    PenStatus=1;

    PVector move; 
    String code="G1 X"+str(Scale*PointData.get(1).x-0.5*Scale*width)+" Y"+str(-1*Scale*PointData.get(1).y+0.5*Scale*width);
    fileWriter.println(code);
    if (!toggle_One.getBooleanValue()) { //In normal Draw mode, Pen Down action need
      fileWriter.println("G0 Z0"); // "Z 0" = work origin
      PenStatus=0;
    }

    for (int i=1; i<PointData.size()-1; i++) {
     
      move = CalcMove(PointData.get(i-1), PointData.get(i) );
      if (!(move.x==0 && move.y == 0)) {  // Skip same points.
      
        if (toggle_One.getBooleanValue()) { // If normal draw mode add Pen Up and Down Command
          if (PenStatus == 1&& PointData.get(i-1).z == 0) {
            fileWriter.println("G0 Z5"); // Insert PenUp
            PenStatus=0;
          }
          if (PenStatus == 0 && PointData.get(i-1).z == 10) { // if not OneStroke
            fileWriter.println("G0 Z0"); // Insert PenDown
            PenStatus=1;
          }
        } 

        code="G1 X"+str(Scale*PointData.get(i).x-0.5*Scale*width)+" Y"+str(-1*Scale*PointData.get(i).y+0.5*Scale*width);
        fileWriter.println(code);

        if (i%10==0) {   
          // Send progress % to serial monitor
          fileWriter.println("M118 E1 ___Processing: "+str(0.1*float(int(float(i)/(PointData.size()-1)*1000)))+"%");
        }
      }
    }
    fileWriter.println("G1 Z50"); // PenUP for Finish
    fileWriter.println(";----------- End Gcode -------------"); // 
    fileWriter.println(";-----------------------------------"); // 
    fileWriter.flush();
    fileWriter.close();
    JOptionPane.showMessageDialog(frame, "GCODE File Saved");
  }
}
