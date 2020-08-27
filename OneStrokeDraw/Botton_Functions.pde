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
  PointData.add(new PVector(width*.5, width*.5));// Set Center for reference point
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
