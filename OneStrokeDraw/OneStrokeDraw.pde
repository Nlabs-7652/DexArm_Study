//  Example testing sketch for DexArm
//  One Stroke Draw for DexArm v1.21
//  
//  Written By Nlab7652, Summer 2020
//
// Copyright (c) 2020 Nakayama Lab
// Released under the MIT license
//
//
//

import processing.serial.*;


import javax.swing.UIManager;
import java.awt.Font;
import javax.swing.JOptionPane; 



import controlP5.*;

ControlP5 INTERFACES;

Float version=1.21;
/////////////////

Boolean Need_Select_Serial=true;   // If you need select Serial port  set true 
String myArmPort="COM3";           // If serial port is fixed this com port will use
int baudrate=115200;               // change baud rate to your liking

/////////////////
int sizeW = 750  ;   // Screen size
int sizeH = 750;     // should be square?

Float ArmSpan=150.0; // Range of the arm move 

int FSpeed=5000;     // Feedrate in mm per minute. (Speed of print head movement)
int delay_time=500;  

///////////////////
Float Scale;         // from Screen to Arm
int FontSize;

Serial myPort;
String serial_list;                // list of serial ports
int serial_list_index = 0;         // currently selected serial port 
int num_serial_ports = 0;          // number of serial ports in the list



int lf = 10;    // LineFeed in ASCII
String myString = null;
String mes = "";


ArrayList<PVector>PointData  = new ArrayList<PVector>();
int PointCount=0;
ArrayList<PVector>BoundaryPointS  = new ArrayList<PVector>();
int BoundaryCount=0;

int LimitReached=0; // Count XY limit during move
int StopWhenLimit=3; //  If limit message evoked repeatedly, recalibration might be necessary


PVector PointStrage= new PVector(0, 0, 0);
int FlagNeedStorge=0;



int RunningFlag=0;
//  0   Calibration
//  1   Arm Draw
//  2   End draw
//  3   Move Boundary
//　4　 Pause

int WaitFlag=0;
int DrawFlag=0;
int PenStatus=0;
int DrawBound=0;
int LineDraw=0;


PFont f;
float Inc=10;
float PenZvalue=10.5; // amount of movement in the Z for Pen Up or Down 
float FinishZ=50.0; // When finish drawing, Pen will UP 



PVector Bposition;
PVector BPrePoint;
float BarmX, BarmY, BarmZ;


String getFile = null;


void settings() {
  size(sizeW, sizeH);
}

void setup() {
  surface.setTitle("DexArm Study ver"+version);

  Scale=ArmSpan/(float(width));
  FontSize=int(32*width/1500);
  GUI_init();

  PointData.add(new PVector(width*.5, width*.5));// Set Center for reference point


  //// Serial port setting

  // get the number of serial ports in the list
  num_serial_ports = Serial.list().length;

  if (  num_serial_ports==0) {
    exit();
  }

  if (!Need_Select_Serial&&  num_serial_ports>0) {
    myPort = new Serial(this, myArmPort, baudrate); // change baud rate to your liking

    // Initialize theArm
    myPort.write("M1112\nG91\n"); 
    println("Home");
    delay(delay_time);
  } else {


    try {
      switch(num_serial_ports) {
      case 0:
        JOptionPane.showMessageDialog(frame, "Device is not connected to the PC");
        exit();
        break;

      case 1:  
        myPort = new Serial(this, myArmPort, baudrate); 

        // Initialize theArm
        myPort.write("M1112\nG91\n"); 
        println("Home");
        delay(delay_time);

        break;

      default:
        //////  If more than 2 Serial ports, let user select
        //////        Modified the code by macshout 
        //////                     https://forum.processing.org/two/discussion/7140/how-to-let-the-user-select-com-serial-port-within-a-sketch

        String COMx="", COMlist = "";
        // If more than 2 serial ports.... do something in the future
        for (int j = 0; j < num_serial_ports; ) {
          COMlist += char(j+'a') + " = " + Serial.list()[j];
          if (++j < num_serial_ports) COMlist += ",  ";
        }

        COMx = (String) JOptionPane.showInputDialog(null, 
          "Select COM port", 
          "Select port", 
          JOptionPane.QUESTION_MESSAGE, 
          null, 
          Serial.list(), 
          Serial.list()[0]);

        if (COMx == null) exit();
        if (COMx.isEmpty()) exit();
        num_serial_ports = int(COMx.toLowerCase().charAt(0) - 'a') + 1;


        myPort = new Serial(this, COMx, 115200); // change baud rate to your liking
        myPort.bufferUntil('\n');
        // Initialize theArm
        myPort.write("M1112\nG91\n"); 
        println("Home");
        delay(delay_time);
        break;
      }
    }
    catch  (Exception e) {
      JOptionPane.showMessageDialog(frame, "Device is not connected to the PC");
      exit();
    }
  }
  /////////  End Serial port setting
}// end setup()



void draw() {
  // GUI

  background(105, 105, 105, 60); 

  noStroke();
  fill(50); 
  rect(0, height*.89, width, height*.9);
  INTERFACES.draw();

  if (toggle_ShowBD.getBooleanValue()) {
    toggle_ShowBD.setColorActive(color(0, 255, 0));
  } else {
    toggle_ShowBD.setColorActive(color(0, 55, 0));
  }

  if (!toggle_One.getBooleanValue()) {
    toggle_One.setColorActive(color(0, 155, 255));
    toggle_One.setLabel("One_stroke");
  } else {
    toggle_One.setColorActive(color(200, 150, 205));
    toggle_One.setLabel("Normal_draw");
  }
  //// 


  switch(RunningFlag) {

  case 0:
    textFont(f);       
    fill(255);
    if (PointData.size()==1 && DrawFlag==0) {  
      textAlign(CENTER);
      text("Calibrate the Arm First.", width*.6, height/2); 
      text("a <-  x  -> d   ", width*.6, height/2+FontSize);
      text("w <-  y  -> s   ", width*.6, height/2+FontSize*2);
      text("f <-  z  -> r   ", width*.6, height/2+FontSize*3);
      text("                ", width*.6, height/2+FontSize*4);
      text("h    for  Home  ", width*.6, height/2+FontSize*6);
    }

    if (mousePressed == true && DrawFlag==1) {

      if (mouseY<(float)height*.88) {//avoid drawing on Button Area

        PVector mouse0 = new PVector(pmouseX, pmouseY, 10); // Record mouse up at z
        PVector mouse1 = new PVector(mouseX, mouseY, 0);
        PointData.add(mouse0);
        PointData.add(mouse1);
      }
    }
    break;

  case 1: // Start move Arm
    println("Now Running at "+PointCount+"/"+PointData.size() );

    if (PointCount>=PointData.size()) { //Draw finished
      RunningFlag=2;
      ArmMove(0, 0, FinishZ, FSpeed); // Pen Up

      Btn_Run.show();
      Btn_BackToCenter.show();
      Btn_Cancel.hide();
      Btn_Pause.hide();
      break;
    }
    if (WaitFlag==1) {  // if arm is still moving, wait incoming event, exit loop 
      println("Arm still moving\n");
      break;
    }
    if (PenStatus==1) {
      ArmMove(0, 0, -1*PenZvalue, 5000); // PenDown
      PenStatus=0;
    }


    PVector move= CalcMove(PointData.get(PointCount-1), PointData.get(PointCount) );

    if (move.x==0&&move.y==0) {  // Skip same points.
      println("Skip "+PointCount+"\n");
    } else { 
      if (toggle_One.getBooleanValue()&&PointData.get(PointCount-1).z==0) { // if not OneStroke
        ArmMove(0, 0, PenZvalue, 5000); // PenUp
        PenStatus=1;
        delay(500);
      }
      //Draw
      ArmMove(move.x, move.y, 0, FSpeed);
    }

    PointCount=PointCount+1;
    break;

  case 2:
    // 
    // End draw 
    // Do something ? save Draw point data to file?
    break;

  case 3:
    //Move Boundary
    if (WaitFlag==1) { //Skip If arm is Busy
      println("Arm Busy");
      break;
    }

    if (BoundaryCount<BoundaryPointS.size()-1) {
      Bposition= BoundaryPointS.get(BoundaryCount+1); //
      BPrePoint= BoundaryPointS.get(BoundaryCount);

      if (BoundaryCount==1) {

        if (DrawBound==0) {
          ArmMove(0, 0, -1*PenZvalue, 5000); // PenDown
          PenStatus=0;
        }
      }
    }
    if (BoundaryCount==BoundaryPointS.size()-1) {
      Bposition= BoundaryPointS.get(1); //
      BPrePoint= BoundaryPointS.get(4);

      BarmZ=0;
    }


    if (BoundaryCount==5) {
      if (DrawBound==0) {
        ArmMove(0, 0, PenZvalue, 5000); // PenUP
        PenStatus=1;
      }
      Bposition= BoundaryPointS.get(0); // Back to Original pen position
      BPrePoint= BoundaryPointS.get(1);
    }


    println("Count "+BoundaryCount+" from :"+BPrePoint+" target :"+Bposition);
    BarmX=((-BPrePoint.x+Bposition.x)*Scale);
    BarmY=((BPrePoint.y-Bposition.y)*Scale);

    if (BarmX==0&&BarmY==0) { 
      println("Skip "+BoundaryCount+"\n");
    } else { 

      ArmMove(BarmX, BarmY, BarmZ, FSpeed);
    }

    if (BoundaryCount>4) {  //End MoveBoundary
      RunningFlag=0;
      Btn_BOD.hide();
      Btn_Run.show();
      Btn_TraceBD.hide();
      Btn_Run.show();
      Btn_CLS.show();
    } else { 
      BoundaryCount+=1;
    }

    break;

  case 4:
    // Pause
    // wait for cancel or resume
    break;
  case 5:
    //  for future feature?
    // 
    break;

  default:
    break;
  }

  if (toggle_ShowBD.getBooleanValue()) {//Draw Boundary
    noFill();
    stroke(10, 200, 55);
    strokeWeight(6); 
    rect(BoundaryPointS.get(1).x, BoundaryPointS.get(1).y, BoundaryPointS.get(3).x-BoundaryPointS.get(1).x, BoundaryPointS.get(3).y-BoundaryPointS.get(1).y);
  } 



  // Draw Points on Screen
  for (int i = 2; i < PointData.size (); i++ ) { // PointData.get(0) is Center of the area so start from 2
    noStroke();
    fill(255);

    if (!toggle_One.getBooleanValue()) { // OneStroke mode
      PVector position=  PointData.get(i);

      stroke(10, 200, 155);
      strokeWeight(1);
      ellipse(position.x, position.y, 15, 15);
      stroke(100, 200, 205);
      strokeWeight(8);
      line(PointData.get(i-1).x, PointData.get(i-1).y, PointData.get(i).x, PointData.get(i).y);
    } else {   // Normal Stroke mode
      PVector PrePosition=  PointData.get(i-1);
      PVector Position=  PointData.get(i);

      if (PrePosition.z>0) { //PenDown
        stroke(10, 100, 55);
        strokeWeight(1); 

        ellipse(Position.x, Position.y, 15, 15);
        strokeWeight(5); 
        stroke(200, 150, 205);
        line(PrePosition.x, PrePosition.y, Position.x, Position.y);
      } else {  //PenUp

        stroke(10, 20, 55);
        strokeWeight(5); 
        line(PrePosition.x, PrePosition.y, Position.x, Position.y);
      }
    }
  }

  //Show Progress bar and accepted Point by arm when Running
  if (RunningFlag==1 || RunningFlag==4) {

    //DrawPoint
    fill(255, 0, 255);
    stroke(100, 20, 25);
    strokeWeight(2);  
    PVector position=  PointData.get(PointCount-1);
    ellipse(position.x, position.y, 25, 25);

    //Draw Progress bar
    fill(100);
    rect(width*.65, height*0.91, width*0.3, height*.06);

    fill(0, 200, 150);
    rect(width*.65, height*0.91, width*0.3*float(PointCount)/ PointData.size(), height*.06);
  }

  if (PointData.size()>1&&RunningFlag==0) {//  Ready to draw by arm
    GetBoundary();

    Btn_Run.show();
    Btn_BOD.show();
    Btn_TraceBD.show();
    Btn_CLS.show();

    toggle_ShowBD.show();
    toggle_One.show();

    Btn_Draw.hide();
  }
}

void keyPressed() {


  if (key == 'g') {   
    myPort.write("M1111\nM1112\nG92 X0 Y0 Z81.2 E0\nG91\n"); 
    println("Recab");
  }
  if (key == 'h') {  

    myPort.write("M1112\nG91\n"); 

    println("Home");
  }


  if (key == 'a') {   
    ArmMove(Inc, 0, 0, FSpeed);
  }
  if (key == 'd') {   
    ArmMove(-1*Inc, 0, 0, FSpeed);
  }
  if (key == 'w') {  
    ArmMove(0, Inc, 0, FSpeed);
  }
  if (key == 's') {   

    ArmMove(0, -1*Inc, 0, FSpeed);
  }
  if (key == 'f') {   
    ArmMove(0, 0, -1*Inc, FSpeed);
  }
  if (key == 'r') {   

    ArmMove(0, 0, Inc, FSpeed);
  }

  if (key == '0') {   
    myPort.write("G92.1\n");
    println(" reset the work coordinate system to machine coordinate system. ");
  }

  if (key == 'b') {   
    RunningFlag=2;

    println("Pause");
  }


  if (key == 'p') {   // Show current point of the head
    myPort.write("M114\n");
  }
  if (key == 'o') { // File Open?
  }

  if (key == 'q') {   // Save File dialog?
  }
}

void GetBoundary() {
  float MaxX=-1*ArmSpan, MaxY=-1*ArmSpan, MinX=ArmSpan, MinY=ArmSpan;
  BoundaryCount=0;
  BoundaryPointS.clear();

  if (PointData.size()>0) {
    for (int i = 0; i<PointData.size(); i++) {
      if (PointData.get(i).x>=MaxX) {
        MaxX=PointData.get (i).x;
      }
      if (PointData.get(i).y>=MaxY) {
        MaxY=PointData.get (i).y;
      }
      if (PointData.get(i).x<=MinX) {
        MinX=PointData.get (i).x;
      }
      if (PointData.get(i).y<=MinY) {
        MinY=PointData.get (i).y;
      }
    }
  }

  BoundaryPointS.add( PointData.get(0)); // Add initial porint for  CheckBoundary starting and returning point
  BoundaryPointS.add(new PVector(MinX, MinY));
  BoundaryPointS.add(new PVector(MaxX, MinY));
  BoundaryPointS.add(new PVector(MaxX, MaxY));
  BoundaryPointS.add(new PVector(MinX, MaxY));
}




PVector CalcMove(PVector fromPoint, PVector ToPoint  ) {

  float armX=((-fromPoint.x+ToPoint.x)*Scale);
  float armY=((fromPoint.y-ToPoint.y)*Scale);

  return new PVector(armX, armY);
}

void ArmMove(float x, float y, float z, int f) {
  mes="G1 X"+str(x)+" Y"+str(y)+" Z"+str(z)+" F"+str(f)+"\n";
  myPort.write(mes);
  println("ArmMove "+mes);
  delay(delay_time);
}


void serialEvent(Serial p) {

  myString = p.readStringUntil(lf); 

  if (mes != null) {
    DecodeSerialEvent(myString);
  }
} 

void DecodeSerialEvent(String mes) {

  println("from Arm :  "+mes);

  // Because the arm moves slow compared to the PC code,
  // we have to wait until arm finish previous command. 
  // Otherwise the new commands will be rejected while its say busy.


  if (mes.indexOf("busy")>0) { 
    println("Arm Busy-------------\n");
    WaitFlag=1;
  } else {
    WaitFlag=0; // arm is ready to accept new command
  }

  if (RunningFlag==1 && mes.indexOf("limit")>0) {  // when arm reach limits, better stop drwaing and recab the arm
    LimitReached+=1;

    if (StopWhenLimit<=LimitReached) {  
      RunningFlag=4;

      int option = JOptionPane.showConfirmDialog(frame, "Continue anyway? or Quit ", 
        "Arm reached XY Limit repeatedly ", JOptionPane.YES_NO_OPTION, 
        JOptionPane.WARNING_MESSAGE);

      if (option == JOptionPane.YES_OPTION) {
        // Resume and Continue  
        RunningFlag=1;
      } else if (option == JOptionPane.NO_OPTION) {
        myPort.write("M1112\nG91\n"); 
        println("Home");
        delay(delay_time);

        JOptionPane.showMessageDialog(frame, "Calibrate Again");
        exit();
      }
    };
  }

  // This feature is not inuse so far. But a method to save certain position of the arm 

  if (mes.indexOf("Count A")>0) { // Get Current (relative) cordination of the Arm After M1114 fired 

    String Buf =mes.substring(0, mes.indexOf("Count A")) ;
    println(Buf);
    if (Buf.indexOf("E:")>0) {
      String[] Res=Buf.split(" ");

      for (String A : Res) {
        print(" Position :"+A);
        println("  Each cordi :    "+A.substring(2, A.length()));
        float theValue=float(A.substring(2, A.length()));
        println("TheValue "+theValue);
      }
      if (FlagNeedStorge==1&& Res.length>0) {
        PointStrage.x=float(Res[0].substring(2, Res[0].length()));
        PointStrage.y=float(Res[1].substring(2, Res[1].length()));
        PointStrage.z=float(Res[2].substring(2, Res[2].length()));
        FlagNeedStorge=0;
      }
    }
  }//// End Get Cordination
}
