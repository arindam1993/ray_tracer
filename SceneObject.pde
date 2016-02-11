//Baseclass for scene objects
public interface SceneObject{
  
  public boolean intersectRay(Ray ray, PVector result, boolean DEBUG); 
  public float getRayColor(RGB retColor, Ray ray, Scene scene, PVector retIntersectPt, boolean DEBUG);
  public PVector getPosition();

  
  public Material getMaterial();
  public void setMaterial(Material mat);
  
  public PVector getSurfaceNormalAtPt(PVector pt);
  public Ray getRefractedRay(Ray incidentRay);
  
  
  public void transform(PMatrix3D t);
  
  
}

public class Polygon implements SceneObject{
  
 PVector[] vertices;
 int numVertices;
 Material mat;
  
 public Polygon(){
   vertices = new PVector[3];
   numVertices = 0;
 }
  
 public void addVertex(PVector v){
   if ( numVertices < 3 ){
     vertices[numVertices] = v;
     numVertices++;
   }
 }
  
 
 public boolean intersectRay(Ray ray, PVector result, boolean DEBUG){
   
   
   //Ray is almost parallel
   PVector N = getSurfaceNormalAtPt(new PVector(0,0,0));
   
   if ( DEBUG ) println("N: "+N);
   
   if( abs(ray.direction.dot(N)) < 0.01f) return false;
   
   float D = N.dot(vertices[0]);
   
   if ( DEBUG ) println("D: "+D);
   
   float t =  (N.dot(ray.origin) + D)/N.dot(ray.direction);
   //print(t+" ");
   
   if ( DEBUG ) println("Ray Origin: "+N.dot(ray.origin));
   
   //Triangle is behind
   if ( t < 0.01f ) return false;
   
   
   if ( DEBUG ) println("t: "+t);
   
   PVector intersectPt = PVector.add(ray.origin, ray.direction.copy().normalize().mult(t));
   
   PVector planeVec = PVector.sub(vertices[0], intersectPt);
   
   if ( abs(planeVec.dot(N) ) > 0.01f) return false;
    //print(intersectPt+" ");
   PVector C;
   
   PVector e1 = PVector.sub(vertices[1], vertices[0]);
   PVector vp0 = PVector.sub(intersectPt, vertices[0]);
   
   C = e1.cross(vp0);
   //print("NdotC:"+C);
   if ( N.dot(C) > 0) return false;
   
   PVector e2 = PVector.sub(vertices[2], vertices[1]);
   PVector vp1 = PVector.sub(intersectPt, vertices[1]);
   
   C = e2.cross(vp1);
   if ( N.dot(C) > 0) return false;
   
   PVector e3 = PVector.sub(vertices[0], vertices[2]);
   PVector vp2 = PVector.sub(intersectPt, vertices[2]);
   
    C = e3.cross(vp2);
   if ( N.dot(C) > 0) return false;
   
   PVector toPt = PVector.sub(intersectPt, ray.origin);
   
   if( toPt.dot(ray.direction) < 0 ) return false;
   
   result.set(intersectPt.x, intersectPt.y, intersectPt.z);
   
   return true;
  
   
 }
 
 public float getRayColor(RGB retColor, Ray ray, Scene scene, PVector retIntersectPt, boolean DEBUG){
   PVector intersectPt = new PVector(0,0,0);
    
    if( this.intersectRay(ray, intersectPt, false) ){
      PVector surfNormal = this.getSurfaceNormalAtPt(intersectPt);
      
      //Make polygons double sided
      if( surfNormal.dot(intersectPt) > 0) surfNormal.mult(-1);
      
      retColor.copyTo(this.mat.getRenderColor(intersectPt, surfNormal, scene, ray, this, DEBUG));
      
      retIntersectPt.set(intersectPt.x, intersectPt.y, intersectPt.z);
     //print("Hit and color " + intersectPt);
      
      return PVector.sub(intersectPt, ray.origin).mag();
    }else{
    retColor.copyTo(scene.getBackground());
    return -1.0f;
    }
 }
 
 public PVector getPosition(){
   PVector center = new PVector(0,0,0);
   
   for( int i=0;i<3 ; i++){
     center.add(vertices[i]);
   }
   return center;
   
 }
  
 public PVector getSurfaceNormalAtPt(PVector pt){
   PVector vec1 = PVector.sub(vertices[2], vertices[0]);
   PVector vec2 = PVector.sub(vertices[1], vertices[0]);
   PVector res1=  vec1.cross(vec2).normalize().mult(1);
   
   return res1;
 }
  
 public void setMaterial(Material mat){
   this.mat = mat;
 }
 public Material getMaterial(){
   return this.mat;
 }
  
  
  public Ray getRefractedRay(Ray incidentRay){
  
    float rIndex = ((SpecularMaterial)(this.mat)).getRefractiveIndex();
    PVector f =new PVector(0,0,0);
    return new Ray(incidentRay.origin, Refract(incidentRay.direction, getSurfaceNormalAtPt(f),rIndex));
  }
  
  
  public void transform(PMatrix3D t){
  
    for( int i=0 ; i<vertices.length ; i++){
      PVector vertex = vertices[i];
      PVector transformedVertex = new PVector(0,0,0);
      
      vertices[i] = t.mult(vertex, transformedVertex);
    }
  }
  
  
  public String toString(){
    return "Polygon: { v0: "+vertices[0]+", v1: "+vertices[1]+", v2: "+vertices[2] + ", Material: "+ mat+"}";
  }
  
  
  
  
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
  
  public float getRayColor(RGB retColor,Ray ray,Scene scene, PVector retIntersectPt, boolean DEBUG){
    PVector intersectPt = new PVector(0,0,0);
    
    if( this.intersectRay(ray, intersectPt, false) ){
      PVector surfNormal = this.getSurfaceNormalAtPt(intersectPt);
      retColor.copyTo(this.mat.getRenderColor(intersectPt, surfNormal, scene, ray, this, DEBUG));
      
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
  
  public boolean intersectRay(Ray ray, PVector result, boolean DEBUG){
    
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
    float t2 = (-b + sqrt(D))/ 2*a;
    
    PVector r1 = new PVector(x0 + t1*dx, y0 + t1*dy, z0 + t1*dz);
    PVector r2 = new PVector(x0 + t2*dx, y0 + t2*dy, z0 + t2*dz);
    
    PVector toR1 = PVector.sub(r1, ray.origin);
    PVector toR2 = PVector.sub(r2, ray.origin);
    
    ////Check if intersection is in ray direction
    if(toR1.dot(ray.direction)  > 0  && toR2.dot(ray.direction) > 0)  {
      
    //  //Pick the closest
     if( ray.origin.dist(r1) <= ray.origin.dist(r2)) result.set(r1.x, r1.y, r1.z);
     else  result.set(r2.x, r2.y, r2.z);
    }
    else {
     
    return false;
  }
    ////When both are positive
    
     result.set(r1.x, r1.y, r1.z);
    return true;
    
  }
  
  
  public Ray getRefractedRay(Ray incidentRay){
    float rIndex = ((SpecularMaterial)(this.mat)).getRefractiveIndex();
    PVector firstHit = new PVector(0,0,0);
    this.intersectRay(incidentRay, firstHit,false);
    
    PVector newDir = Refract(incidentRay.direction, this.getSurfaceNormalAtPt(firstHit), rIndex);
    
    Ray firstRefraction = new Ray(firstHit, newDir.normalize());
    PVector nextHit = fartherHit(firstRefraction );
    PVector escapeDir = Refract(nextHit, this.getSurfaceNormalAtPt(nextHit).copy().mult(-1), 1/rIndex);
    
    return new Ray(nextHit, escapeDir.normalize());
  
  }
  
  private PVector fartherHit(Ray ray){
  
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
    float t1 = (-b - sqrt(D))/ 2*a;
    float t2 = (-b + sqrt(D))/ 2*a;
    
    PVector r1 = new PVector(x0 + t1*dx, y0 + t1*dy, z0 + t1*dz);
    PVector r2 = new PVector(x0 + t2*dx, y0 + t2*dy, z0 + t2*dz);
    
    if( ray.origin.dist(r1) > ray.origin.dist(r2)) return r1;
     else  return r2;
  }
  
  
  public void transform(PMatrix3D t){

    float scale = t.m33;
    
    PVector result = new PVector(0,0,0);
    
    this.position = t.mult(this.position, result);
    this.radius*=scale;
  }
  
  
  
  public String toString(){
    return "Sphere : { x:" + position.x + " y:" + position.y + " z:" + position.z + " R:" + radius +" Material :"+this.mat +" } ";
  }
}