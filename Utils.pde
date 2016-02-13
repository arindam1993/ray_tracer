public void SetPixel(int w, int h, int c){
pixels[(h*w+w)] = c;
updatePixels();
}



//Assumes vector pointing away from the surface
public PVector Reflect(PVector vec, PVector normal){
  return PVector.sub(
    normal.copy().mult(vec.dot(normal) * 2),
    vec
  ).normalize();
}

//Assumes vector pointing towards the surface and normal away
public PVector Reflect2(PVector vec, PVector normal){
  return PVector.sub(
    vec,
    normal.copy().mult(-1).mult(vec.dot(normal.copy().mult(-1)) * 2 )
  );
}

//Assumes vector pointing towards the surface
public PVector Refract(PVector vec, PVector normal, float rIndex){
  float c = normal.dot(vec) * (-1);
  float fact =  rIndex * c - sqrt(1 - rIndex*rIndex*(1 - c*c));
  return PVector.add(vec.copy().mult(rIndex), normal.copy().mult(fact));
}

public class RayTraceReturn{

  public RGB pixColor;
  public float depth;
  
  public RayTraceReturn(RGB pixColor, float depth){
    this.pixColor = pixColor;
    this.depth = depth;
  
  }
}

public RayTraceReturn RayTrace(Ray ray, Scene scene, SceneObject emittedObject , boolean isPrimaryRay, int bounceCt, boolean DEBUG){
  float minDepth = 999999.0f;
  RGB pixColor =new RGB(0,0,0);
  RGB retColor = new RGB(0,0,0);
  retColor.copyTo(scene.getBackground());
  
  RayTraceReturn toRet= new RayTraceReturn(retColor, 999999.0f);
  
  for(SceneObject obj : scene.getSceneObjects()){
    
   if( obj != emittedObject || isPrimaryRay){
     PVector interSectPt = new PVector(0,0,0);
     float depth = obj.getRayColor(pixColor, ray, scene, interSectPt, DEBUG);
     if( depth < minDepth && depth > 0 ){   
         retColor.copyTo(pixColor);
          toRet.depth = depth;
          minDepth = depth;
          
          
          if ( DEBUG ){
            println( "Ray hit : " + obj);
          }
         //Recurse
         
         if( obj.getMaterial().spawnsSecondary()){
            
          PVector surfaceNormal = obj.getSurfaceNormalAtPt(interSectPt);
            
          Ray reflected = ray.clone().reflect(surfaceNormal, interSectPt);
          Ray refracted = ray.clone().refract(obj);
           
          RayTraceReturn reflectedColor = RayTrace(reflected, scene, obj, false, bounceCt, false);
          RayTraceReturn refractedColor = RayTrace(refracted, scene, obj, false, bounceCt, false);
            
            
          retColor.add(reflectedColor.pixColor.mult(((SpecularMaterial)(obj.getMaterial())).getKRefl()));
          retColor.add(refractedColor.pixColor.mult(((SpecularMaterial)(obj.getMaterial())).getKTrans()));
            
         }

      }
    }
  }
  ++bounceCt;
  return toRet;

}

public RGB isShadow(PVector intersectPt, PVector toLight, Scene scene, SceneObject currObj, boolean DEBUG){

  Ray ray = new Ray(intersectPt, toLight.copy().normalize());
  for( SceneObject obj : scene.getSceneObjects()){
    if( obj != currObj){
      PVector res = new PVector(0,0,0);
      if ( obj.intersectRay(ray, res, DEBUG) ){
        if ( DEBUG ){
          println("Shadow Ray hit: "+obj);
          println("by Ray : " + ray + "at " + res);
        }
        return new RGB(0,0,0);
      }
    }
  }
  
  return new RGB(1,1,1);

}

PVector _pixPt = new PVector(0,0,-1);
public Ray getEyeRay(Ray ray, int w, int h){
  
  float px =(float)( w - (width/2)) * (2*scene.viewPlaneScale/width);
  float py =(float)( h - (height/2)) *  (-1 * 2*scene.viewPlaneScale/height);
  _pixPt.set(px,py,-1);
        
  //RGB pixColor = new RGB(0,0,0);
  ray.setEndPoint(_pixPt);
  
  return ray;
}

int getNearestSquareRoot( int n ){
  return int(ceil(sqrt(n)));
}

void getPixelRays(int w, int h, float pixSize, ArrayList<Ray> toRetRays){
  float gridSize = pixSize/getNearestSquareRoot(scene.numRays);
  boolean DEBUG = (w < 5) && (h <5);
  if (DEBUG)
    println(" For " + w + " " + h + " " + gridSize);
  
  float px =(float)( w - (width/2)) * (pixSize);
  float py =(float)( h - (height/2)) *  (-1 * pixSize);
  for ( float offsetX = 0; offsetX < pixSize ; offsetX+= gridSize ){
    for ( float offsetY = 0; offsetY < pixSize ; offsetY+= gridSize ) {
      Ray ray = new Ray(scene.eye, new PVector(0,0,0));
 
      float randXOffset = random(1) * gridSize;
      float randYOffset = random(1) * gridSize;
      
      float _px=px +offsetX + randXOffset;
      float _py=py +offsetY + randYOffset;
      
      //if (DEBUG)
      //  print (" " + offsetX + " " + offsetY + ", ");
      
      _pixPt.set(_px,_py,-1);
      ray.setEndPoint(_pixPt);
      
      toRetRays.add(ray);
      
      //print ( ray + " ");
    }
  }
  if (DEBUG)
    print("\n");

}


public PMatrix3D MakeIdentityMatrix(){
 return new PMatrix3D(1, 0, 0, 0,
                      0, 1, 0, 0,
                      0, 0, 1, 0,
                      0, 0, 0, 1);
}

public PMatrix3D MakeAxisAngleRotationMatrix(float angle, float v0, float v1, float v2){
  PMatrix3D mat =  MakeIdentityMatrix();
  mat.rotate(angle,v0,v1,v2);
  return mat;
}