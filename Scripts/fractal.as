#include "Scripts/Utilities/Sample.as"

Viewport@ viewport_;
Window@ window;

void Start(){
  SampleStart();

  // Load XML file containing default UI style sheet
  XMLFile@ style = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");

  // Set the loaded style as default style
  ui.root.defaultStyle = style;
  InitWindow();
  InitControls();

  CreateScene();
  CreateInstructions();
  SetupViewport();
  SubscribeToEvents();
}

void InitControls(){
  Slider@ slider = Slider();
  slider.name = "Scale";
}
void InitWindow(){
  window = Window();
  ui.root.AddChild(window);

  // Set Window size and layout settings
  window.SetMinSize(384, 192);
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

void CreateInstructions()
{
  // Construct new Text object, set string to display and font to use
  Text@ instructionText = ui.root.CreateChild("Text");
  instructionText.text = "Use WASD keys and mouse to move";
  instructionText.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 15);

  // Position the text relative to the screen center
  instructionText.horizontalAlignment = HA_CENTER;
  instructionText.verticalAlignment = VA_CENTER;
  instructionText.SetPosition(0, ui.root.height / 4);
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
