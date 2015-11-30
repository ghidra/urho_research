#include "Scripts/Utilities/Sample.as"

//global fractal parameters
uint    f_fractal             = 0;
float   f_scale               = 2.0f;
float   f_power               = 8.0f;
float   f_surfacedetail       = 2.0f;
float   f_surfacesmoothness   = 0.8f;
float   f_boundingradius      = 5.0f;
Vector3 f_offset              = Vector3(0.71f,0.66f,0.54f);
Vector3 f_shift               = Vector3();

uint    f_coloriterations     = 4;
Vector3 f_color1              = Vector3(1.0f, 1.0f, 1.0f);
float   f_color1intensity     = 0.45f;
Vector3 f_color2              = Vector3(0.1f, 0.1f, 0.8f);
float   f_color2intensity     = 0.3f;
Vector3 f_color3              = Vector3(0.8f, 0.5f, 0.1f);
float   f_color3intensity     = 0.0f;
bool    f_transparent         = false;
float   f_gamma               = 1.0f;

Vector3 f_light               = Vector3(-16.0f, 100.0f, -60.0f);
Vector2 f_myambientcolor      = Vector2(0.5f, 0.3f);
Vector3 f_background1color    = Vector3(0.2f, 0.2f, 0.8f);
Vector3 f_background2color    = Vector3();
Vector3 f_innerglowcolor      = Vector3(0.2f, 0.2f, 0.8f);
float   f_innerglowintensity  = 0.0f;
Vector3 f_outerglowcolor      = Vector3(1.0f, 1.0f, 1.0f);
float   f_outerglowintensity  = 0.0f;
float   f_fog                 = 0.0f;
float   f_fogfalloff          = 0.0f;
float   f_specularity         = 0.8f;
float   f_specularexponent    = 4.0f;

float   f_aointensity         = 0.5f;
float   f_aospread            = 9.0f;
//------

Viewport@ viewport_;
Window@ window;

void Start(){
  SampleStart();

  // Load XML file containing default UI style sheet
  XMLFile@ style = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");

  // Set the loaded style as default style
  ui.root.defaultStyle = style;
  
  InitWindow();//window must be the gui
  InitControls();

  CreateScene();
  //CreateInstructions();
  SetupViewport();
  SubscribeToEvents();
}

void InitWindow(){

  input.mouseVisible = true;

  window = Window();
  ui.root.AddChild(window);

  // Set Window size and layout settings
  window.SetMinSize(384, 192);
  //window.SetMaxSize(1280, 720);
  //window.SetLayout(LM_VERTICAL, 6, IntRect(6, 6, 6, 6));
  window.SetLayout(LM_VERTICAL);
  window.SetAlignment(HA_CENTER, VA_CENTER);
  window.name = "Window";

  // Create Window 'titlebar' container
  UIElement@ titleBar = UIElement();
  titleBar.SetMinSize(0, 24);
  titleBar.verticalAlignment = VA_TOP;
  titleBar.layoutMode = LM_HORIZONTAL;

  // Create the Window title Text
  Text@ windowTitle = Text();
  windowTitle.name = "WindowTitle";
  windowTitle.text = "Fractals";

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
  SubscribeToEvent("UIMouseClick", "HandleControlClicked");

  ///make the sliders
  //CreateSlider(window, "", power, 4);
}

void InitControls(){

  //UIElement@ myslider = CreateSlider("test");
  //CreateSlider(window,"fractal",f_fractal,0,8);

  ScrollView@ details = ScrollView();
  window.AddChild(details);
  
  //details.SetLayout(LM_HORIZONTAL);
  details.SetMaxSize(384,100);
  //details.SetAlignment(HA_LEFT,VA_TOP);
  //details.SetMaxSize(2147483647,100);
  details.SetStyleAuto();
  details.SetScrollBarsVisible(false,true);
  UIElement@ sliders = UIElement();
  details.AddChild(sliders);
  sliders.SetLayout(LM_VERTICAL);
  //sliders.SetMaxSize(2147483647,2147483647);
  //details.verticalAlignment = VA_TOP;
  //details.layoutMode = LM_HORIZONTAL;

  CreateSlider(sliders,"scale",f_scale,-10.0f,10.0f);//
  CreateSlider(sliders,"power",f_power,-20.0f,20.0f);//
  CreateSlider(sliders,"surface detail",f_surfacedetail,0.1f,2.0f);//0.1,2.0
  CreateSlider(sliders,"surface smoothness",f_surfacesmoothness,0.01f,1.0f);//0.01,1.0
  CreateSlider(sliders,"boundingradius",f_boundingradius,0.1f,150.0);//0.1,150
  CreateSlider(sliders,"offset x",f_offset.x,-3.0f,3.0f);//-3,3
  CreateSlider(sliders,"offset y",f_offset.y,-3.0f,3.0f);//
  CreateSlider(sliders,"offset z",f_offset.z,-3.0f,3.0f);//
  CreateSlider(sliders,"shift x",f_shift.x,-3.0f,3.0f);//-3,3
  CreateSlider(sliders,"shift y",f_shift.y,-3.0f,3.0f);//
  CreateSlider(sliders,"shift z",f_shift.z,-3.0f,3.0f);//

  //details.SetStyleAuto();
  //details.UpdateLayout();

  /*CreateSlider(window,"color iterations",f_coloriterations,0.0f,30.0f);
  CreateSlider(window,"color 1 r",f_color1.x,0.0f,1.0f);
  CreateSlider(window,"color 1 g",f_color1.y,0.0f,1.0f);
  CreateSlider(window,"color 1 b",f_color1.z,0.0f,1.0f);
  CreateSlider(window,"color 1 intensity",f_color1intensity,0.0f,3.0f);
  CreateSlider(window,"color 2 r",f_color2.x,0.0f,1.0f);
  CreateSlider(window,"color 2 g",f_color2.y,0.0f,1.0f);
  CreateSlider(window,"color 2 b",f_color2.z,0.0f,1.0f);
  CreateSlider(window,"color 2 intensity",f_color2intensity,0.0f,3.0f);
  CreateSlider(window,"color 3 r",f_color3.x,0.0f,1.0f);
  CreateSlider(window,"color 3 g",f_color3.y,0.0f,1.0f);
  CreateSlider(window,"color 3 b",f_color3.z,0.0f,1.0f);
  CreateSlider(window,"color 3 intensity",f_color3intensity,0.0f,3.0f);
  //CreateSlider(window,"color iterations",f_coloriterations,0.0f,30.0f);//0,30
  CreateSlider(window,"gamma",f_gamma,0.1f,2.0f);*/

  /*Vector3 color1              = Vector3(1.0f, 1.0f, 1.0f);
  float   color1intensity     = 0.45f;
  Vector3 color2              = Vector3(0.1f, 0.1f, 0.8f);
  float   color2intensity     = 0.3f;
  Vector3 color3              = Vector3(0.8f, 0.5f, 0.1f);
  float   color3intensity     = 0.0f;
  bool    transparent         = false;
  float   gamma               = 1.0f;

  Vector3 light               = Vector3(-16.0f, 100.0f, -60.0f);
  Vector2 myambientcolor      = Vector2(0.5f, 0.3f);
  Vector3 background1color    = Vector3(0.2f, 0.2f, 0.8f);
  Vector3 background2color    = Vector3();
  Vector3 innerglowcolor      = Vector3(0.2f, 0.2f, 0.8f);
  float   innerglowintensity  = 0.0f;
  Vector3 outerglowcolor      = Vector3(1.0f, 1.0f, 1.0f);
  float   outerglowintensity  = 0.0f;
  float   fog                 = 0.0f;
  float   fogfalloff          = 0.0f;
  float   specularity         = 0.8f;
  float   specularexponent    = 4.0f;

  float aointensity           = 0.5f;
  float aospread              = 9.0f;*/

}

void CreateSlider(UIElement@ parent,const String& label, float target, float min=0.0f, float max = 1.0f){
  /*UIElement@ container = UIElement();
  parent.AddChild(container);
  container.SetStyleAuto();
  container.SetLayout(LM_VERTICAL);
  container.SetMaxSize(2147483647, 16);*/
  //textcontainer.verticalAlignment = VA_TOP;
  //textcontainer.layoutMode = LM_HORIZONTAL;

  UIElement@ slidercontainer = UIElement();
  parent.AddChild(slidercontainer);
  slidercontainer.SetStyleAuto();
  slidercontainer.SetLayout(LM_HORIZONTAL);
  slidercontainer.SetMaxSize(2147483647, 16);

  Text@ text = Text();
  slidercontainer.AddChild(text);
  text.SetStyleAuto();
  //text.SetAlignment(HA_LEFT,VA_TOP);
  text.text=label;
  text.SetMinSize(100, 16);
  text.SetMaxSize(100, 16);

  /*Text@ valuetext = Text();
  container.AddChild(valuetext);
  valuetext.SetStyleAuto();
  //valuetext.SetAlignment(HA_RIGHT, VA_TOP);
  valuetext.text=String(target);
  valuetext.SetMaxSize(2147483647, 16);*/

  Slider@ slider = Slider();
  slidercontainer.AddChild(slider);
  slider.SetStyleAuto();
  //slider.SetAlignment(HA_LEFT, VA_TOP);
  slider.name = label;
  slider.range = 1.0f;
  slider.value = target;
  slider.SetMaxSize(2147483647, 16);
  slider.SetMinSize(200, 8);

  Text@ valuetext = Text();
  slidercontainer.AddChild(valuetext);
  valuetext.SetStyleAuto();
  //valuetext.SetAlignment(HA_RIGHT, VA_TOP);
  valuetext.textAlignment=HA_RIGHT;
  valuetext.text=String(target);
  valuetext.SetMinSize(50, 16);
  valuetext.SetMaxSize(50, 16);

  //set the vars to hold onto to use in the handler
  //slider.vars["var"]=target;
  //slider.vars["var_value"]=valuetext;
  SubscribeToEvent(slider, "sliderChanged", "HandleSliderChanged");
}
void HandleSliderChanged(StringHash eventType, VariantMap& eventData){

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

void SetupViewport()
{
  // Set up a viewport to the Renderer subsystem so that the 3D scene can be seen. We need to define the scene and the camera
  // at minimum. Additionally we could configure the viewport screen size and the rendering path (eg. forward / deferred) to
  // use, but now we just use full screen and default render path configured in the engine command line options
  viewport_ = Viewport(scene_, cameraNode.GetComponent("Camera"));
  //XMLFile@ xml = cache.GetResource("XMLFile", "RenderPaths/research/Dithered_quad.xml");
  XMLFile@ xml = cache.GetResource("XMLFile", "RenderPaths/Fractal.xml");
  viewport_.SetRenderPath(xml);
  renderer.viewports[0] = viewport_;

  //graphics.SetMode(1280,720);//make it render a certain size... doesnt work so well on work computer
  graphics.SetMode(1280,720,false,true,false,false,false,1);
}

void MoveCamera(float timeStep)
{
  // Do not move if the UI has a focused element (the console)
  if (ui.focusElement !is null)
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
  // Subscribe HandleUpdate() function for processing update events
  SubscribeToEvent("Update", "HandleUpdate");
}

void HandleUpdate(StringHash eventType, VariantMap& eventData){
  // Take the frame time step, which is stored as a float
  float timeStep = eventData["TimeStep"].GetFloat();

  // Move the camera, scale movement with time step
  MoveCamera(timeStep);

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
  //Print(viewport_.renderPath.commands[2].shaderParameters[8]);
  //renderer.viewports[0].renderPath.commands[2].shaderParameters["CameraPitch"]=Variant(pitch);
  //viewport_.renderPath.commands[2].shaderParameters["CameraYaw"]=Variant(yaw);
  //viewport_.renderPath.commands[2].shaderParameters["CameraRoll"]=Variant(roll);
}

// Create XML patch instructions for screen joystick layout specific to this sample app
String patchInstructions = "";
