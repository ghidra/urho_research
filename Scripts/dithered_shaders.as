#include "/Scripts/Utilities/Sample.as"

Scene@ scene_;
Node@ cameraNode;
float yaw = 0.0f;
float pitch = 0.0f;

void Start(){
  SampleStart();
  CreateScene();
  CreateInstructions();
  SetupViewport();
  SubscribeToEvents();
}

void CreateScene(){
  //graphics.SetMode(1920/2,1080/2,false,false,true,false,true,4);
  //int width, int height, bool fullscreen, bool borderless, bool resizable, bool vsync, bool tripleBuffer, int multiSample

  scene_ = Scene();

  // Create the Octree component to the scene. This is required before adding any drawable components, or else nothing will
  // show up. The default octree volume will be from (-1000, -1000, -1000) to (1000, 1000, 1000) in world coordinates; it
  // is also legal to place objects outside the volume but their visibility can then not be checked in a hierarchically
  // optimizing manner
  scene_.CreateComponent("Octree");

  // Create a child scene node (at world origin) and a StaticModel component into it. Set the StaticModel to show a simple
  // plane mesh with a "stone" material. Note that naming the scene nodes is optional. Scale the scene node larger
  // (100 x 100 world units)
  Node@ planeNode = scene_.CreateChild("Plane");
  planeNode.scale = Vector3(100.0f, 1.0f, 100.0f);
  StaticModel@ planeObject = planeNode.CreateComponent("StaticModel");
  planeObject.model = cache.GetResource("Model", "Models/Plane.mdl");
  planeObject.material = cache.GetResource("Material", "Materials/research/StoneTiled_dithered.xml");

  // Create a directional light to the world so that we can see something. The light scene node's orientation controls the
  // light direction; we will use the SetDirection() function which calculates the orientation from a forward direction vector.
  // The light will use default settings (white light, no shadows)
  Node@ lightNode = scene_.CreateChild("DirectionalLight");
  lightNode.direction = Vector3(0.6f, -0.5f, 0.8f); // The direction vector does not need to be normalized
  Light@ light = lightNode.CreateComponent("Light");
  light.lightType = LIGHT_DIRECTIONAL;
  light.castShadows = true;
  light.shadowBias = BiasParameters(0.00025f, 0.5f);
  // Set cascade splits at 10, 50 and 200 world units, fade shadows out at 80% of maximum shadow distance
  light.shadowCascade = CascadeParameters(10.0f, 50.0f, 200.0f, 0.0f, 0.8f);

  // Create more StaticModel objects to the scene, randomly positioned, rotated and scaled. For rotation, we construct a
  // quaternion from Euler angles where the Y angle (rotation about the Y axis) is randomized. The mushroom model contains
  // LOD levels, so the StaticModel component will automatically select the LOD level according to the view distance (you'll
  // see the model get simpler as it moves further away). Finally, rendering a large number of the same object with the
  // same material allows instancing to be used, if the GPU supports it. This reduces the amount of CPU work in rendering the
  // scene.
  const uint NUM_OBJECTS = 200;
  for (uint i = 0; i < NUM_OBJECTS; ++i)
  {
    Node@ mushroomNode = scene_.CreateChild("Mushroom");
    mushroomNode.position = Vector3(Random(90.0f) - 45.0f, 0.0f, Random(90.0f) - 45.0f);
    mushroomNode.rotation = Quaternion(0.0f, Random(360.0f), 0.0f);
    mushroomNode.SetScale(0.5f + Random(2.0f));
    StaticModel@ mushroomObject = mushroomNode.CreateComponent("StaticModel");
    mushroomObject.model = cache.GetResource("Model", "Models/Mushroom.mdl");
    Material@ mat = cache.GetResource("Material", "Materials/research/Mushroom_dithered.xml");
    Material@ rmat = mat.Clone();
    Color myCola = Color(Random(1.0f),Random(1.0f),Random(1.0f),1.0f);
    rmat.shaderParameters["ObjectColor"]=Variant(myCola);//single quotes didnt work
    mushroomObject.material = rmat;

    mushroomObject.castShadows = true;
  }

  //-----------------
  //-----------------

  // Create a scene node for the camera, which we will move around
  // The camera will use default settings (1000 far clip distance, 45 degrees FOV, set aspect ratio automatically)
  cameraNode = scene_.CreateChild("Camera");
  cameraNode.CreateComponent("Camera");

  // Set an initial position for the camera scene node above the plane
  cameraNode.position = Vector3(0.0f, 5.0f, 0.0f);
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
  Viewport@ viewport = Viewport(scene_, cameraNode.GetComponent("Camera"));
  XMLFile@ xml = cache.GetResource("XMLFile", "RenderPaths/research/Dithered_quad.xml");
  viewport.SetRenderPath(xml);
  renderer.viewports[0] = viewport;
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

void SubscribeToEvents()
{
  // Subscribe HandleUpdate() function for processing update events
  SubscribeToEvent("Update", "HandleUpdate");
}

void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
  // Take the frame time step, which is stored as a float
  float timeStep = eventData["TimeStep"].GetFloat();

  // Move the camera, scale movement with time step
  MoveCamera(timeStep);
}

// Create XML patch instructions for screen joystick layout specific to this sample app
String patchInstructions = "";
