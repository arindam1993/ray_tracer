//Baseclass for scene objects
public interface SceneObject{
  
  public boolean intersectRay(Ray ray, PVector result); 
  public float getRayColor(RGB retColor, Ray ray, Scene scene, PVector retIntersectPt);
  public PVector getPosition();
  public void setPosition(PVector pos);
  
  public Material getMaterial();
  public void setMaterial(Material mat);
  
  public PVector getSurfaceNormalAtPt(PVector pt);
  
  
}




public class Sphere implements SceneObject{
  
  PVector position;
  float radius;
  Material mat;
  
  public Sphere(PVector position, float radius, Material mat){
    this.position = position;
    this.radius = radius;
    this.mat = mat;
  }
  
  public float getRayColor(RGB retColor,Ray ray,Scene scene, PVector retIntersectPt){
    PVector intersectPt = new PVector(0,0,0);
    
    if( this.intersectRay(ray, intersectPt) ){
      PVector surfNormal = this.getSurfaceNormalAtPt(intersectPt);
      retColor.copyTo(this.mat.getRenderColor(intersectPt, surfNormal, scene, ray, this));
      
      retIntersectPt.set(intersectPt.x, intersectPt.y, intersectPt.z);
      
      return PVector.sub(intersectPt, ray.origin).mag();
    }else{
    retColor.copyTo(scene.getBackground());
    return -1.0f;
    }
  }
  
  public PVector getPosition(){
    return position;
  }
  public void setPosition(PVector pos){
    this.position = pos;
  }
  
  public void setMaterial(Material mat){
    this.mat = mat;
  }
  public Material getMaterial(){
    return this.mat;
  }
  public PVector getSurfaceNormalAtPt(PVector pt){
    return PVector.sub(pt, this.position).normalize();
  }
  
  public boolean intersectRay(Ray ray, PVector result){
    
    float dx = ray.direction.x;
    float dy = ray.direction.y;
    float dz = ray.direction.z;
    
    float x0 = ray.origin.x;
    float y0 = ray.origin.y;
    float z0 = ray.origin.z;
    
    float cx = this.position.x;
    float cy = this.position.y;
    float cz = this.position.z;
    
    float a = dx*dx + dy*dy + dz*dz;
    float b = 2*dx*(x0-cx) +  2*dy*(y0-cy) +  2*dz*(z0-cz);
    float c = cx*cx + cy*cy + cz*cz + x0*x0 + y0*y0 + z0*z0 - 2*(cx*x0 + cy*y0 + cz*z0) - this.radius*this.radius;
    
    float D = b*b - 4*a*c;
    if ( D < 0 ) { return false ; }
    
    float t1 = (-b - sqrt(D))/ 2*a;
    //float t2 = (-b + sqrt(D))/ 2*a;
    
    PVector r1 = new PVector(x0 + t1*dx, y0 + t1*dy, z0 + t1*dz);
    //PVector r2 = new PVector(x0 + t2*dx, y0 + t2*dy, z0 + t2*dz);
    
    PVector toR1 = PVector.sub(r1, ray.origin);
    //PVector toR2 = PVector.sub(r2, ray.origin);
    
    ////Check if intersection is in ray direction
    if( toR1.dot(ray.direction) < 0 ) return false;
      
    //return r2 since s1 is in opposite direction of ray
    // result.set(r2.x, r2.y, r2.z);
      
    // println("r1 was opposite");
    //}else if( toR2.dot(ray.direction) < 0 ) {
      
    // //Similarly return the other point
    // result.set(r1.x, r1.y, r1.z);
    // println("r2 was opposite");
    //}
    ////When both are positive
    //else {
      
    //  //Pick the closest
    //  if( ray.origin.dist(r1) <= ray.origin.dist(r2)) result.set(r1.x, r1.y, r1.z);
    //   result.set(r2.x, r2.y, r2.z);
    //}
     result.set(r1.x, r1.y, r1.z);
    return true;
    
  }
  

  
  
  
  public String toString(){
    return "Sphere : { x:" + position.x + " y:" + position.y + " z:" + position.z + " R:" + radius +" Material :"+this.mat +" } ";
  }
}