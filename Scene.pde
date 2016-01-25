

//Data structure which stores the entire scene, gets built up as the .cli file gets parsed
public class Scene{
  
  private ArrayList<SceneObject> objects;
  private ArrayList<Light> lights;
  private RGB bgColor;
  
  private PVector eye;
  private float fov;
  private float viewPlaneScale;
  
  public Scene() {
    initDefaults();
  }
  
  public Scene(float fov,RGB bgColor){
    initDefaults();
    this.bgColor = bgColor;
    setFOV(fov);
  }
  
  private void initDefaults(){
    objects = new ArrayList<SceneObject>();
    lights = new ArrayList<Light>();
    
    eye = new PVector(0,0,0);
    bgColor = new RGB(0.0,0.0,0.0);
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
    this.viewPlaneScale = tan(this.fov/2); 
    
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
  
  public ArrayList<SceneObject> getSceneObjects(){
    return objects;
  }
  
  public void clear(){
    objects.clear();
    lights.clear();
     bgColor = new RGB(0.0,0.0,0.0);
  }
  
  
  public void render(){

    PVector pixPt = new PVector(0,0,-1);
    Ray ray = new Ray(eye, new PVector(0,0,-1));
   
    
    for(int h = 0; h < height ; h++)
    {
      for(int w = 0; w < width ; w++)
      {
        float px =(float)( w - (width/2)) * (2*this.viewPlaneScale/width);
        float py =(float)( h - (height/2)) *  (-1 * 2*this.viewPlaneScale/height);
        pixPt.set(px,py,-1);
        
        //RGB pixColor = new RGB(0,0,0);
        ray.setEndPoint(pixPt);

        RayTraceReturn ret = RayTrace(ray,scene,null,true, 0);
        
        if( ret.depth < ZBuffer[w][h]){
          set(int(w),int(h), ret.pixColor.getPColor());
          ZBuffer[w][h] = ret.depth;
        }
      }
    }
  }
  
}