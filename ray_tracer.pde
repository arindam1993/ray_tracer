///////////////////////////////////////////////////////////////////////
//
//  Ray Tracing Shell
//
///////////////////////////////////////////////////////////////////////

int screen_width = 300;
int screen_height = 300;

// global matrix values
PMatrix3D global_mat;
float[] gmat = new float[16];  // global matrix values
Scene scene;
// Some initializations for the scene.

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
}

// Press key 1 to 9 and 0 to run different test cases.

void keyPressed() {
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
  
  Material currentMaterial = new DiffuseMaterial(new RGB(1.0,1.0,1.0), new RGB(1.0,1.0,1.0));   
  initZbuffer();
  if (scene != null ) scene.clear();
 
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
      Light lt = new Light(pos,col);
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
      
      scene.addObject(obj);
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
    }
    else if (token[0].equals("write")) {
      // save the current image to a .png file
      
      if(!filename.equals("rect_test.cli")) scene.render();
      save(token[1]);  
    }
  }
}

//  Draw frames.  Should be left empty.
void draw() {
}

// when mouse is pressed, print the cursor location
void mousePressed() {
  println ("mouse: " + mouseX + " " + mouseY);
}