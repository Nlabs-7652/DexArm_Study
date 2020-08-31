




ControlP5 Btn_UP, Btn_Dwn, Btn_10, Btn_1, Btn_01;
ControlP5 Btn_Draw, Btn_CLS, Btn_Run, Btn_BOD, Btn_BackToCenter, Btn_TraceBD, Btn_Pause, Btn_Cancel;
ControlP5 Btn_Save, Btn_Load, Btn_GCODE;


Toggle toggle_ShowBD, toggle_One;

void GUI_init() {
  INTERFACES = new ControlP5(this);
  INTERFACES.setAutoDraw(false);




  f = createFont("Arial", FontSize, true); 
  ControlFont font = new ControlFont(f, FontSize);

  // Set Font size for Serial select dialog 
  // Using Java libraly

  UIManager.put("OptionPane.messageFont", new Font("", Font.PLAIN, 10+FontSize));
  UIManager.put("OptionPane.buttonFont", new Font("", Font.PLAIN, FontSize));
  UIManager.put("ComboBox.font", new Font("", Font.BOLD, FontSize)); // It took almost 3hrs to find the key for this (TvT)

  ////////////////////////////////////

  toggle_One = INTERFACES.addToggle("Toggle_One") // OneStroke mode switch
    .setPosition(width*0.83, height*.912)
    .setColorBackground(color(155, 155, 155))
    .setFont(font)
    .setValue(false)
    .setSize((int)(width*0.1), (int)(height*.025)) 
    .setLabel("One_Stroke")
    .setMode(ControlP5.SWITCH)
    .hide(); 

  toggle_ShowBD = INTERFACES.addToggle("toggle_ShowBD") // Show Boundary switch
    .setPosition(20, height*.912)
    .setColorBackground(color(155, 155, 155))
    .setColorForeground(color(0, 0, 255))
    .setColorActive(color(0, 255, 0))
    .setFont(font)
    .setValue(false)
    .setSize((int)(width*0.1), (int)(height*.025)) 
    .setLabel("Show_BD")
    .setMode(ControlP5.SWITCH)
    .hide(); 



  Btn_BackToCenter = new ControlP5(this);
  Btn_BackToCenter.addButton("ArmBackToCenter")
    .setFont(font)
    .setLabel("Prepare_for_Draw_Again") 
    .setPosition(width*.15, height*.9)
    .setSize(int(width*.35), int(height*.09))
    .setColorBackground(color(0, 0, 250)) 
    .setColorCaptionLabel(color(255, 255, 0));


  Btn_UP = new ControlP5(this);
  Btn_UP.addButton("Zup")
    .setFont(font)
    .setLabel("Z Up") 
    .setPosition(width*.2, height*.4)
    .setSize(int(width*.1), int(height*.09))
    .setColorBackground(color(0, 0, 150))
    .setColorActive(color(100, 250, 250))
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_Dwn = new ControlP5(this);
  Btn_Dwn.addButton("Zdwn")
    .setFont(font)
    .setLabel("Z Down") 
    .setPosition(width*.2, height*.6)
    .setSize(int(width*.1), int(height*.09))
    .setColorBackground(color(0, 0, 150))
    .setColorActive(color(100, 250, 250))
    .setColorCaptionLabel(color(255, 255, 0));


  Btn_10 = new ControlP5(this);
  Btn_10.addButton("x10")
    .setFont(font)
    .setLabel("10") 
    .setPosition(width*.1, height*.5)
    .setSize(int(width*.1), int(height*.09))
    .setColorBackground(color(0, 150, 250)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_1 = new ControlP5(this);
  Btn_1.addButton("x1")
    .setLabel("1") 
    .setFont(font)
    .setPosition(width*.2, height*.5)
    .setSize(int(width*.1), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_01 = new ControlP5(this);
  Btn_01.addButton("x01")
    .setLabel("0.1") 
    .setFont(font)
    .setPosition(width*.3, height*.5)
    .setSize(int(width*.1), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_Draw = new ControlP5(this);
  Btn_Draw.addButton("MouseDraw")
    .setLabel("Draw_data") 
    .setFont(font)
    .setPosition(width*.55, height*.9)
    .setSize(int(width*.25), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_BOD = new ControlP5(this);
  Btn_BOD.addButton("DrawBoundary")
    .setLabel("Draw_BD") 
    .setFont(font)
    .setPosition(width*.30, height*.9)
    .setSize(int(width*.15), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_TraceBD= new ControlP5(this);
  Btn_TraceBD.addButton("TraceBoundary")
    .setFont(font)
    .setLabel("Trace_BD") 
    .setPosition(width*.15, height*.9)
    .setSize(int(width*.15), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));


  Btn_Run = new ControlP5(this);
  Btn_Run.addButton("StartArmDraw")
    .setLabel("Arm_Draw") 
    .setFont(font)
    .setPosition(width*.55, height*.9)
    .setSize(int(width*.15), int(height*.09))
    .setColorBackground(color(100, 100, 250)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_Pause = new ControlP5(this);
  Btn_Pause.addButton("PauseOnAndOff")
    .setLabel("Pause") 
    .setFont(font)
    .setPosition(width*.25, height*.9)
    .setSize(int(width*.15), int(height*.08))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_Cancel = new ControlP5(this);
  Btn_Cancel.addButton("CancelDraw")
    .setLabel("Cancel") 
    .setFont(font)
    .setPosition(width*.4, height*.9)
    .setSize(int(width*.15), int(height*.08))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_CLS = new ControlP5(this);
  Btn_CLS.addButton("ClearDraw")
    .setLabel("Clear") 
    .setFont(font)
    .setPosition(width*.45, height*.9)
    .setSize(int(width*.10), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));


  Btn_Load = new ControlP5(this);
  Btn_Load.addButton("fileLoad")
    .setLabel("Load Image Data ") 
    .setFont(font)
    .setPosition(width*.20, height*.9)
    .setSize(int(width*.25), int(height*.09))
    .setColorBackground(color(0, 0, 150)) 
    .setColorCaptionLabel(color(255, 255, 0));


  Btn_Save = new ControlP5(this);
  Btn_Save.addButton("fileSave")
    .setFont(font)
    .setLabel("Save") 
    .setPosition(width*.7, height*.9)
    .setSize(int(width*.12), int(height*.04))
    .setColorBackground(color(0, 0, 150))
    .setColorActive(color(100, 250, 250))
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_GCODE = new ControlP5(this);
  Btn_GCODE.addButton("SaveGCode")
    .setFont(font)
    .setLabel("Save_G") 
    .setPosition(width*.7, height*.95)
    .setSize(int(width*.12), int(height*.04))
    .setColorBackground(color(0, 0, 150))
    .setColorActive(color(100, 250, 250))
    .setColorCaptionLabel(color(255, 255, 0));

  Btn_Run .hide();
  Btn_BOD.hide();
  Btn_BackToCenter.hide();
  Btn_TraceBD.hide();
  Btn_Cancel.hide();
  Btn_Pause.hide();
  Btn_CLS.hide();
  Btn_GCODE.hide();

  Btn_Save.hide();
  Btn_UP.hide();
  Btn_Dwn.hide();
  Btn_10.hide();
  Btn_1.hide();
  Btn_01.hide();
}
