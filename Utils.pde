
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

public RayTraceReturn RayTrace(Ray ray, Scene scene, SceneObject emittedObject , boolean isPrimaryRay, int bounceCt){
  float minDepth = 999999.0f;
  RGB pixColor =new RGB(0,0,0);
  RGB retColor = new RGB(0,0,0);
  retColor.copyTo(scene.getBackground());
  
  RayTraceReturn toRet= new RayTraceReturn(retColor, 999999.0f);
  
  for(SceneObject obj : scene.getSceneObjects()){
    
   if( obj != emittedObject | isPrimaryRay){
     PVector interSectPt = new PVector(0,0,0);
     float depth = obj.getRayColor(pixColor, ray, scene, interSectPt);
     if( depth < minDepth && depth > 0 ){   
         retColor.copyTo(pixColor);
          toRet.depth = depth;
          minDepth = depth;
         //Recurse
         if( obj.getMaterial().spawnsSecondary()){
            
            PVector surfaceNormal = obj.getSurfaceNormalAtPt(interSectPt);
            
            Ray reflected = ray.clone().reflect(surfaceNormal, interSectPt);
            Ray refracted = ray.clone().refract(obj);
           
            RayTraceReturn reflectedColor = RayTrace(reflected, scene, obj, false, bounceCt);
            RayTraceReturn refractedColor = RayTrace(refracted, scene, obj, false, bounceCt);
            
            
            retColor.add(reflectedColor.pixColor.mult(((SpecularMaterial)(obj.getMaterial())).getKRefl()));
            retColor.add(refractedColor.pixColor.mult(((SpecularMaterial)(obj.getMaterial())).getKTrans()));
            
         }

      }
    }
  }
  ++bounceCt;
  return toRet;

}