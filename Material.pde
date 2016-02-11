//Base class for differnt types of material
public interface Material{
  //Different implementations of materials will use different getRenderColor()
  public RGB getRenderColor(PVector intersectPt, PVector surfaceNormal, Scene scene, Ray ray, SceneObject obj, boolean DEBUG);
  public boolean spawnsSecondary();
}


public class DiffuseMaterial implements Material{

  RGB diffuseColor;
  RGB ambientColor;
  
  public DiffuseMaterial(RGB diffuseColor, RGB ambientColor){
    this.diffuseColor = diffuseColor;
    this.ambientColor = ambientColor;
  }
  
  public RGB getRenderColor(PVector intersectPt, PVector surfaceNormal, Scene scene, Ray ray, SceneObject obj, boolean DEBUG){
    
    RGB finalColor = new RGB(0,0,0);
    
    for(Light l : scene.getLights()){
     PVector toLight = PVector.sub(l.getPosition(), intersectPt).normalize();
     float factor = surfaceNormal.dot(toLight);
     if ( factor < 0 ) factor = 0;
     
     RGB currColor = diffuseColor.clone().dot(l.getColor()).mult(factor);
     
     
     
     RGB shadowResult = isShadow(intersectPt, toLight, scene, obj, DEBUG);
     currColor.dot(shadowResult);
     finalColor.add(currColor);
     
     
    }
    finalColor.add(ambientColor);
    //clone().dot(l.getColor()));
    return finalColor;
  
  }
  
  public boolean spawnsSecondary(){
    return false;
  }
  

  
  public String toString(){
    return "DiffuseMaterial: { diffuseColor:"+this.diffuseColor+", ambientColor:"+this.ambientColor+"}";
  }
  
}

public class SpecularMaterial implements Material {
  
  DiffuseMaterial baseMat;
  RGB specColor;
  float specExp;
  float kRefl;
  float kTrans;
  float rIndex;
  
  public SpecularMaterial(RGB diffuseColor, RGB ambientColor, RGB specColor, float specExp, float kRefl, float kTrans, float rIndex){
    this.baseMat = new DiffuseMaterial(diffuseColor, ambientColor);
    this.specColor = specColor;
    this.specExp = specExp;
    this.kRefl = kRefl;
    this.kTrans = kTrans;
    this.rIndex = rIndex;

  }
  
  public RGB getRenderColor(PVector intersectPt, PVector surfaceNormal, Scene scene, Ray ray, SceneObject obj, boolean DEBUG){
    
    RGB diffuseComp = baseMat.getRenderColor(intersectPt, surfaceNormal,scene, ray, obj, DEBUG);
    
    RGB specComp = new RGB(0,0,0);
    for(Light l : scene.getLights()){
      PVector toLight = PVector.sub(l.getPosition(), intersectPt).normalize();
      PVector R = Reflect(toLight, surfaceNormal);
      float ref = Math.max(0, R.dot(ray.direction.copy().mult(-1)));
      float factor = pow(ref, specExp);
     
      specComp.add(specColor.clone().mult(factor));
      
      specComp.dot(isShadow(intersectPt, toLight, scene, obj, DEBUG));
    }
 
    
    
    //Ray reflected = ray.clone().reflect(surfaceNormal, intersectPt);
    //Ray refracted = ray.clone().refract(surfaceNormal, intersectPt, obj);
    
    //RGB reflectedColor = RayTraceScene(reflected, scene, obj);
    //RGB refractedColor = RayTraceScene(refracted, scene, obj);
    
    //return diffuseComp.add(specComp).add(reflectedColor.mult(kRefl)).add(refractedColor.mult(kTrans));
    //return diffuseComp.add(specComp);
    
    return diffuseComp.add(specComp);
  }
  
  
  public boolean spawnsSecondary(){
    return true;
  }
  
  public float getRefractiveIndex(){
    return rIndex;
  }
  
  public float getKRefl(){
    return kRefl;
  }
  
  public float getKTrans(){
    return kTrans;
  }

  
  public String toString(){
      return "DiffuseComponent : " + this.baseMat + " SpecColor :  " + this.specColor + " Exp : " + this.specExp + " KRefl : " + kRefl + " KTrans : " + kTrans + " RIndex : " + rIndex;
  
  }

}