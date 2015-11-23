#include "Scripts/Utilities/Sample.as"

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

void InitControls(){
  /*
  <parameter name="ColorIterations" value="4" />
  <parameter name="Color1" value="1.0 1.0 1.0" />
  <parameter name="Color1Intensity" value="0.45" />
  <parameter name="Color2" value="0.1 0.1 0.8" />
  <parameter name="Color2Intensity" value="0.3" />
  <parameter name="Color3" value="0.8 0.5 0.1" />
  <parameter name="Color3Intensity" value="0.0" />
  <parameter name="Transparent" value="false" />
  <parameter name="Gamma" value="1.0" />
  
  <parameter name="Light" value="-16.0 100.0 -60.0" />
  <parameter name="MyAmbientColor" value="0.5 0.3" />
  <parameter name="Background1Color" value="0.2 0.2 0.8" />
  <parameter name="Background2Color" value="0.0 0.0 0.0" />
  <parameter name="InnerGlowColor" value="0.2 0.2 0.8" />
  <parameter name="InnerGlowIntensity" value="0.0" />
  <parameter name="OuterGlowColor" value="1.0 1.0 1.0" />
  <parameter name="OuterGlowIntensity" value="0.0" />
  <parameter name="Fog" value="0.0" />
  <parameter name="FogFalloff" value="0.0" />
  <parameter name="Specularity" value="0.8" />
  <parameter name="SpecularExponent" value="4.0" />

  <parameter name="AoIntensity" value="0.5" />
  <parameter name="AoSpread" value="9.0" />*/

  Slider@ s_power = Slider();
  s_power.name = "Power";

  Slider@ s_scale = Slider();
  s_scale.name = "Scale";

  Slider@ s_surfacedetail = Slider();
  s_surfacedetail.name = "SurfaceDetail";

  Slider@ s_surfacesmoothness = Slider();
  s_surfacesmoothness.name = "SurfaceSmoothness";

  Slider@ s_boundingradius = Slider();
  s_boundingradius.name = "BoundingRadius";

  Slider@ s_offset = Slider();
  s_offset.name = "Offset";//this is a vector

  Slider@ s_shift = Slider();
  s_shift.name = "Shift";

  

  window.AddChild(s_power);
  window.AddChild(s_scale);
  window.AddChild(s_surfacedetail);
  window.AddChild(s_surfacesmoothness);
  window.AddChild(s_boundingradius);
  window.AddChild(s_offset);
  window.AddChild(s_shift);

  s_power.SetStyleAuto();
  s_scale.SetStyleAuto();
  s_surfacedetail.SetStyleAuto();
  s_surfacesmoothness.SetStyleAuto();
  s_boundingradius.SetStyleAuto();
  s_offset.SetStyleAuto();
  s_shift.SetStyleAuto();
}
void InitWindow(){

  input.mouseVisible = true;

  window = Window();
  ui.root.AddChild(window);

  // Set Window size and layout settings
  window.SetMinSize(384, 192);
  //window.SetMaxSize(1280, 720);
  window.SetLayout(LM_VERTICAL, 6, IntRect(6, 6, 6, 6));
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
}
//void HandleClosePressed(StringHash eventType, VariantMap& eventData)
//{
//    engine.Exit();
//}

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
      cameraNode.Translate(Vector3(0.0f, 0.0f, 1.0f) * MOVE_SPEED * timeStep);
      if (input.keyDown['S'])
        cameraNode.Translate(Vector3(0.0f, 0.0f, -1.0f) * MOVE_SPEED * timeStep);
        if (input.keyDown['A'])
          cameraNode.Translate(Vector3(-1.0f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
          if (input.keyDown['D'])
            cameraNode.Translate(Vector3(1.0f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
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
