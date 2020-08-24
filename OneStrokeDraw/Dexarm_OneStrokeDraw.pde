import processing.serial.*;
import java.util.*;
import controlP5.*;


/////////////////
String myArmPort="COM3";


int sizeW = 1500  ; // Screen size
int sizeH = 1500;
Float ArmSpan=150.0; // Range of the arm move 
int FSpeed=5000;
int delay_time=500; 

///////////////////


Serial myPort;

int lf = 10;    // LineFSpeed in ASCII
String myString = null;
String s = "";


ArrayList<PVector>PointData  = new ArrayList<PVector>();
ArrayList<PVector>BoundaryPointS  = new ArrayList<PVector>();
int BoundaryCount=0;

PVector PointStrage= new PVector(0, 0, 0);
int FlagNeedStorge=0;

int PointCount=0;
int RunningFlag=0;
int WaitFlag=0;
int DrawFlag=0;
int PenStatus=0;
int DrawBound=0;



PFont f;
float Inc=10;

Float Scale;

PVector Bposition;
PVector BPrePoint;
float BarmX, BarmY, BarmZ;


//Declare our various CP5 objects & variables
ControlP5 INTERFACES;


void settings() {
  size(sizeW, sizeH);
}

void setup() {

  Scale=ArmSpan/(float(width));

  for (int i = 0; i < Serial.list ().length; i++) {
    println (Serial.list ()[i]);
  }

  myPort = new Serial(this, myArmPort, 115200);
  GUI_init();

  //PointStrage= new PVector(0, 0, 0);
  // Initialize theArm
  myPort.write("M1112\nG91\n"); 
  println("Home");
  delay(delay_time);

  PointData.add(new PVector(width*.5, width*.5));// Set Center for reference point
}


void draw() {
  background(105, 105, 105, 60); 

  noStroke();
  fill(50); 
  rect(0, height*.89, width, height*.9);
  INTERFACES.draw();
  while (myPort.available() > 0) {
    myString = myPort.readStringUntil(lf);
    if (myString != null) {
      println("from Arm :  "+myString);


      if (myString.indexOf("busy")>0) {
        println("Arm Busy-------------\n");
        // Because the arm move slow compare to PC, we have to wait until arm finish previous command.

        WaitFlag=1;
        println("wait on\n");
      } else {
        WaitFlag=0;
      }

      if (myString.indexOf("limit")>0) {  //Do something when arm reach the boundary of its area.
        println(" Limit !? ----Busy-------------");
      }

      if (myString.indexOf("Count A")>0) { // Get Current (relative) cordination of theArm After M1114 fired 

        String Buf =myString.substring(0, myString.indexOf("Count A")) ;
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
      }
    }
  }

  switch(RunningFlag) {

  case 0:
    textFont(f);       
    fill(255);
    if (PointData.size()==1&&DrawFlag==0) {  
      textAlign(CENTER);
      text("Calibrate the Arm First.", width*.6, height/2); 
      text("a <-  x  -> d   ", width*.6, height/2+48);
      text("w <-  y  -> s   ", width*.6, height/2+48+24);
      text("f <-  z  -> r   ", width*.6, height/2+48+24+24);
      text("                ", width*.6, height/2+48+24+48);
      text("h    for  Home   ", width*.6, height/2+48+48+48);
    }

    if (mousePressed == true && DrawFlag==1) {

      if (mouseY<height*.9) { //avoid Button Area
        PVector mouse = new PVector(mouseX, mouseY);
        PointData.add(mouse);
      }
    } 
    break;

  case 1: // Start move Arm
    println("Now Running at "+PointCount+"/"+PointData.size() );

    if (PointCount>=PointData.size()) { //Draw finished
      RunningFlag=2;
      ArmMove(0, 0, 50, FSpeed); // Pen Up
      PenStatus=5;
      Btn_Run.show();
      Btn_BackToCenter.show();
      Btn_Cancel.hide();
      Btn_Pause.hide();
      break;
    }
    if (WaitFlag==1) {  // if arm is still moving, skip for wait 
      println("Arm still moving\n");
      break;
    }
    if (PenStatus==1) {
      ArmMove(0, 0, -5.5, 5000); // PenDown
      PenStatus=0;
    }

    PVector move= CalcMove(PointData.get(PointCount-1), PointData.get(PointCount) );

    if (move.x==0&&move.y==0) {  // Skip Duplicated points.
      println("Skip "+PointCount);
    } else { 
      //Draw
      ArmMove(move.x, move.y, 0, FSpeed);
    }

    PointCount=PointCount+1;
    break;

  case 2:
    // 
    // End draw do something ? save point to file?
    break;

  case 3:
    //Move Boundary
    if (WaitFlag==1) { //Skip If arm is Busy

      println("Arm Busy");
      break;
    }

    if (BoundaryCount<BoundaryPointS.size()-1) {
      Bposition=   BoundaryPointS.get(BoundaryCount+1); //
      BPrePoint= BoundaryPointS.get(BoundaryCount);

      if (BoundaryCount==1) {

        if (DrawBound==0) {
          ArmMove(0, 0, -5.5, 5000); // PenDown
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
        ArmMove(0, 0, 5.5, 5000); // PenUP
        PenStatus=1;
      }
      Bposition= BoundaryPointS.get(0); // Back to Original pen position
      BPrePoint= BoundaryPointS.get(1);
    }


    println("Count "+BoundaryCount+" from :"+BPrePoint+" target :"+Bposition);
    BarmX=((-BPrePoint.x+Bposition.x)*Scale);
    BarmY=((BPrePoint.y-Bposition.y)*Scale);

    if (BarmX==0&&BarmY==0) { 
      println("Skip "+BoundaryCount);
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
  for (int i = 1; i < PointData.size (); i++ ) {
    noStroke();
    fill(255);
    PVector position=  PointData.get(i);
    ellipse(position.x, position.y, 15, 15);
    stroke(10, 200, 255);
    strokeWeight(4); 
    if ( RunningFlag==2 && i<=PointData.size()-2) {
      line(PointData.get(i).x, PointData.get(i).y, PointData.get(i+1).x, PointData.get(i+1).y);
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

  if (PointData.size()>1&&RunningFlag==0) {// Ready to draw by arm
    Btn_Run.show();
    Btn_BOD.show();
    GetBoundary();
    toggle_ShowBD.show();
    Btn_TraceBD.show();
    Btn_Draw.hide();
    Btn_CLS.show();
  }
}

void keyPressed() {
 

  if (key == 'g') {   

    s= "M1111\nM1112\nG92 X0 Y0 Z81.2 E0\nG91\n";
    myPort.write(s); 
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
    s="G1 X0 Y-"+str(Inc)+" Z0 F2000\n";
    ArmMove(0, -1*Inc, 0, FSpeed);
  }
  if (key == 'f') {   
    ArmMove(0, 0, -1*Inc, FSpeed);
  }
  if (key == 'r') {   
    s="G1 X0 Y0 Z+"+str(Inc)+" F2000\n";
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
}

void StartArmDraw() {

  FlagNeedStorge=1;
  //myPort.write("M114\n"); // Storage calibrated starting point
  //delay(100);

  GetBoundary();
  if (PointData.size()>0) {
    PointCount=0;
    WaitFlag=0;
    RunningFlag=1;

    //PenUp for center to Start Point
    ArmMove(0, 0, 5.5, FSpeed);

    println("Start");
    DrawFlag=0;
    Btn_Draw.hide();
    Btn_Run.hide();
    Btn_BOD.hide();
    Btn_TraceBD.hide();
    Btn_BackToCenter.hide();
    Btn_CLS.hide();
    Btn_Pause.show();

    PVector move= CalcMove(PointData.get(0), PointData.get(1) );
    ArmMove(move.x, move.y, 0, FSpeed);
    //PenDown at Start point
    ArmMove(0, 0, -5.5, FSpeed);

    PointCount=2;
  }
}

void ClearDraw() {
  RunningFlag=0;
  DrawFlag=1;
  PointData.clear();
  PointData.add(new PVector(width*.5, width*.5));// Set Center for reference point
toggle_ShowBD.setValue(false);
}

void DrawBoundary() {
  GetBoundary();
  ArmMove(0, 0, +5.5, 5000); // PenUP
  PenStatus=1;
  RunningFlag=3;
  DrawFlag=0;
  DrawBound=0;
  toggle_ShowBD.setValue(true);
  Btn_Run.hide();
  Btn_CLS.hide();
  Btn_BOD.hide();
  Btn_TraceBD.hide();
}

void TraceBoundary() {
  GetBoundary();
  ArmMove(0, 0, +5.5, 5000); // PenUP
  PenStatus=1;
  RunningFlag=3;
  DrawFlag=0;
  DrawBound=1;
  toggle_ShowBD.setValue(true);
  Btn_Run.hide();
  Btn_CLS.hide();
  Btn_BOD.hide();
  Btn_TraceBD.hide();
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

void ArmMove(float x, float y, float z, int f) {
  s="G1 X"+str(x)+" Y"+str(y)+" Z"+str(z)+" F"+str(f)+"\n";
  myPort.write(s);
  println("ArmMove "+s);
  delay(delay_time);
}

void ArmBackToCenter() { // Prepare for Arm Draw same data again

  // Btn_BackToCenter//
  //  PVector TargetPoint=PointStrage;
  ArmMove(0, 0, -50+5.5, 5000); // PenDown to UP level
  PenStatus=1;


  PVector move= CalcMove(PointData.get(PointCount-1), PointData.get(0) );

  ArmMove(move.x, move.y, 0, FSpeed);
  Btn_BackToCenter.hide();
  //float x, y, z;

  //x=TargetPoint.x;
  //y=TargetPoint.y;
  //z=TargetPoint.z;
  //println("ArmBack? "+x, y, z);
}

void PauseOnAndOff() {

  if (RunningFlag==1) {
    RunningFlag=4;
    Btn_Pause .setColorBackground(color(200, 150, 200)) ;
    Btn_Cancel.show();
  } else {
    RunningFlag=1;
    Btn_Pause .setColorBackground(color(0, 0, 150)) ;
    Btn_Cancel.hide();
  }
}

void CancelDraw() {

  //Force finish draw points and prepare redraw again
  PointCount=PointData.size();
  Btn_Pause .setColorBackground(color(0, 0, 150)) ;
  Btn_Cancel.hide();
  RunningFlag=1;
}

PVector CalcMove(PVector fromPoint, PVector ToPoint  ) {

  float armX=((-fromPoint.x+ToPoint.x)*Scale);
  float armY=((fromPoint.y-ToPoint.y)*Scale);

  return new PVector(armX, armY);
}
