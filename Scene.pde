import java.util.HashMap;

//Data structure which stores the entire scene, gets built up as the .cli file gets parsed
public class Scene{
  
  private ArrayList<SceneObject> objects;
  private ArrayList<Light> lights;
  private ArrayList<Ray> _currPixelRays;
  private HashMap<String, SceneObject> namedObjs;
  
  private RGB bgColor;
  public int numRays;
  
  public PVector eye;
  private float fov;
  public float viewPlaneScale;
  public float pixSize;
  
  public float focalDistance;
  public float lensRadius;
  public Scene() {
    initDefaults();
    _currPixelRays = new ArrayList<Ray>();
  }
  
  public Scene(float fov,RGB bgColor){
    initDefaults();
    this.bgColor = bgColor;
    setFOV(fov);
  }
  
  private void initDefaults(){
    objects = new ArrayList<SceneObject>();
    lights = new ArrayList<Light>();
    namedObjs = new HashMap<String, SceneObject>();
    eye = new PVector(0,0,0);
    bgColor = new RGB(0.0,0.0,0.0);
    focalDistance = -1.0f; 
    lensRadius = -1.0f;
    numRays=1;
  }
  
  public boolean hasLens(){
    return ( focalDistance >0 ) && ( lensRadius > 0);
  }
 
  public void addObject(SceneObject object){
    objects.add(object);
    
    println("Added Object: "+object.toString());
  }
  public void addLight(Light light){
    lights.add(light);
    
     println("Added Light: "+light.toString());
  }
  
  public void setFOV(float fov){
    this.fov = fov * PI/180;
    this.viewPlaneScale = 2 *tan(this.fov/2); 
    
    println("View Plane Scale: "+this.viewPlaneScale);
  }
  public void setBackground(RGB c){
    this.bgColor.copyTo(c);
    println("Scene Background Set to : "+ this.bgColor);
    
  }
  
   public RGB getBackground(){
    return this.bgColor;
  }
  
  public ArrayList<Light> getLights(){
    return lights;
  }
  
  public void addNamedObj(String name, SceneObject obj){
    namedObjs.put(name,obj);
  }
  
  public SceneObject getObjByName(String name){
    return namedObjs.get(name);
  }
  
  
  
  public ArrayList<SceneObject> getSceneObjects(){
    return objects;
  }
  
  public void clear(){
    objects.clear();
    lights.clear();
    focalDistance = -1.0f; 
    lensRadius = -1.0f;
     bgColor = new RGB(0.0,0.0,0.0);
  }
  
  
  public void render(){
 
    for(int h = 0; h < height ; h++)
    {
      for(int w = 0; w < width ; w++)
      {
        boolean DEBUG = (w < 5) && (h <5);
        _currPixelRays.clear();
        getPixelRays(w,h,this.viewPlaneScale/width,_currPixelRays);
        //ray = getEyeRay(ray,w,h);
        RGB finalColor = new RGB(0,0,0);
        float finalDepth = 999999;
        int loopCt = 0;
        for ( Ray r : _currPixelRays){
          
          r.setTimestamp(random(1));
          if ( this.hasLens() ){
            
            if ( DEBUG ) println( r);
            r.randomlyBlur(this.lensRadius, this.focalDistance);
          }
          //print( r + " ");
          RayTraceReturn ret = RayTrace(r,scene,null,true, 0, false);
          if ( loopCt == 0){
            finalDepth = ret.depth;
           }
           loopCt++;
           //if (DEBUG)
             //print( ret.pixColor + " " );
          finalColor.add(ret.pixColor);
        }
        
        //if ( DEBUG )
         //print( finalColor + " " );
        finalColor.mult(1/float(loopCt));
        //if ( DEBUG )
         //print( finalColor + " " );
        
        if( finalDepth <= ZBuffer[w][h] ){
          
          set(int(w),int(h), finalColor.getPColor());
          ZBuffer[w][h] = finalDepth;
        }
        
      }
    }
  }
  
}