#include "Scripts/Utilities/Sample.as"

Viewport@ viewport_;
Window@ window;
bool windowopen;
bool fullscreen;
VariantMap fractaldata;
Array<String> fractaltype;

void Start(){
  //SampleStart();
  fractaltype.Push("MENGERSPONGE");
  fractaltype.Push("SPHERESPONGE");
  fractaltype.Push("MANDELBOX");
  fractaltype.Push("MANDELBULB");

  fractaldata["CamPos"];
  fractaldata["CamRot"];

  fractaldata["Fractal"]             = 0;
  fractaldata["Scale"]               = 2.0f;
  //fractaldata["MaxIterations"]       = 8;
  //fractaldata["StepLimit"]           = 60;
  fractaldata["Power"]               = 8.0f;
  fractaldata["SurfaceDetail"]       = 2.0f;
  fractaldata["SurfaceSmoothness"]   = 0.8f;
  fractaldata["BoundingRadius"]      = 5.0f;
  fractaldata["Offset"]              = Vector3(0.71f,0.66f,0.54f);
  fractaldata["Shift"]               = Vector3();

  fractaldata["ColorIterations"]     = 4;
  fractaldata["Color1"]              = Vector3(1.0f, 1.0f, 1.0f);
  fractaldata["Color1Intensity"]     = 0.45f;
  fractaldata["Color2"]              = Vector3(0.1f, 0.1f, 0.8f);
  fractaldata["Color2Intensity"]     = 0.3f;
  fractaldata["Color3"]              = Vector3(0.8f, 0.5f, 0.1f);
  fractaldata["Color3Intensity"]     = 0.0f;
  fractaldata["Transparent"]         = false;
  fractaldata["Gamma"]               = 1.0f;

  fractaldata["Light"]               = Vector3(-16.0f, 100.0f, -60.0f);
  fractaldata["MyAmbientColor"]      = Vector2(0.5f, 0.3f);
  fractaldata["Background1Color"]    = Vector3(0.2f, 0.2f, 0.8f);
  fractaldata["Background2Color"]    = Vector3();
  fractaldata["InnerglowColor"]      = Vector3(0.2f, 0.2f, 0.8f);
  fractaldata["InnerglowIntensity"]  = 0.0f;
  fractaldata["OuterGlowColor"]      = Vector3(1.0f, 1.0f, 1.0f);
  fractaldata["OuterGlowIntensity"]  = 0.0f;
  fractaldata["Fog"]                 = 0.0f;
  fractaldata["FogFalloff"]          = 0.0f;
  fractaldata["Specularity"]         = 0.8f;
  fractaldata["SpecularExponent"]    = 4.0f;

  fractaldata["AoIntensity"]         = 0.5f;
  fractaldata["AoSpread"]            = 9.0f;
  //fractaldata["AoIterations"]        = 4;

  fractaldata["SphereHoles"]         = 4.0f;
  fractaldata["SphereScale"]         = 1.0f;
  fractaldata["BoxScale"]            = 0.5f;
  fractaldata["BoxFold"]             = 1.0f;
  fractaldata["FudgeFactor"]         = 0.0f;
  fractaldata["JuliaFactor"]         = 0.0f;
  fractaldata["RadiolariaFactor"]    = 0.0f;
  fractaldata["Radiolaria"]          = 0.0f;

  XMLFile@ style = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");// Load XML file containing default UI style sheet
  ui.root.defaultStyle = style;// Set the loaded style as default style
  
  //ToggleParameters();

  CreateScene();
  CreateConsoleAndDebugHud();
  SetupViewport();
  SubscribeToEvents();
  //CreateInstructions();

}

void ToggleParameters(){

  if(windowopen){
    windowopen=false;
    window.Remove();
    input.mouseVisible = false;
    return;
  }

  //get position information
  IntVector2 res = IntVector2(graphics.width,graphics.height);
  res-=IntVector2(384,400);
  int posx = int(res.x/2.0);
  int posy = int(res.y/2.0);
  IntVector2 pos=IntVector2(posx,posy);

  input.mouseVisible = true;

  window = Window();
  ui.root.AddChild(window);

  window.SetMinSize(384, 400);
  window.SetMaxSize(384, 800);
  window.SetPosition(pos.x,pos.y);//
  window.SetLayout(LM_VERTICAL);
  window.movable=true;
  window.name = "Window";

  // Create Window 'titlebar' container
  UIElement@ titleBar = UIElement();
  titleBar.SetMinSize(0, 24);
  titleBar.SetMaxSize(384, 24);
  titleBar.verticalAlignment = VA_TOP;
  titleBar.layoutMode = LM_HORIZONTAL;

  Text@ windowTitle = Text();
  windowTitle.name = "WindowTitle";
  windowTitle.text = "Parameters";

  titleBar.AddChild(windowTitle);

  window.AddChild(titleBar);
  window.SetStyleAuto();
  windowTitle.SetStyleAuto();

  //////NOW FOR ALL THE ACTUAL PARAMETERS
  CreateFractalDropDown(window);

  UIElement@ dial_main = CreateScrollableElement(window,"Fractal");

  CreateSlider(dial_main,"scale","Scale",1,0,-10.0f,10.0f);//
  //CreateSlider(dial_main,"max iterations","MaxIterations",0,0,1.0f,30.0f);//
  CreateSlider(dial_main,"power","Power",1,0,-20.0f,20.0f);//
  CreateSlider(dial_main,"surface detail","SurfaceDetail",1,0,0.1f,2.0f);//0.1,2.0
  CreateSlider(dial_main,"surface smoothness","SurfaceSmoothness",1,0,0.01f,1.0f);//0.01,1.0
  CreateSlider(dial_main,"boundingradius","boundingRadius",1,0,0.1f,150.0);//0.1,150
  CreateSlider(dial_main,"offset x","Offset",3,0,-3.0f,3.0f);//-3,3
  CreateSlider(dial_main,"offset y","Offset",3,1,-3.0f,3.0f);//
  CreateSlider(dial_main,"offset z","Offset",1,2,-3.0f,3.0f);//
  CreateSlider(dial_main,"shift x","Shift",3,0,-3.0f,3.0f);//-3,3
  CreateSlider(dial_main,"shift y","Shift",3,1,-3.0f,3.0f);//
  CreateSlider(dial_main,"shift z","Shift",3,2,-3.0f,3.0f);//

  UIElement@ dial_extra = CreateScrollableElement(window,"Extra");
  
  CreateSlider(dial_extra,"sphere holes","SphereHoles",1,0,3.0f,6.0f);//
  CreateSlider(dial_extra,"sphere scale","SphereScale",1,0,0.01f,3.0f);//
  CreateSlider(dial_extra,"box scale","BoxScale",1,0,0.01f,3.0f);//
  CreateSlider(dial_extra,"box fold","BoxFold",1,0,0.01f,3.0f);//
  CreateSlider(dial_extra,"fudge factor","FudgeFactor",1,0,0.0f,100.0f);//
  CreateSlider(dial_extra,"julia factor","JuliaFactor",1,0,0.0f,1.0f);//
  CreateSlider(dial_extra,"radiolaria factor","RadiolariaFactor",1,0,-2.0f,2.0f);//
  CreateSlider(dial_extra,"radiolaria","Radiolaria",1,0,0.0f,1.0f);//

  UIElement@ dial_color = CreateScrollableElement(window,"Color");

  CreateSlider(dial_color,"color iterations","ColorIterations",0,0,0.0f,30.0f);
  CreateSlider(dial_color,"color 1 r","Color1",3);
  CreateSlider(dial_color,"color 1 g","Color1",3,1);
  CreateSlider(dial_color,"color 1 b","Color1",3,2);
  CreateSlider(dial_color,"color 1 intensity","Color1Intensity",1,0,0.0f,3.0f);
  CreateSlider(dial_color,"color 2 r","Color2",3);
  CreateSlider(dial_color,"color 2 g","Color2",3,1);
  CreateSlider(dial_color,"color 2 b","Color2",3,2);
  CreateSlider(dial_color,"color 2 intensity","Color2Intensity",1,0,0.0f,3.0f);
  CreateSlider(dial_color,"color 3 r","Color3",3);
  CreateSlider(dial_color,"color 3 g","Color3",3,1);
  CreateSlider(dial_color,"color 3 b","Color3",3,2);
  CreateSlider(dial_color,"color 3 intensity","Color3Intensity",1,0,0.0f,3.0f);
  //CreateSlider(dial_color,"color iterations",f_coloriterations,0.0f,30.0f);//0,30
  CreateSlider(dial_color,"gamma","Gamma",1,0,0.1f,2.0f);

  UIElement@ dial_shad = CreateScrollableElement(window,"Shading");

  CreateSlider(dial_shad,"light x","Light",3,0,-300.0f,300.0f);
  CreateSlider(dial_shad,"light y","Light",3,1,-300.0f,300.0f);
  CreateSlider(dial_shad,"light z","Light",3,2,-300.0f,300.0f);
  CreateSlider(dial_shad,"ambient light","MyAmbientColor",2,0,0.0f,1.0f);
  CreateSlider(dial_shad,"ambient bg","MyAmbientColor",2,1,0.0f,1.0f);
  CreateSlider(dial_shad,"bg 1 r","Background1Color",3);
  CreateSlider(dial_shad,"bg 1 g","Background1Color",3,1);
  CreateSlider(dial_shad,"bg 1 b","Background1Color",3,2);
  CreateSlider(dial_shad,"bg 2 r","Background2Color",3);
  CreateSlider(dial_shad,"bg 2 g","Background2Color",3,1);
  CreateSlider(dial_shad,"bg 2 b","Background2Color",3,2);
  CreateSlider(dial_shad,"inner glow r","InnerGlowColor",3);
  CreateSlider(dial_shad,"inner glow g","InnerGlowColor",3,1);
  CreateSlider(dial_shad,"inner glow b","InnerGlowColor",3,2);
  CreateSlider(dial_shad,"inner glow intensity","InnerGlowIntensity");
  CreateSlider(dial_shad,"outer glow r","OuterGlowColor",3);
  CreateSlider(dial_shad,"outer glow g","OuterGlowColor",3,1);
  CreateSlider(dial_shad,"outer glow b","OuterGlowColor",3,2);
  CreateSlider(dial_shad,"outer glow intensity","OuterGlowIntensity");
  CreateSlider(dial_shad,"fog","Fog");
  CreateSlider(dial_shad,"fog falloff","FogFalloff");
  CreateSlider(dial_shad,"specularity","Specularity");
  CreateSlider(dial_shad,"specular exponent","SpecularExponent");
  CreateSlider(dial_shad,"ao intensity","AoIntensity");
  CreateSlider(dial_shad,"ao spread","AoSpread",1,0,0.0f,20.0f);
  CreateSlider(dial_shad,"ao iterations","AoIterations",0,0,1.0f,30.0f);

  windowopen=true;
}

UIElement@ CreateScrollableElement(UIElement@ parent,const String& label){
  //make the whole container
  UIElement@ container = UIElement();
  parent.AddChild(container);
  container.size = IntVector2(380, 118);
  container.SetLayout(LM_VERTICAL);
  //make a title bar for it
  UIElement@ titlebar = UIElement();
  container.AddChild(titlebar);
  titlebar.SetMinSize(0, 18);
  titlebar.SetMaxSize(384, 18);
  titlebar.verticalAlignment = VA_TOP;
  titlebar.layoutMode = LM_HORIZONTAL;
  // Create the Window title Text
  Text@ titletext = Text();
  titlebar.AddChild(titletext);
  titletext.SetMinSize(0, 18);
  titletext.SetMaxSize(380, 18);
  titletext.SetStyleAuto();
  titletext.text = label;

  ScrollView@ view = ScrollView();
  container.AddChild(view);
  view.size = IntVector2(380, 100);
  view.SetStyleAuto();
  
  view.SetMaxSize(380,100);
  view.SetStyleAuto();
  view.SetScrollBarsVisible(false,true);
  
  UIElement@ content = UIElement();
  view.contentElement = content;
  content.SetLayout(LM_VERTICAL);

  return content;
}

void CreateSlider(UIElement@ parent,const String& label, String target, const uint type=1, const uint index=0, float min=0.0f, float max = 1.0f){
  //convert variant value to number
  float val = 1.0f;
  //Variant vtarget = fractaldata[target];
  switch(type){
    case 0:
      val = float(fractaldata[target].GetInt());
      break;
    case 1:
      val = fractaldata[target].GetFloat();
      break;
    case 2:
      if(index==0){
        val = fractaldata[target].GetVector2().x;
      }else{
        val = fractaldata[target].GetVector2().y;
      }
      break;
    case 3:
      if(index==0){
        val = fractaldata[target].GetVector3().x;
      }else if(index==1){
        val = fractaldata[target].GetVector3().y;
      }else{
        val = fractaldata[target].GetVector3().z;
      }
      break;
  }
  //-----
  UIElement@ slidercontainer = UIElement();
  parent.AddChild(slidercontainer);
  slidercontainer.SetStyleAuto();
  slidercontainer.SetLayout(LM_HORIZONTAL);
  slidercontainer.size = IntVector2(367, 16);

  Text@ text = Text();
  slidercontainer.AddChild(text);
  text.SetStyleAuto();
  text.text=label;
  text.SetMinSize(100, 16);
  text.SetMaxSize(100, 16);

  Slider@ slider = Slider();
  slidercontainer.AddChild(slider);
  slider.SetStyleAuto();
  slider.name = label;
  slider.range = 1.0f;
  slider.value = fit(val,min,max);
  slider.SetMaxSize(2147483647, 16);
  slider.SetMinSize(200, 8);

  Text@ valuetext = Text();
  slidercontainer.AddChild(valuetext);
  valuetext.SetStyleAuto();
  valuetext.textAlignment=HA_RIGHT;
  valuetext.name="value_"+label;
  valuetext.text=String(val);
  valuetext.SetMinSize(50, 16);
  valuetext.SetMaxSize(50, 16);

  //set the vars to hold onto to use in the handler
  slider.vars["var"]=target;//the variable that we need to update
  slider.vars["min"]=min;
  slider.vars["max"]=max;
  slider.vars["input"]=label;
  slider.vars["type"]=type;//the type of variable 0=uint, 1=float, 2=vector2,3=vector3
  slider.vars["index"]=index;//index of element incase a vector

  SubscribeToEvent(slider, "sliderChanged", "HandleSliderChanged");
}
void HandleSliderChanged(StringHash eventType, VariantMap& eventData){
  RenderPathCommand pt = renderer.viewports[0].renderPath.commands[2];

  Slider@ slider = GetEventSender();
  float newvalue = fit(eventData["Value"].GetFloat(),0.0f,1.0f,slider.vars["min"].GetFloat(),slider.vars["max"].GetFloat());
  Text@ value = window.GetChild("value_"+slider.vars["input"].GetString(), true);
  //now handle the value
  uint t = slider.vars["type"].GetInt();
  uint i = slider.vars["index"].GetInt();
  String id = slider.vars["var"].GetString();

  switch(t){
    case 0:
      fractaldata[id] = int(newvalue);
      value.text = String(fractaldata[id].GetInt());
      break;
    case 1:
      fractaldata[id] = newvalue;
      value.text = String(fractaldata[id].GetFloat());
      break;
    case 2:
      if(i==0){
        fractaldata[id] = Vector2(newvalue,fractaldata[id].GetVector2().y);
        value.text = String(fractaldata[id].GetVector2().x);
      }else{
        fractaldata[id] = Vector2(fractaldata[id].GetVector2().x, newvalue);
        value.text = String(fractaldata[id].GetVector2().y);
      }
      break;
    case 3:
      if(i==0){
        fractaldata[id] = Vector3(newvalue,fractaldata[id].GetVector3().y,fractaldata[id].GetVector3().z);
        value.text = String(fractaldata[id].GetVector3().x);
      }else if(i==1){
        fractaldata[id] = Vector3(fractaldata[id].GetVector3().x,newvalue,fractaldata[id].GetVector3().z);
        value.text = String(fractaldata[id].GetVector3().y);
      }else{
        fractaldata[id] = Vector3(fractaldata[id].GetVector3().x,fractaldata[id].GetVector3().y,newvalue);
        value.text = String(fractaldata[id].GetVector3().z);
      }
      break;
  }

  pt.shaderParameters[slider.vars["var"].GetString()]=fractaldata[id];
  renderer.viewports[0].renderPath.commands[2] = pt;
}

void CreateFractalDropDown(UIElement@ parent){
  DropDownList@ list = DropDownList();
  parent.AddChild(list);
  list.SetStyleAuto();
  list.SetFixedHeight(16);
  list.resizePopup = true;

  for (uint i = 0; i < fractaltype.length; ++i){
    Text@ text = Text();
    list.AddItem(text);
    text.SetStyleAuto();
    text.text = fractaltype[i];
  }

  SubscribeToEvent(list, "ItemSelected", "SetFractalTypeHandler");
}
void SetFractalTypeHandler(StringHash eventType, VariantMap& eventData){
  int index = eventData["Selection"].GetInt();
  fractaldata["Fractal"]=index;
  SetFractalType(index);
}
void SetFractalType(int index){
  RenderPathCommand rpc = renderer.viewports[0].renderPath.commands[2];
  rpc.pixelShaderDefines=String(fractaltype[index]);
  renderer.viewports[0].renderPath.RemoveCommand(2);
  renderer.viewports[0].renderPath.AddCommand(rpc);
}

void CreateInstructions(){
  // Construct new Text object, set string to display and font to use
  Text@ instructionText = ui.root.CreateChild("Text");
  instructionText.text = "P to toggle parameter pane\nF to toggle fullscreen\nF1-F10 to bookmark\n1-0 to load bookmark";
  instructionText.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 15);

  // Position the text relative to the screen center
  instructionText.horizontalAlignment = HA_CENTER;
  instructionText.verticalAlignment = VA_CENTER;
  instructionText.SetPosition(0, ui.root.height / 4);
}
//-------------------

void CreateScene(){

  scene_ = Scene();
  scene_.CreateComponent("Octree");

  Node@ lightNode = scene_.CreateChild("DirectionalLight");
  lightNode.direction = Vector3(0.6f, -0.5f, 0.8f); // The direction vector does not need to be normalized
  Light@ light = lightNode.CreateComponent("Light");
  light.lightType = LIGHT_DIRECTIONAL;
  light.castShadows = true;
  light.shadowBias = BiasParameters(0.00025f, 0.5f);
  light.shadowCascade = CascadeParameters(10.0f, 50.0f, 200.0f, 0.0f, 0.8f);

  cameraNode = scene_.CreateChild("Camera");
  cameraNode.CreateComponent("Camera");
  cameraNode.position = Vector3(0.0f, 0.0f, -2.5f);
}

void SetupViewport(){
  viewport_ = Viewport(scene_, cameraNode.GetComponent("Camera"));
  //XMLFile@ xml = cache.GetResource("XMLFile", "RenderPaths/Fractal.xml");
  XMLFile@ xml = cache.GetResource("XMLFile", "RenderPaths/Fractal_LBM.xml");
  viewport_.SetRenderPath(xml);
  renderer.viewports[0] = viewport_;

  fullscreen=true;//this toggles it to be small at first
  ToggleFullscreen();
  //graphics.SetMode(1280,720,false,true,false,false,false,1);
}

void ToggleFullscreen(){
  IntVector2 res = graphics.desktopResolution;
  if(fullscreen){
    
    //res-=IntVector2(1280,720);
    //make sure that haf is divisibe by tw to have an even number
    int hx = int(res.x/2.0);
    int hy = int(res.y/2.0);
    hx=(hx%2!=0)?hx+1:hx;
    hy=(hy%2!=0)?hy+1:hy;

    if(hx<720 || hy<400){
      hx=720;
      hy=400;
    }

    IntVector2 half = IntVector2(hx,hy);

    IntVector2 resh=res-half;
    int posx = int(resh.x/2.0);
    int posy = int(resh.y/2.0);
    IntVector2 pos=IntVector2(posx,posy);

    graphics.SetMode(hx,hy,false,true,false,false,false,false,1);
    graphics.SetWindowPosition(pos.x,pos.y);

    fullscreen=false;
  }else{
    graphics.SetMode(res.x,res.y,false,true,false,false,false,false,1);
    graphics.SetWindowPosition(0,0);

    fullscreen=true;
  }
}

void MoveCamera(float timeStep){
  // Do not move if the UI has a focused element (the console)
  //if (ui.focusElement !is null || windowopen)
  if (windowopen)
    return;

  // Movement speed as world units per second
  float MOVE_SPEED = 20.0f;
  if(input.keyDown[KEY_SHIFT])
    MOVE_SPEED*=0.1;
  if(input.keyDown[KEY_CTRL])
    MOVE_SPEED*=0.1;
  if(input.keyDown[KEY_ALT])
    MOVE_SPEED*=0.1;
  // Mouse sensitivity as degrees per pixel
  const float MOUSE_SENSITIVITY = 0.1f;

  // Use this frame's mouse motion to adjust camera node yaw and pitch. Clamp the pitch between -90 and 90 degrees
  IntVector2 mouseMove = input.mouseMove;
  yaw += MOUSE_SENSITIVITY * mouseMove.x;
  pitch += MOUSE_SENSITIVITY * mouseMove.y;
  pitch = Clamp(pitch, -90.0f, 90.0f);

  // Construct new orientation for the camera scene node from yaw and pitch. Roll is fixed to zero
  cameraNode.rotation = Quaternion(pitch, yaw, 0.0f);

  // Read WASD keys and move the camera scene node to the corresponding direction if they are pressed
  // Use the Translate() function (default local space) to move relative to the node's orientation.
  if (input.keyDown['W'])
    cameraNode.Translate(Vector3(0.0f, 0.0f, 0.25f) * MOVE_SPEED * timeStep);
  if (input.keyDown['S'])
    cameraNode.Translate(Vector3(0.0f, 0.0f, -0.25f) * MOVE_SPEED * timeStep);
  if (input.keyDown['A'])
    cameraNode.Translate(Vector3(-0.25f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
  if (input.keyDown['D'])
    cameraNode.Translate(Vector3(0.25f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
}

void SubscribeToEvents(){
  SubscribeToEvent("Update", "HandleUpdate");
  SubscribeToEvent("KeyDown", "myHandleKeyDown");
}
void myHandleKeyDown(StringHash eventType, VariantMap& eventData){
  int key = eventData["Key"].GetInt();
  if (key == KEY_P)
    ToggleParameters();
  else if (key == KEY_F)
    ToggleFullscreen();
  else if (key == KEY_ESC) 
    engine.Exit();
  else if (key == KEY_F1) 
    SaveParameters(1);
  else if (key == KEY_F2) 
    SaveParameters(2);
  else if (key == KEY_F3) 
    SaveParameters(3);
  else if (key == KEY_F4) 
    SaveParameters(4);
  else if (key == KEY_F5) 
    SaveParameters(5);
  else if (key == KEY_F6) 
    SaveParameters(6);
  else if (key == KEY_F7) 
    SaveParameters(7);
  else if (key == KEY_F8) 
    SaveParameters(8);
  else if (key == KEY_F9) 
    SaveParameters(9);
  else if (key == KEY_F10) 
    SaveParameters(0);
  else if (key == KEY_1) 
    LoadParameters(1);
  else if (key == KEY_2) 
    LoadParameters(2);
  else if (key == KEY_3) 
    LoadParameters(3);
  else if (key == KEY_4) 
    LoadParameters(4);
  else if (key == KEY_5) 
    LoadParameters(5);
  else if (key == KEY_6) 
    LoadParameters(6);
  else if (key == KEY_7) 
    LoadParameters(7);
  else if (key == KEY_8) 
    LoadParameters(8);
  else if (key == KEY_9) 
    LoadParameters(9);
  else if (key == KEY_0) 
    LoadParameters(0);
  else if (key == KEY_M)
    {
        if (debugHud.mode == 0 || (debugHud.mode & DEBUGHUD_SHOW_MEMORY) > 0)
            debugHud.mode = DEBUGHUD_SHOW_STATS | DEBUGHUD_SHOW_MODE | DEBUGHUD_SHOW_PROFILER;
        else
            debugHud.mode = 0;
    }
    else if (key == KEY_N)
    {
        if (debugHud.mode == 0 || (debugHud.mode & DEBUGHUD_SHOW_PROFILER) > 0)
            debugHud.mode = DEBUGHUD_SHOW_STATS | DEBUGHUD_SHOW_MODE | DEBUGHUD_SHOW_MEMORY;
        else
            debugHud.mode = 0;
    }
}
void HandleUpdate(StringHash eventType, VariantMap& eventData){
  float timeStep = eventData["TimeStep"].GetFloat(); // Take the frame time step, which is stored as a float
  MoveCamera(timeStep);// Move the camera, scale movement with time step

  //set the shader parameters in the renderpath to the camera values it needs
  Quaternion rot = cameraNode.rotation;
  const float pitch = rot.pitch+0.0;
  float yaw = rot.yaw;
  float roll = rot.roll;

  RenderPathCommand pt = renderer.viewports[0].renderPath.commands[2];
  pt.shaderParameters["CameraPitch"]=Variant(pitch);
  pt.shaderParameters["CameraYaw"]=Variant(yaw);
  pt.shaderParameters["CameraRoll"]=Variant(roll);
  renderer.viewports[0].renderPath.commands[2] = pt;
}
// Create XML patch instructions for screen joystick layout specific to this sample app
String patchInstructions = "";
//--------------

//-------------SAVE
void SaveParameters(const uint id=0){
  //Print("Trying to save a file");
  String filename = "fractal_settings/s"+String(id)+".ini";
  File file(filename, FILE_WRITE);
  //number 1 get camear info
  //Print(String(file.open));
  fractaldata["CamPos"]=cameraNode.worldPosition;
  fractaldata["CamRot"]=cameraNode.rotation;
  file.WriteVariantMap(fractaldata);//writes it all bianary i guess

  file.Close();
}
void LoadParameters(const uint id=0){
  String filename = "fractal_settings/s"+String(id)+".ini";
  File file(filename, FILE_READ);
  VariantMap vm = file.ReadVariantMap();
  bool wasopen=false;

  if(windowopen){
    wasopen=true;
    ToggleParameters();
  }


  //temporary test of new elemts that wenrent there when making intial bookmarks
  if(!vm.Contains("SphereHoles"))vm["SphereHoles"]=4.0f;
  if(!vm.Contains("SphereScale"))vm["SphereScale"]=1.0f;
  if(!vm.Contains("BoxScale"))vm["BoxScale"]=0.5f;
  if(!vm.Contains("BoxFold"))vm["BoxFold"]=1.0f;
  if(!vm.Contains("FudgeFactor"))vm["FudgeFactor"]=0.0f;
  if(!vm.Contains("JuliaFactor"))vm["JuliaFactor"]=0.0f;
  if(!vm.Contains("RadiolariaFactor"))vm["RadiolariaFactor"]=0.0f;
  if(!vm.Contains("Radiolaria"))vm["Radiolaria"]=0.0f;

  fractaldata = vm;

  RenderPathCommand pt = renderer.viewports[0].renderPath.commands[2];

  pt.shaderParameters["Fractal"]             = vm["Fractal"];

  pt.shaderParameters["Scale"]               = vm["Scale"];
  pt.shaderParameters["Power"]               = vm["Power"];
  pt.shaderParameters["SurfaceDetail"]       = vm["SurfaceDetail"];
  pt.shaderParameters["SurfaceSmoothness"]   = vm["SurfaceSmoothness"];
  pt.shaderParameters["BoundingRadius"]      = vm["BoundingRadius"];
  pt.shaderParameters["Offset"]              = vm["Offset"];
  pt.shaderParameters["Shift"]               = vm["Shift"];

  pt.shaderParameters["ColorIterations"]     = vm["ColorIterations"];
  pt.shaderParameters["Color1"]              = vm["Color1"];
  pt.shaderParameters["Color1Intensity"]     = vm["Color1Intensity"];
  pt.shaderParameters["Color2"]              = vm["Color2"];
  pt.shaderParameters["Color2Intensity"]     = vm["Color2Intensity"];
  pt.shaderParameters["Color3"]              = vm["Color3"];
  pt.shaderParameters["Color3Intensity"]     = vm["Color3Intensity"];
  //fractaldata["Transparent"]         = vm["Transparent"];
  pt.shaderParameters["Gamma"]               = vm["Gamma"];

  pt.shaderParameters["Light"]               = vm["Light"];
  pt.shaderParameters["MyAmbientColor"]      = vm["MyAmbientColor"];
  pt.shaderParameters["Background1Color"]    = vm["Background1Color"];
  pt.shaderParameters["Background2Color"]    = vm["Background2Color"];
  pt.shaderParameters["InnerglowColor"]      = vm["InnerglowColor"];
  pt.shaderParameters["InnerglowIntensity"]  = vm["InnerglowIntensity"];
  pt.shaderParameters["OuterGlowColor"]      = vm["OuterGlowColor"];
  pt.shaderParameters["OuterGlowIntensity"]  = vm["OuterGlowIntensity"];
  pt.shaderParameters["Fog"]                 = vm["Fog"];
  pt.shaderParameters["FogFalloff"]          = vm["FogFalloff"];
  pt.shaderParameters["Specularity"]         = vm["Specularity"];
  pt.shaderParameters["SpecularExponent"]    = vm["SpecularExponent"];

  pt.shaderParameters["AoIntensity"]         = vm["AoIntensity"];
  pt.shaderParameters["AoSpread"]            = vm["AoSpread"];

  pt.shaderParameters["SphereHoles"]         = vm["SphereHoles"];
  pt.shaderParameters["SphereScale"]         = vm["SphereScale"];
  pt.shaderParameters["BoxScale"]            = vm["BoxScale"];
  pt.shaderParameters["BoxFold"]             = vm["BoxFold"];
  pt.shaderParameters["FudgeFactor"]         = vm["FudgeFactor"];
  pt.shaderParameters["JuliaFactor"]         = vm["JuliaFactor"];
  pt.shaderParameters["RadiolariaFactor"]    = vm["RadiolariaFactor"];
  pt.shaderParameters["Radiolaria"]          = vm["Radiolaria"];

  cameraNode.worldPosition = vm["CamPos"].GetVector3();
  Quaternion rot = vm["CamRot"].GetQuaternion();
  pitch = rot.pitch+0.0;
  yaw = rot.yaw;

  renderer.viewports[0].renderPath.commands[2] = pt;

  SetFractalType(vm["Fractal"].GetInt());

  if(wasopen)
    ToggleParameters();
}



float fit(const float v, const float l1, const float h1, const float l2=0.0f,const float h2=1.0f){
  return Clamp( l2 + (v - l1) * (h2 - l2) / (h1 - l1), l2,h2);
}
