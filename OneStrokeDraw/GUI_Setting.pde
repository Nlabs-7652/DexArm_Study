
ControlP5 Btn_10, Btn_1, Btn_01, Btn_Draw, Btn_Run, Btn_BOD,  Btn_BackToCenter, Btn_TraceBD, Btn_Pause, Btn_Cancel;

Toggle toggle_ShowBD;

void GUI_init() {
  INTERFACES = new ControlP5(this);
  INTERFACES.setAutoDraw(false);



  int FontSize=int(32*width/1500);
  f = createFont("Arial", FontSize, true); 
  ControlFont font = new ControlFont(f, FontSize);


  toggle_ShowBD=  INTERFACES.addToggle("toggle_ShowBD")
    .setPosition(20, height*.912)
    .setColorBackground(color(155, 155, 155))
    .setFont(font)
    .setValue(false)
    .setSize((int)(width*0.1), (int)(height*.05)) 
    .setLabel("Show_BD")
    .setMode(ControlP5.SWITCH)
    .hide(); 


   Btn_BackToCenter= new ControlP5(this);
   Btn_BackToCenter.addButton("ArmBackToCenter")
    .setFont(font)
    .setLabel("Prepare_for_ReDraw") 
    .setPosition(width*.2, height*.9)
    .setSize(int(width*.3), int(height*.09))
    .setColorBackground(color(0, 0, 250)) 
    .setColorCaptionLabel(color(255, 255, 0));




  Btn_10 = new ControlP5(this);
  Btn_10.addButton("x10")
    .setFont(font)
    .setLabel("10") 
    .setPosition(width*.1, height*.9)
    .setSize(int(width*.1), int(height*.09))
    .setColorBackground(color(0, 0, 250)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_1 = new ControlP5(this);
  Btn_1.addButton("x1")
    .setLabel("1") 
    .setFont(font)
    .setPosition(width*.2, height*.9)
    .setSize(int(width*.1), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_01 = new ControlP5(this);
  Btn_01.addButton("x01")
    .setLabel("0.1") 
    .setFont(font)
    .setPosition(width*.3, height*.9)
    .setSize(int(width*.1), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_Draw = new ControlP5(this);
  Btn_Draw.addButton("MouseDraw")
    .setLabel("Mouse_Draw") 
    .setFont(font)
    .setPosition(width*.55, height*.9)
    .setSize(int(width*.25), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_BOD = new ControlP5(this);
  Btn_BOD.addButton("DrawBoundary")
    .setLabel("Draw_Boundary") 
    .setFont(font)
    .setPosition(width*.40, height*.9)
    .setSize(int(width*.23), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_TraceBD= new ControlP5(this);
  Btn_TraceBD.addButton("TraceBoundary")
    .setFont(font)
    .setLabel("Trace_Boundary") 
    .setPosition(width*.15, height*.9)
    .setSize(int(width*.23), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));


  Btn_Run = new ControlP5(this);
  Btn_Run.addButton("StartArmDraw")
    .setLabel("Arm_Draw") 
    .setFont(font)
    .setPosition(width*.7, height*.9)
    .setSize(int(width*.2), int(height*.09))
    .setColorBackground(color(100, 100, 250)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_Pause= new ControlP5(this);
  Btn_Pause.addButton("PauseOnAndOff")
    .setLabel("Pause") 
    .setFont(font)
    .setPosition(width*.25, height*.9)
    .setSize(int(width*.15), int(height*.08))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_Cancel=new ControlP5(this);
  Btn_Cancel.addButton("CancelDraw")
    .setLabel("Cancel") 
    .setFont(font)
    .setPosition(width*.4, height*.9)
    .setSize(int(width*.15), int(height*.08))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));



  Btn_Run .hide();
  Btn_BOD.hide();
 Btn_BackToCenter.hide();
  Btn_TraceBD.hide();
  Btn_Cancel.hide();
  Btn_Pause.hide();
}

void x10() {
  Inc=10;
  Btn_01.setColorBackground(color(0, 0, 150)); 
  Btn_1 .setColorBackground(color(0, 0, 150)) ;
  Btn_10 .setColorBackground(color(0, 0, 250)) ;
}
void x1() {
  Inc=1;
  Btn_01.setColorBackground(color(0, 0, 150)); 
  Btn_1 .setColorBackground(color(0, 0, 250)) ;
  Btn_10 .setColorBackground(color(0, 0, 150)) ;
}
void x01() {
  Inc=0.1;
  Btn_01.setColorBackground(color(0, 0, 250)); 
  Btn_1 .setColorBackground(color(0, 0, 150)) ;
  Btn_10 .setColorBackground(color(0, 0, 150)) ;
}
void MouseDraw() {
  DrawFlag=1;
  Btn_01.hide();
  Btn_1 .hide();
  Btn_10 .hide();
}
