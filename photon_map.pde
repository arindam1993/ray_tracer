// kD-tree code, eventually for photon mapping
//
// Greg Turk, April 2016

float photon_radius = 8;
/*
int screen_width = 850;
int screen_height = 850;

// debug drawing stuff
int num_photons = 8000;    // number of photons to draw (small number)
float photon_radius = 8;   // drawing of photons

//int num_photons = 400000;   // number of photons to draw (large number)
//float photon_radius = 2;    // drawing of photons

float old_mouseX,old_mouseY;
boolean first_draw = true;

kd_tree photons;

void settings() {
  size (screen_width, screen_height);
}

void setup() {
  int i;
  
  // initialize kd-tree
  photons = new kd_tree();
  
  // create random list of "photons"
  for (i = 0; i < num_photons; i++) {
    float x,y;
    // pick random positions, with variable density in x
    do {
      x = random (0.0, screen_width);
      y = random (0.0, screen_height);
    } while (x > random (0.0, screen_width));
    float z = 0.0;
    Photon p = new Photon (x, y, z);
    photons.add_photon (p);
  }
  
  // build the kd-tree
  photons.build_tree();
  println ("finished building tree");
}

// draw a bunch of points (which are stand-ins for photons)
void draw() {
  
  int num_near = 40;
  boolean fast = false;
  
  // draw all the "photons" in black only once
  if (first_draw) {
    // get ready to draw
    background (255, 255, 255);
    noStroke();
    fill (0, 0, 0);
  
    // draw the initial photons
    photons.draw(photons.root);
    
    first_draw = false;
  }
  
  noStroke();
  
  ArrayList<Photon> plist;
  
  // re-draw the last frame's photons in black
  fill (0, 0, 0);
  plist = photons.find_near ((float) old_mouseX, (float) old_mouseY, 0.0, num_near, 200.0);
  draw_photon_list (plist);
   
  // draw the new near photons in red
  fill (255, 0, 0);
  plist = photons.find_near ((float) mouseX, (float) mouseY, 0.0, num_near, 200.0);
  draw_photon_list (plist);

  // save these mouse positions for next frame
  old_mouseX = mouseX;
  old_mouseY = mouseY;
}

// draw a list of photons
void draw_photon_list(ArrayList<Photon> plist)
{
  for (int i = 0; i < plist.size(); i++) {
    Photon photon = plist.get(i);
    ellipse (photon.pos[0], photon.pos[1], photon_radius, photon_radius);
  }
}*/