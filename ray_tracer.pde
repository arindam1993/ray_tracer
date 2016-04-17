///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
//
///////////////////////////////////////////////////////////////////////

int screen_width = 1000;
int screen_height = 1000;

// global matrix values
PMatrix3D global_mat;
float[] gmat = new float[16];  // global matrix values
Scene scene;
MatrixStack matStack;

int timer;
boolean isListObject = false;
ListObject currentListObject = null;
// Some initializations for the scene.
 SceneObject lastObj = null;
void setup() {
  size (300, 300, P3D);  // use P3D environment so that matrix commands work properly
  noStroke();
  colorMode (RGB, 1.0);
  background (0, 0, 0);
  
  // grab the global matrix values (to use later when drawing pixels)
  PMatrix3D global_mat = (PMatrix3D) getMatrix();
  global_mat.get(gmat);  
  printMatrix();
  //resetMatrix();    // you may want to reset the matrix here

  interpreter("rect_test.cli");
  
  scene = new Scene();
  initZbuffer();
  loadPixels();
  
  matStack = new MatrixStack();
  
  
  //TESTS
  
  getRandomNormalizedSamples(50, new ArrayList<PVector>());
}

// Press key 1 to 9 and 0 to run different test cases.

  Material currentMaterial ;   
  
  SceneObject currentPolygon ;

void keyPressed() {
  lastObj = null;
  currentMaterial = new DiffuseMaterial(new RGB(1.0,1.0,1.0), new RGB(1.0,1.0,1.0));   
  currentPolygon = new Polygon();
  initZbuffer();
  if (scene != null ) scene.clear();
  matStack = new MatrixStack();
  
  switch(key) {
    case '1':  interpreter("t01.cli"); break;
    case '2':  interpreter("t02.cli"); break;
    case '3':  interpreter("t03.cli"); break;
    case '4':  interpreter("t04.cli"); break;
    case '5':  interpreter("t05.cli"); break;
    case '6':  interpreter("t06.cli"); break;
    case '7':  interpreter("t07.cli"); break;
    case '8':  interpreter("t08.cli"); break;
    case '9':  interpreter("t09.cli"); break;
    case '0':  interpreter("t10.cli"); break;
    case 'q':  exit(); break;
  }
}

//  Parser core. It parses the CLI file and processes it based on each 
//  token. Only "color", "rect", and "write" tokens are implemented. 
//  You should start from here and add more functionalities for your
//  ray tracer.
//
//  Note: Function "splitToken()" is only available in processing 1.25 or higher.

void interpreter(String filename) {
  
  String str[] = loadStrings(filename);
  if (str == null) println("Error! Failed to read the file.");


  for (int i=0; i<str.length; i++) {
    
    String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
    if (token.length == 0) continue; // Skip blank line.
    
    if (token[0].equals("fov")) {
      scene.setFOV(float(token[1]));
    }
    else if (token[0].equals("background")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      scene.setBackground(new RGB(r,g,b));
    }
    else if (token[0].equals("point_light")) {
      PVector pos = new PVector(
        float(token[1]),
        float(token[2]),
        float(token[3])
      );
      
      RGB col = new RGB(
        float(token[4]),
        float(token[5]),
        float(token[6])
      );
      Light lt = new PointLight(pos,col);
      scene.addLight(lt);
    }
    else if (token[0].equals("diffuse")) {
      float dr = float(token[1]);
      float dg = float(token[2]);
      float db = float(token[3]);
      
      float ar = float(token[4]);
      float ag = float(token[5]);
      float ab = float(token[6]);
      
      currentMaterial = new DiffuseMaterial(new RGB(dr,dg,db), new RGB(ar,ag,ab));
    } else if (token[0].equals("shiny"))  {
    
      float dr = float(token[1]);
      float dg = float(token[2]);
      float db = float(token[3]);
      
      float ar = float(token[4]);
      float ag = float(token[5]);
      float ab = float(token[6]);
      
      float cr = float(token[7]);
      float cg = float(token[8]);
      float cb = float(token[9]);
      
      float exp = float(token[10]);
      float kRefl = float(token[11]);
      float kTrans = float(token[12]);
      float rIndex = float(token[13]);
      
      currentMaterial = new SpecularMaterial(
          new RGB(dr,dg,db),
          new RGB(ar,ag,ab),
          new RGB(cr,cg,cb),
          exp,
          kRefl,
          kTrans,
          rIndex
        );
      
    }
    else if (token[0].equals("sphere")) {
      PVector pos = new PVector(
        float(token[2]),
        float(token[3]),
        float(token[4])
      );
      
      float R = float(token[1]);
      
      SceneObject obj = new Sphere(pos,R,currentMaterial);
      
      obj.transform(matStack.top());
      
      obj.initBBox();
      
      _handleInstaceAdd(obj);
      //scene.addObject(obj);
    }
    else if (token[0].equals("read")) {  // reads input from another file
      interpreter (token[1]);
    }
    else if (token[0].equals("color")) {  // example command -- not part of ray tracer
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      fill(r, g, b);
    }
    else if (token[0].equals("rect")) {  // example command -- not part of ray tracer
      float x0 = float(token[1]);
      float y0 = float(token[2]);
      float x1 = float(token[3]);
      float y1 = float(token[4]);
      rect(x0, screen_height-y1, x1-x0, y1-y0);
    }else if(token[0].equals("begin")){
      
      currentPolygon = new Polygon();
    }else if(token[0].equals("vertex")){
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);

      ((Polygon)(currentPolygon)).addVertex(new PVector(x,y,z));
    }else if( token[0].equals("end") ){
    
      currentPolygon.setMaterial(currentMaterial);
      
      currentPolygon.transform(matStack.top());
      
      currentPolygon.initBBox();
      
      if( !isListObject ){
        _handleInstaceAdd(currentPolygon);
      }else{
        currentListObject.addObject(currentPolygon);
      }
    }else if (token[0].equals("begin_list")){
      currentListObject = new ListObject();
      isListObject = true;
    }else if ( token[0].equals("end_list")){
      isListObject = false;
      currentListObject.initBBox();
      _handleInstaceAdd(currentListObject);
    }else if ( token[0].equals("end_accel")){
      isListObject = false;
      currentListObject.initBBox();
      currentListObject.accelerate();
      _handleInstaceAdd( currentListObject);
    }
    else if ( token[0].equals("push") ){
      matStack.push();
    }else if ( token[0].equals("pop") ){
      matStack.pop();
    }else if ( token[0].equals("translate") ){
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      matStack.translateTop(x,y,z);
    }else if ( token[0].equals("rotate") ){
      float angle = float(token[1]) * PI/180;
      float x = float(token[2]);
      float y = float(token[3]);
      float z = float(token[4]);
      matStack.rotateTop(angle,x,y,z);
    }else if ( token[0].equals("scale") ){
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      matStack.scaleTop(x,y,z);
    }else if ( token[0].equals("rays_per_pixel")){
      int num = int(token[1]);
      scene.numRays = num;
    }else if (token[0].equals("moving_sphere")){
      float radius = float(token[1]);
      
      float x1 = float(token[2]);
      float y1 = float(token[3]);  
      float z1 = float(token[4]);
      
      float x2 = float(token[5]);
      float y2 = float(token[6]);     
      float z2 = float(token[7]);
      
      SceneObject movSphere =new MovingSphere(
        new PVector(x1,y1,z1),
        new PVector(x2,y2,z2),
        radius,
        currentMaterial
      );
      
      movSphere.transform(matStack.top());
      movSphere.initBBox();
      _handleInstaceAdd(movSphere);
    
    }else if( token[0].equals("box") ){
      float xMin = float(token[1]);
      float yMin = float(token[2]);
      float zMin = float(token[3]);
      float xMax = float(token[4]);
      float yMax = float(token[5]);
      float zMax =  float(token[6]);
      
      SceneObject box = new BoundingBox(xMin,yMin,zMin, xMax, yMax, zMax);
      box.transform(matStack.top());
      box.setMaterial(currentMaterial);
      _handleInstaceAdd(box);
      
    }else if(token[0].equals("named_object")){
      String name = token[1];
      scene.addNamedObj(name, lastObj);
      lastObj = null;
    }else if(token[0].equals("instance")){
      String name = token[1];
      SceneObject obj = new InstancedObject(name);
      scene.addObject(obj);
    }else if( token[0].equals("disk_light") ){
      
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      
      float radius = float(token[4]);
      
      float dx = float(token[5]);
      float dy = float(token[6]);
      float dz = float(token[7]);
      
      float r = float(token[8]);
      float g = float(token[9]);
      float b = float(token[10]);
      
      Light dl = new DiscLight(
        new PVector(x,y,z),
        radius,
        new PVector(dx,dy,dz),
        new RGB(r,g,b)
       );
       
       scene.addLight(dl);
      
    }else if ( token[0].equals("lens")){
      scene.lensRadius = float(token[1]);
      scene.focalDistance = float(token[2]);
      
      println( "Lens: " + scene.lensRadius + " Focal Distance: " + scene.focalDistance );
    }else if(token[0].equals("noise")){
      float scale = float(token[1]);
      Texture nT= new NoiseTexture(scale);
      currentMaterial.setTexture(nT);
      
    }else if(token[0].equals("wood")){
      
      Texture nT= new WoodTexture(new PVector(-0.707,0,0.707), new PVector(0,0,-4));
      currentMaterial.setTexture(nT);
    }else if(token[0].equals("marble")){
      
      Texture nT= new MarbleTexture(new PVector(-0.707,0,0.707), new PVector(0,0,-4));
      currentMaterial.setTexture(nT);
    }else if(token[0].equals("stone")){
      
      Texture nT= new StoneTexture(new PVector(-0.5,-1,-5), new PVector(0.5,1,-3), 100);
      currentMaterial.setTexture(nT);
      
    }else if ( token[0].equals("reflective")){
      float dr = float(token[1]);
      float dg = float(token[2]);
      float db = float(token[3]);
      
      float ar = float(token[4]);
      float ag = float(token[5]);
      float ab = float(token[6]);
      
      
      float exp = 0.0f;
      float kRefl = float(token[7]);
      float kTrans = 0.0f;
      float rIndex = 0.0f;
      
      currentMaterial = new SpecularMaterial(
          new RGB(dr,dg,db),
          new RGB(ar,ag,ab),
          new RGB(0,0,0),
          exp,
          kRefl,
          kTrans,
          rIndex
        );
      
    }else if (token[0].equals("hollow_cylinder")){
      float radius = float(token[1]);
      float x = float(token[2]);
      float z = float(token[3]);
      
      float yMin = float(token[4]);
      float yMax = float(token[5]);
      
      SceneObject cylinder = new OpenCylinder(radius,x,z,yMin,yMax);
      cylinder.setMaterial(currentMaterial);
      cylinder.initBBox();
      scene.addObject(cylinder);
    }
    else if (token[0].equals("write")) {
      // save the current image to a .png file
      if( lastObj != null ) scene.addObject(lastObj);
      if(!filename.equals("rect_test.cli")) scene.render();
      save(token[1]);  
    }   else if (token[0].equals("reset_timer")) {
      timer = millis();
    }
    else if (token[0].equals("print_timer")) {
      int new_timer = millis();
      int diff = new_timer - timer;
      float seconds = diff / 1000.0;
      println ("timer = " + seconds);
    }

  }
}

//  Draw frames.  Should be left empty.
void draw() {
}

// when mouse is pressed, print the cursor location
void mousePressed() {
  println ("mouse: " + mouseX + " " + mouseY);
  Ray ray = new Ray(new PVector(0,0,0), new PVector(0,0,-1));
  ray = getEyeRay(ray,mouseX,mouseY);
  println("Ray: "+ray);
  RayTrace(ray,scene,null,true,0,true);
  
}