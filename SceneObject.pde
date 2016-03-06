//Baseclass for scene objects

float MISSED = -1.0f;

public interface SceneObject{
  
  public float intersectRay(Ray ray, PVector result, boolean DEBUG, boolean isShadowRay); 
  public float getRayColor(RGB retColor, Ray ray, Scene scene, PVector retIntersectPt, boolean DEBUG, boolean isShadowRay);
  public PVector getPosition();

  
  public Material getMaterial();
  public void setMaterial(Material mat);
  
  public PVector getSurfaceNormalAtPt(PVector pt);
  public Ray getRefractedRay(Ray incidentRay);
  
  public PVector getBBoxMin();
  public PVector getBBoxMax();
  public void initBBox();
  
  public void transform(PMatrix3D t);
  
  
}


public class ListObject implements SceneObject{

    private ArrayList<SceneObject> objects;
    private boolean accelerated;
    
    private SceneObject lastQueried;
    
    private PVector _bboxMin;
    private PVector _bboxMax;
    private BoundingBox bbox;
    
    public ListObject(){
      objects = new ArrayList<SceneObject>();
      accelerated = false;
      lastQueried = null;
      _bboxMin = new PVector(99999.0f,99999.0f,99999.0f);
      _bboxMax = new PVector(-99999.0f,-99999.0f,-99999.0f);
    }
    
    
    public float intersectRay(Ray ray, PVector result, boolean DEBUG, boolean isShadowRay){
      
      if( this.bbox.intersectRay(ray,result,DEBUG,isShadowRay) == MISSED ){ return MISSED; }
      
      SceneObject closest = null;
      float minDepth = 999999.0f;
      for( SceneObject _obj : objects ){
        
        float depth = _obj.intersectRay(ray,result,DEBUG,isShadowRay);
        
        if( depth != MISSED ){
          
          if( depth < minDepth){
            
            closest = _obj;
            minDepth = depth;
            
          }
          
        }
      }
      
      if ( closest == null ) return MISSED;
      
      lastQueried = closest;
      return closest.intersectRay(ray,result,DEBUG,isShadowRay);
      
    }
    
    
    
    public float getRayColor(RGB retColor, Ray ray, Scene scene, PVector retIntersectPt, boolean DEBUG, boolean isShadowRay){
      PVector intersectPt = new PVector(0,0,0);
      
      if( this.intersectRay(ray, intersectPt, false, isShadowRay) != MISSED){
        PVector surfNormal = this.getSurfaceNormalAtPt(intersectPt);
        
        //Double sided polygon hack
        if ( lastQueried instanceof Polygon){
          if( surfNormal.dot(intersectPt) > 0) surfNormal.mult(-1);
        }
        
        if(!isShadowRay){
          retColor.copyTo(this.lastQueried.getMaterial().getRenderColor(intersectPt, surfNormal, scene, ray, this, DEBUG));
        }
        
        retIntersectPt.set(intersectPt.x, intersectPt.y, intersectPt.z);
        
        return PVector.sub(intersectPt, ray.origin).mag();
      }else{
      retColor.copyTo(scene.getBackground());
      return MISSED;
      } 
      
    }
    public PVector getPosition(){
      return new PVector(0,0,0);
    }
  
    
    public Material getMaterial(){
      return lastQueried.getMaterial();
    }
    public void setMaterial(Material mat){
      for ( SceneObject _obj : objects ){
        _obj.setMaterial(mat);
      }
    }
    
    public PVector getSurfaceNormalAtPt(PVector pt){
    
      return lastQueried.getSurfaceNormalAtPt(pt);
    }
    public Ray getRefractedRay(Ray incidentRay){
    
      return lastQueried.getRefractedRay(incidentRay);
    }
    
    public void transform(PMatrix3D t){
      for ( SceneObject _obj : objects ){
        _obj.transform(t);
      }
    }
    
    public void addObject(SceneObject obj){
      objects.add(obj);
      
      PVector min = obj.getBBoxMin();
      
      if ( min.x < _bboxMin.x ) _bboxMin.x  = min.x;
      if ( min.y < _bboxMin.y ) _bboxMin.y  = min.y;
      if ( min.z < _bboxMin.z ) _bboxMin.z  = min.z;
      
      PVector max = obj.getBBoxMax();
      
      if ( max.x > _bboxMax.x ) _bboxMax.x  = max.x;
      if ( max.y > _bboxMax.y ) _bboxMax.y  = max.y;
      if ( max.z > _bboxMax.z ) _bboxMax.z  = max.z;
      
    }
    
  public PVector getBBoxMin(){
    return _bboxMin;
  }
  
  public PVector getBBoxMax(){
    return _bboxMax;
  }
    
  public void initBBox(){
    PVector min = this.getBBoxMin();
    PVector max = this.getBBoxMax();
    this.bbox = new BoundingBox(min.x,min.y,min.z, max.x , max.y, max.z);
    println(this.bbox+ "List Object Created ");
  }
}


public class InstancedObject implements SceneObject{

  SceneObject baseObj;
  PMatrix3D tMat;
  PMatrix3D invertTMat;
  PMatrix3D adjTMat;
  
  
  public InstancedObject(String name){
    baseObj = scene.getObjByName(name);
    tMat = matStack.top().get();

    tMat.print();
    println();    
    invertTMat = tMat.get();
    invertTMat.invert();
     //myInvert(invertTMat);
    invertTMat.print();
    adjTMat = invertTMat.get();
    adjTMat.transpose();
  }
  
  
  public float intersectRay(Ray ray, PVector result, boolean DEBUG, boolean isShadowRay){
    
    //print(newRay);
    return baseObj.intersectRay(ray, result, DEBUG,isShadowRay);
  } 
  
  public float getRayColor(RGB retColor, Ray ray, Scene scene, PVector retIntersectPt, boolean DEBUG, boolean isShadowRay){
    Ray newRay = ray.transform(invertTMat);
    
    float tScale = newRay.direction.mag();
    newRay.direction.normalize();
    
    if(DEBUG){
      println("NEW RAY:" + newRay);
    }
     PVector intersectPt = new PVector(0,0,0);
    float tVal = this.intersectRay(newRay, intersectPt, false,isShadowRay);
    if( tVal  != MISSED){
      PVector surfNormal = this.getSurfaceNormalAtPt(intersectPt);
      if (DEBUG){
        println("Normal: " + surfNormal);
       
      }
      
      tVal = tVal/tScale;
      
      PVector tIntersect = PVector.add(ray.origin, ray.direction.copy().mult(tVal));
      
      if(DEBUG){
        println("Intersect: " + tIntersect);
      }
      if(!isShadowRay){
        retColor.copyTo(this.baseObj.getMaterial().getRenderColor(tIntersect, surfNormal, scene, newRay, this, DEBUG));
      }
      
      retIntersectPt.set(tIntersect.x, tIntersect.y, tIntersect.z);
      
      //print(intersectPt);
      
      return tVal;
    }else{
    retColor.copyTo(scene.getBackground());
    return MISSED;
    }
  }
  public PVector getPosition(){
    PVector tPos = new PVector(0,0,0);
    tPos = tMat.mult(baseObj.getPosition(), tPos);
    return tPos;
  }
  
  public Material getMaterial(){
    return this.baseObj.getMaterial();
  }
  public void setMaterial(Material mat){
    this.baseObj.setMaterial(mat);
  }
  
  
  public PVector getSurfaceNormalAtPt(PVector pt){
    //PVector newPt = new PVector(0,0,0);
    //adjTMat.mult(pt,newPt);
    PVector normal = baseObj.getSurfaceNormalAtPt(pt);
    PVector newNormal = new PVector(0,0,0);
    newNormal = adjTMat.mult(normal, newNormal);
    newNormal.normalize();
    return newNormal;
  }
  public Ray getRefractedRay(Ray incidentRay){
    return baseObj.getRefractedRay(incidentRay);
  }
  
  
  public void transform(PMatrix3D t){}
  
    public PVector getBBoxMin(){
    return baseObj.getBBoxMin();
  }
  
  public PVector getBBoxMax(){
    return baseObj.getBBoxMax();
  }
  
   public void initBBox(){
    baseObj.initBBox();
  }
  
  public String toString(){
    return "Instance of :" + baseObj;
  }
}

public class BoundingBox implements SceneObject{
  
  PVector min;
  PVector max;
  Material mat;
  
  public BoundingBox(float xMin, float yMin, float zMin, float xMax, float yMax, float zMax){
    this.min = new PVector(xMin, yMin, zMin);
    this.max = new PVector(xMax, yMax, zMax);
    
  }
  
  public float intersectRay(Ray ray, PVector result, boolean DEBUG, boolean isShadow){
  
  
    float tMin = ( min.x - ray.origin.x)/ray.direction.x;
    float tMax = ( max.x - ray.origin.x)/ray.direction.x;
    
    //Swapping
    if( tMin > tMax ){
      float temp = tMax;
      tMax = tMin;
      tMin = temp;  
    }
    
    float tyMin = ( min.y - ray.origin.y )/ ray.direction.y;
    float tyMax = ( max.y - ray.origin.y )/ ray.direction.y;
    
    //Swapping again
    if( tyMin > tyMax ){
      float temp = tyMax;
      tyMax = tyMin;
      tyMin = temp;  
    } 
    
    
    if ((tMin > tyMax) || (tyMin > tMax)) 
        return MISSED; 
 
    if (tyMin > tMin) 
        tMin = tyMin; 
 
    if (tyMax < tMax) 
        tMax = tyMax; 
  
    float tzMin = (min.z - ray.origin.z)/ray.direction.z;
    float tzMax = (max.z - ray.origin.z)/ray.direction.z;
    
    if(  tzMin > tzMax ) {
      float temp = tzMax;
      tzMax = tzMin;
      tzMin = temp;
    }
    
     if ((tMin > tzMax) || (tzMin > tMax)) 
        return MISSED; 
 
    if (tzMin > tMin) 
        tMin = tzMin; 
 
    if (tzMax < tMax) 
        tMax = tzMax; 
 
   PVector pt = PVector.add(ray.origin, ray.direction.copy().mult(tMin));
   
   result.set(pt.x, pt.y, pt.z);
 
    return tMin; 
  }
  
  
   
  public float getRayColor(RGB retColor, Ray ray, Scene scene, PVector retIntersectPt, boolean DEBUG, boolean isShadowRay){
    PVector intersectPt = new PVector(0,0,0);
      
      if( this.intersectRay(ray, intersectPt, false, isShadowRay) != MISSED){
        PVector surfNormal = this.getSurfaceNormalAtPt(intersectPt);
        
        if(!isShadowRay){
          retColor.copyTo(this.mat.getRenderColor(intersectPt, surfNormal, scene, ray, this, DEBUG));
        }
        
        retIntersectPt.set(intersectPt.x, intersectPt.y, intersectPt.z);
        
        return PVector.sub(intersectPt, ray.origin).mag();
      }else{
      retColor.copyTo(scene.getBackground());
      return -1.0f;
      }
  }
  
  public PVector getPosition(){
    return min;
  }

  
  public Material getMaterial(){
    return mat;
  }
  public void setMaterial(Material mat){
    this.mat = mat;
  }
  
  public PVector getSurfaceNormalAtPt(PVector pt){
  
    return new PVector(0,0,1);
  }
  public Ray getRefractedRay(Ray incidentRay){
    
    float rIndex = ((SpecularMaterial)(this.mat)).getRefractiveIndex();
    PVector f =new PVector(0,0,0);
    return new Ray(incidentRay.origin, Refract(incidentRay.direction, getSurfaceNormalAtPt(f),rIndex));
  
  }
  
  public PVector getBBoxMin(){
    return min;
  }
  
   public PVector getBBoxMax(){
    return max;
  }
  
   public void initBBox(){
  }
  
  public void transform(PMatrix3D t){}
  
  public String toString(){
    return " BoundingBox: { Min:" + this.min + " , Max : " + this.max + "}";
  }
  
}

public class Polygon implements SceneObject{
  
 PVector[] vertices;
 int numVertices;
 Material mat;
 PVector _bboxMin;
 PVector _bboxMax;
 BoundingBox bbox;
  
 public Polygon(){
   vertices = new PVector[3];
   numVertices = 0;
   _bboxMin = new PVector(9999.0f,9999.0f,9999.0f);
   _bboxMax = new PVector(-9999.0f,-9999.0f,-9999.0f);
 }
  
 public void addVertex(PVector v){
   if ( numVertices < 3 ){
     vertices[numVertices] = v;
     numVertices++;
   }
 }
  
 
 public float intersectRay(Ray ray, PVector result, boolean DEBUG, boolean isShadowRay){
   
   if( this.bbox.intersectRay(ray,result,DEBUG,isShadowRay) == MISSED ){ return MISSED; }
   
   //Ray is almost parallel
   PVector N = getSurfaceNormalAtPt(new PVector(0,0,0));
   
   //if ( DEBUG ) println("N: "+N);
   
  
   
   float D = -N.dot(vertices[0]);
   
   //if ( DEBUG ) println("D: "+D);
   
   float t =  -(N.dot(ray.origin) + D)/N.dot(ray.direction);
   
   
   //if ( DEBUG ) println("Ray Origin: "+N.dot(ray.origin));
   
   //Triangle is behind
   if ( t < 0.01f ) return MISSED;
   //if( abs(ray.direction.dot(N)) == 0.0f) return MISSED;
   
  // if ( DEBUG ) println("t: "+t);
   
   PVector intersectPt = PVector.add(ray.origin, ray.direction.copy().normalize().mult(t));
   
   PVector planeVec = PVector.sub(vertices[0], intersectPt).normalize();
   
   if(DEBUG && isShadowRay){
     println("t:"+t+" "+ " fact: " + abs(planeVec.dot(N)));
   }
   
   if ( abs(planeVec.dot(N) ) > 0.1f) {

   return MISSED;
}
// 
      
   //if(DEBUG && isShadowRay){
   //  println("t:"+t+" ");
   //}
    //print(intersectPt+" ");
   PVector C;
   
   PVector e1 = PVector.sub(vertices[1], vertices[0]);
   PVector vp0 = PVector.sub(intersectPt, vertices[0]);
   
   C = e1.cross(vp0);
   //print("NdotC:"+C);
   if ( N.dot(C) > 0) return MISSED;
   
   PVector e2 = PVector.sub(vertices[2], vertices[1]);
   PVector vp1 = PVector.sub(intersectPt, vertices[1]);
   
   C = e2.cross(vp1);
   if ( N.dot(C) > 0) return MISSED;
   
   PVector e3 = PVector.sub(vertices[0], vertices[2]);
   PVector vp2 = PVector.sub(intersectPt, vertices[2]);
   
    C = e3.cross(vp2);
   if ( N.dot(C) > 0) return MISSED;

   
   result.set(intersectPt.x, intersectPt.y, intersectPt.z);
   
   return t;
  
   
 }
 
 public float getRayColor(RGB retColor, Ray ray, Scene scene, PVector retIntersectPt, boolean DEBUG, boolean isShadowRay){
   PVector intersectPt = new PVector(0,0,0);
    float tVal = this.intersectRay(ray, intersectPt, DEBUG, isShadowRay);
    if(DEBUG && isShadowRay && tVal!=MISSED){
      println("tVal: "+tVal);
    }
    if( tVal != MISSED){
      PVector surfNormal = this.getSurfaceNormalAtPt(intersectPt);
      
      //Make polygons double sided
      if( surfNormal.dot(intersectPt) > 0) surfNormal.mult(-1);
      
      if(!isShadowRay){
        retColor.copyTo(this.mat.getRenderColor(intersectPt, surfNormal, scene, ray, this, DEBUG));
      }
      
      retIntersectPt.set(intersectPt.x, intersectPt.y, intersectPt.z);
     //print("Hit and color " + intersectPt);
      
      return tVal;
    }else{
    retColor.copyTo(scene.getBackground());
    return tVal;
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
   PVector res1=  vec1.cross(vec2).normalize();
   
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
  
  
  public PVector getBBoxMin(){
    for ( PVector v: vertices){
      if ( v.x < _bboxMin.x ) _bboxMin.x = v.x;
      if ( v.y < _bboxMin.y ) _bboxMin.y = v.y;
      if ( v.z < _bboxMin.z ) _bboxMin.z = v.z;
    }
    
    return _bboxMin;
  }
  
  public PVector getBBoxMax(){
    
     for ( PVector v: vertices){
      if ( v.x > _bboxMax.x ) _bboxMax.x = v.x;
      if ( v.y > _bboxMax.y ) _bboxMax.y = v.y;
      if ( v.z > _bboxMax.z ) _bboxMax.z = v.z;
    }
    

    
    return _bboxMax;
  }
  
   public void initBBox(){
    PVector min = this.getBBoxMin();
    PVector max = this.getBBoxMax();
    this.bbox = new BoundingBox(min.x,min.y,min.z, max.x , max.y, max.z);
    println(this.bbox+" Created " );
  }
  
  public String toString(){
    return "Polygon: { v0: "+vertices[0]+", v1: "+vertices[1]+", v2: "+vertices[2] + ", Material: "+ mat+"}";
  }
  
  
  
  
}


public class Sphere implements SceneObject{
  
  PVector position;
  float radius;
  Material mat;
  BoundingBox bbox;
  
  public Sphere(PVector position, float radius, Material mat){
    this.position = position;
    this.radius = radius;
    this.mat = mat;
  }
  
  public float getRayColor(RGB retColor,Ray ray,Scene scene, PVector retIntersectPt, boolean DEBUG, boolean isShadowRay){
    PVector intersectPt = new PVector(0,0,0);
    
    if( this.intersectRay(ray, intersectPt, false,isShadowRay) != MISSED){
      PVector surfNormal = this.getSurfaceNormalAtPt(intersectPt);
      retColor.copyTo(this.mat.getRenderColor(intersectPt, surfNormal, scene, ray, this, DEBUG));
      
      if(!isShadowRay){
        retIntersectPt.set(intersectPt.x, intersectPt.y, intersectPt.z);
      }
      
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
    return PVector.sub(pt, this.getPosition()).mult(1/this.radius);
  }
  
  public float intersectRay(Ray ray, PVector result, boolean DEBUG, boolean isShadowRay){
    
    if( this.bbox.intersectRay(ray,result,DEBUG,isShadowRay) == MISSED ){ return MISSED; }
    
    float dx = ray.direction.x;
    float dy = ray.direction.y;
    float dz = ray.direction.z;
    
    float x0 = ray.origin.x;
    float y0 = ray.origin.y;
    float z0 = ray.origin.z;
    
    PVector pos = this.getPosition();
    //print( pos);
    float cx = pos.x;
    float cy = pos.y;
    float cz = pos.z;
    
    float a = dx*dx + dy*dy + dz*dz;
    float b = 2*dx*(x0-cx) +  2*dy*(y0-cy) +  2*dz*(z0-cz);
    float c = cx*cx + cy*cy + cz*cz + x0*x0 + y0*y0 + z0*z0 - 2*(cx*x0 + cy*y0 + cz*z0) - this.radius*this.radius;
    
    float D = b*b - 4*a*c;
    if ( D < 0 ) { return MISSED ; }
    
    float t1 = (-b - sqrt(D))/ 2*a;
    float t2 = (-b + sqrt(D))/ 2*a;
    
    PVector r1 = new PVector(x0 + t1*dx, y0 + t1*dy, z0 + t1*dz);
    PVector r2 = new PVector(x0 + t2*dx, y0 + t2*dy, z0 + t2*dz);
    
    PVector toR1 = PVector.sub(r1, ray.origin);
    PVector toR2 = PVector.sub(r2, ray.origin);
    
    float t = t1;
    ////Check if intersection is in ray direction
    if(toR1.dot(ray.direction)  > 0  && toR2.dot(ray.direction) > 0)  {
      
    //  //Pick the closest
     if( ray.origin.dist(r1) <= ray.origin.dist(r2)) result.set(r1.x, r1.y, r1.z);
     else  {
       t=t2;
       result.set(r2.x, r2.y, r2.z);
     }
    }
    else {
     
    return MISSED;
  }
    ////When both are positive
    
     result.set(r1.x, r1.y, r1.z);
    return t;
    
  }
  
  
  public Ray getRefractedRay(Ray incidentRay){
    float rIndex = ((SpecularMaterial)(this.mat)).getRefractiveIndex();
    PVector firstHit = new PVector(0,0,0);
    this.intersectRay(incidentRay, firstHit,false, false);
    
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
  
    public PVector getBBoxMin(){
    return this.getPosition().copy().add(_Gxyz.copy().mult(-1 * this.radius));
  }
  
   public PVector getBBoxMax(){
    return this.getPosition().copy().add(_Gxyz.copy().mult(this.radius));
  }
  
   public void initBBox(){
    PVector min = this.getBBoxMin();
    PVector max = this.getBBoxMax();
    this.bbox = new BoundingBox(min.x,min.y,min.z, max.x , max.y, max.z);
  }
  
  public String toString(){
    return "Sphere : { x:" + position.x + " y:" + position.y + " z:" + position.z + " R:" + radius +" Material :"+this.mat +" } ";
  }
}


public class MovingSphere extends Sphere{

  
  PVector start;
  PVector end;
  
  float lastTime;
  public MovingSphere(PVector start, PVector end, float radius, Material m){
    super(end,radius,m);
    this.start = start;
    this.end = end;  
    lastTime = 0;
  }
  
  public float intersectRay(Ray ray, PVector result, boolean DEBUG, boolean isShadowRay){
    this.lastTime = ray.timeStamp;
    //this.position = PVector.add( this.start ,PVector.sub(this.end, this.start).mult(ray.timeStamp));
    
   
    return super.intersectRay(ray,result,DEBUG, isShadowRay);
  }
  
    //public PVector getSurfaceNormalAtPt(PVector pt){
    //  this.position = PVector.add( this.start ,PVector.sub(this.end, this.start).mult(lastTime));
    //  return super.getSurfaceNormalAtPt(pt);
    //}
  
  
  public PVector getPosition(){
    return PVector.add( this.start ,PVector.sub(this.end, this.start).mult(lastTime));
  
  }
  
    public void transform(PMatrix3D t){

    float scale = t.m33;
    
    PVector result1 = new PVector(0,0,0);
    PVector result2 = new PVector(0,0,0);
    
    this.start = t.mult(this.start, result1);
    this.end = t.mult(this.end, result2);
    
    this.radius*=scale;
  }
  

  
   public String toString(){
    return "Moving Sphere : { start: "+ start+", end: " + end + " R:" + radius +" Material :"+this.mat +" } ";
  }
}