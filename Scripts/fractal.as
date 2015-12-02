#include "Scripts/Utilities/Sample.as"

Viewport@ viewport_;
Window@ window;
bool windowopen;
//bool fullscreen;
VariantMap fractaldata;

void Start(){
  //SampleStart();

  fractaldata["Fractal"]             = 0;
  fractaldata["Scale"]               = 2.0f;
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
  fractaldata["SpecularSxponent"]    = 4.0f;

  fractaldata["AoIntensity"]         = 0.5f;
  fractaldata["AoSpread"]            = 9.0f;

  XMLFile@ style = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");// Load XML file containing default UI style sheet
  ui.root.defaultStyle = style;// Set the loaded style as default style
  
  //ToggleParameters();

  CreateScene();
  //CreateInstructions();
  SetupViewport();
  SubscribeToEvents();
}

void ToggleParameters(){

  if(windowopen){
    windowopen=false;
    window.Remove();
    input.mouseVisible = false;
    return;
  }

  input.mouseVisible = true;

  window = Window();
  ui.root.AddChild(window);

  window.SetMinSize(384, 400);
  window.SetMaxSize(384, 800);
  //window.SetLayout(LM_VERTICAL, 6, IntRect(6, 6, 6, 6));
  window.SetLayout(LM_VERTICAL);
  //window.SetAlignment(HA_CENTER, VA_CENTER);
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

  // Create the Window's close button
  //Button@ buttonClose = Button();
  //buttonClose.name = "CloseButton";

  // Add the controls to the title bar
  titleBar.AddChild(windowTitle);
  //titleBar.AddChild(buttonClose);

  // Add the title bar to the Window
  window.AddChild(titleBar);

  // Apply styles
  window.SetStyleAuto();
  windowTitle.SetStyleAuto();
  //buttonClose.style = "CloseButton";

  //graphics.ToggleFullscreen();

  // Subscribe to buttonClose release (following a 'press') events
  //SubscribeToEvent(buttonClose, "Released", "HandleClosePressed");

  // Subscribe also to all UI mouse clicks just to see where we have clicked
  //SubscribeToEvent("UIMouseClick", "HandleControlClicked");

  //////NOW FOR ALL THE ACTUAL PARAMETERS

  //UIElement@ myslider = CreateSlider("test");
  //CreateSlider(window,"fractal",f_fractal,0,8);

  UIElement@ dial_main = CreateScrollableElement(window,"Fractal");

  CreateSlider(dial_main,"scale","Scale",1,0,-10.0f,10.0f);//
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
  CreateSlider(dial_shad,"ao spread","AoSpread");

  windowopen=true;

}

UIElement@ CreateScrollableElement(UIElement@ parent,const String& label){
  //make the whole container
  UIElement@ container = UIElement();
  parent.AddChild(container);
  container.size = IntVector2(380, 118);
  container.SetLayout(LM_VERTICAL);
  //view.SetStyleAuto();
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
  //titletext.name = label;
  titletext.text = label;
  //

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

void CreateSlider(UIElement@ parent,const String& label, String& target, const uint type=1, const uint index=0, float min=0.0f, float max = 1.0f){
  //convert variant value to number
  float val = 1.0f;
  Variant vtarget = fractaldata[target];
  switch(type){
    case 0:
      val = float(vtarget.GetInt());
      break;
    case 1:
      val = vtarget.GetFloat();
      break;
    case 2:
      if(index==0){
        val = vtarget.GetVector2().x;
      }else{
        val = vtarget.GetVector2().y;
      }
      break;
    case 3:
      if(index==0){
        val = vtarget.GetVector3().x;
      }else if(index==1){
        val = vtarget.GetVector3().y;
      }else{
        val = vtarget.GetVector3().z;
      }
      break;
  }
  //-----
  UIElement@ slidercontainer = UIElement();
  parent.AddChild(slidercontainer);
  slidercontainer.SetStyleAuto();
  slidercontainer.SetLayout(LM_HORIZONTAL);
  //slidercontainer.SetMinSize(100, 16);
  //slidercontainer.SetMaxSize(376, 16);
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
  //slider.SetAlignment(HA_LEFT, VA_TOP);
  slider.name = label;
  slider.range = 1.0f;
  slider.value = fit(val,min,max);
  slider.SetMaxSize(2147483647, 16);
  slider.SetMinSize(200, 8);

  Text@ valuetext = Text();
  slidercontainer.AddChild(valuetext);
  valuetext.SetStyleAuto();
  //valuetext.SetAlignment(HA_RIGHT, VA_TOP);
  valuetext.textAlignment=HA_RIGHT;
  valuetext.name="value_"+label;
  valuetext.text=String(val);
  valuetext.SetMinSize(50, 16);
  valuetext.SetMaxSize(50, 16);

  //set the vars to hold onto to use in the handler
  slider.vars["var"]=target;//the variable that we need to update
  slider.vars["min"]=min;
  slider.vars["max"]=max;
  //slider.vars["input"]=valuetext;
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
  Variant v = fractaldata[slider.vars["var"].GetString()];

  switch(t){
    case 0:
      v = int(newvalue);
      value.text = String(v.GetInt());
      break;
    case 1:
      v = newvalue;
      value.text = String(v.GetFloat());
    case 2:
      if(i==0){
        v = Vector2(newvalue,v.GetVector2().y);
        value.text = String(v.GetVector2().x);
      }else{
        v = Vector2(v.GetVector2().x, newvalue);
        value.text = String(v.GetVector2().y);
      }
    case 3:
      if(i==0){
        v = Vector3(newvalue,v.GetVector3().y,v.GetVector3().z);
        value.text = String(v.GetVector3().x);
      }else if(i==1){
        v = Vector3(v.GetVector3().x,newvalue,v.GetVector3().z);
        value.text = String(v.GetVector3().y);
      }else{
        v = Vector3(v.GetVector3().x,v.GetVector3().y,newvalue);
        value.text = String(v.GetVector3().z);
      }
  }

  pt.shaderParameters[slider.vars["var"].GetString()]=v;
  renderer.viewports[0].renderPath.commands[2] = pt;
}

void HandleControlClicked(StringHash eventType, VariantMap& eventData)
{
    // Get the Text control acting as the Window's title
    Text@ windowTitle = window.GetChild("WindowTitle", true);

    // Get control that was clicked
    UIElement@ clicked = eventData["Element"].GetPtr();

    String name = "...?";
    if (clicked !is null)
    {
        // Get the name of the control that was clicked
        name = clicked.name;
    }

    // Update the Window's title text
    windowTitle.text = "Hello " + name + "!";
}
void CreateInstructions(){
  // Construct new Text object, set string to display and font to use
  Text@ instructionText = ui.root.CreateChild("Text");
  instructionText.text = "Use P to toggle parameter pane.";
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
  XMLFile@ xml = cache.GetResource("XMLFile", "RenderPaths/Fractal.xml");
  viewport_.SetRenderPath(xml);
  renderer.viewports[0] = viewport_;

  graphics.SetMode(1280,720,false,true,false,false,false,1);
}

void ToggleFullscreen(){
  bool isfullscreen = graphics.ToggleFullscreen();
  if(!isfullscreen)
    graphics.SetMode(1280,720,false,true,false,false,false,1);
}

void MoveCamera(float timeStep){
  // Do not move if the UI has a focused element (the console)
  //if (ui.focusElement !is null || windowopen)
  if (windowopen)
    return;

  // Movement speed as world units per second
  const float MOVE_SPEED = 20.0f;
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
float fit(const float v, const float l1, const float h1, const float l2=0.0f,const float h2=1.0f){
  return Clamp( l2 + (v - l1) * (h2 - l2) / (h1 - l1), l2,h2);
}
