// kD-tree code, eventually for photon mapping
//
// Greg Turk, April 2016


public class PhotonRadiance{
   
  public RGB power;
  public PVector direction;
  
  public PhotonRadiance(RGB power, PVector direction){
    this.power = power;
    this.direction = direction;
  }
}

float photon_radius = 8;

int NUM_CAUSTIC_PHOTONS_CAST = 0;
int NUM_CAUSTIC_PHOTONS_NEAR = 0;
float CAUSTIC_PHOTON_RADIUS = 0.0f;
class PhotonMap{
 
  kd_tree tree;
  public int numPhotons;
  
  ArrayList<Photon> queryCache;
  public PhotonMap(){
    this.tree = new kd_tree();
    this.numPhotons=0;
  }
  
  public void addPhoton(Photon p){
    this.numPhotons++;
   // println("Added : " + p +"   ");
    this.tree.add_photon(p);
  }
  
  public void buildMap(){
    println("NUMBER OF PHOTONS STORED :" +this.numPhotons); //<>//
    if(numPhotons > 0){
      tree.build_tree();
    }
  }
  
  public PhotonRadiance getCausticRadiance(PVector pos){
    if (!hasCausticPhotons(pos)) return null;
    PhotonRadiance res = new PhotonRadiance(new RGB(0,0,0), new PVector(0,0,0));
      //print("num photons in range" + photons.size());
    for(Photon p:queryCache){
          res.power.add(p.getPower());
          res.direction.add(p.direction.copy().mult(-1));
    }
    
    res.direction.normalize();
    return res;
  }
  
  public RGB getCausticColor(PVector pos, PVector surfaceNormal, RGB diffuseColor){
    if (!hasCausticPhotons(pos)) return new RGB(0,0,0);
    //print(queryCache.size() + " ");
    RGB finalColor = new RGB(0,0,0);
    for(Photon p:queryCache){
      float radFac = surfaceNormal.dot(p.direction.copy().mult(-1));
      if( radFac < 0 ) radFac = 0;
      
      float coneFilterWeight = (CAUSTIC_PHOTON_RADIUS -  pos.dist(p.origin))/(CAUSTIC_PHOTON_RADIUS) ;
      float boost = float(NUM_CAUSTIC_PHOTONS_CAST)/(100.0f );
      
      RGB radColor = diffuseColor.clone().dot(p.power.clone().mult(coneFilterWeight*boost/(PI * CAUSTIC_PHOTON_RADIUS*CAUSTIC_PHOTON_RADIUS))).mult(radFac);
      //radColor.dot(radColor).mult(100000);
      finalColor.add(radColor);
    }
    finalColor.mult(1/float(queryCache.size()));
    return finalColor;
  }
  
  public boolean hasCausticPhotons(PVector pos){
    
    if( numPhotons == 0) return false;
    queryCache = tree.find_near(pos.x,pos.y,pos.z,NUM_CAUSTIC_PHOTONS_NEAR,CAUSTIC_PHOTON_RADIUS);
    
    if( queryCache.size() == 0) return false;
    if( queryCache.size() > 0){
      if( queryCache.get(0) == null) return false;
    }
    
    return true;
  }
 
}


public void BuildCausticPhotonMap(){
  PVector randomDirection = new PVector(0,0,0);

   if(NUM_CAUSTIC_PHOTONS_CAST > 0){
    for(Light l: scene.getLights()){
      RGB powerPerPhoton = l.getColor().clone().mult(1/float(NUM_CAUSTIC_PHOTONS_CAST));
      for( int i =0; i< NUM_CAUSTIC_PHOTONS_CAST;i++){
        randomDirection.set(random(1.0f) - 0.5f, random(1.0f) - 0.5f , random(1.0f) - 0.5f );
        randomDirection.normalize();
        
        PVector pos = l.getPosition();      
        Photon p = new Photon(pos.x, pos.y,pos.z, randomDirection.x, randomDirection.y, randomDirection.z, powerPerPhoton);
        
        CausticPhotonTrace(p,null, 0);
      }

    }
   ArrayList<SceneObject> s = scene.getSceneObjects();
    for( SceneObject obj:s){
      Material m = (obj.getMaterial());
      if( m instanceof DiffuseMaterial){
        PhotonMap pM = ((DiffuseMaterial)(m)).causticMap;
        pM.buildMap();
      }
    }
 }
}

public void CausticPhotonTrace(Photon p, SceneObject ignoreObj, int reflCount){
  ArrayList<SceneObject> s = scene.getSceneObjects();
  PVector intersectPt = new PVector();
  float minDist = 999999.0f;
  PVector closestPt = new PVector(0,0,0);
  SceneObject hitObj = null;
  for( SceneObject obj:s){

    float t = obj.intersectRay(p, intersectPt, false, true);
      
    if( t!= MISSED){
      if( obj !=ignoreObj ){
        
        if(t < minDist){
          minDist = t;
          hitObj = obj;
          closestPt = intersectPt;
        }
        
      }
    }
  }
  
  if( hitObj == null ) return;
  hitObj.intersectRay(p, closestPt, false, true);
  Material m = hitObj.getMaterial();
      
  if( m instanceof SpecularMaterial){

      
       // print("Photon reflected");
        PVector normal = hitObj.getSurfaceNormalAtPt(closestPt);
        Photon reflected = (Photon)(p.reflect(normal, closestPt));
        reflCount++;
        
        CausticPhotonTrace(reflected,hitObj, reflCount);
      
    
  
  }else {
    //Unless Direct Hit fron light
    if ( reflCount > 0){
      DiffuseMaterial mD = (DiffuseMaterial)(m);
      p.setPos(closestPt);
      //print("storing Photon at "+closestPt + " on " + hitObj);
      mD.causticMap.addPhoton(p);
      //print("storing photon");
    }
  }
}

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