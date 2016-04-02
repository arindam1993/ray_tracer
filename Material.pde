//Base class for differnt types of material
public interface Material{
  //Different implementations of materials will use different getRenderColor()
  public RGB getRenderColor(PVector intersectPt, PVector surfaceNormal, Scene scene, Ray ray, SceneObject obj, boolean DEBUG);
  public boolean spawnsSecondary();
  
  public void setTexture(Texture t);
  public Texture getTexture();
}


public class DiffuseMaterial implements Material{

  RGB diffuseColor;
  RGB ambientColor;
  
  Texture tex;
  
  public DiffuseMaterial(RGB diffuseColor, RGB ambientColor){
    this.diffuseColor = diffuseColor;
    this.ambientColor = ambientColor;
    
    tex = new NoTexture();
  }
  
  public RGB getRenderColor(PVector intersectPt, PVector surfaceNormal, Scene scene, Ray ray, SceneObject obj, boolean DEBUG){
    
    RGB finalColor = new RGB(0,0,0);
    
    for(Light l : scene.getLights()){
     PVector toLight = PVector.sub(l.getPosition(), intersectPt).normalize();
     float factor = surfaceNormal.dot(toLight);
     if ( factor < 0 ) factor = 0;
     
     RGB currColor = diffuseColor.clone().dot(l.getColor()).mult(factor);
     
     
     
     //RGB shadowResult = isShadow(intersectPt, toLight, scene, obj, DEBUG);
     //currColor.dot(shadowResult);
     l.getShadowColor(currColor,intersectPt,scene,obj,DEBUG);
     finalColor.add(currColor);
     
     
    }
    
    RGB texColor = tex.getTexColor(intersectPt.x, intersectPt.y, intersectPt.z);
    finalColor.add(ambientColor).dot(texColor);
    //clone().dot(l.getColor()));
    return finalColor;
  
  }
  
  public boolean spawnsSecondary(){
    return false;
  }
  
  public void setTexture(Texture t){
    this.tex = t;
  }
  public Texture getTexture(){
    return tex;
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
  Texture tex;
  
  public SpecularMaterial(RGB diffuseColor, RGB ambientColor, RGB specColor, float specExp, float kRefl, float kTrans, float rIndex){
    this.baseMat = new DiffuseMaterial(diffuseColor, ambientColor);
    this.specColor = specColor;
    this.specExp = specExp;
    this.kRefl = kRefl;
    this.kTrans = kTrans;
    this.rIndex = rIndex;
    
    this.tex= new NoTexture();

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
    RGB texColor = tex.getTexColor(intersectPt.x, intersectPt.y, intersectPt.z);
    
    return diffuseComp.add(specComp).dot(texColor);
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

   public void setTexture(Texture t){
    this.tex = t;
  }
  public Texture getTexture(){
    return tex;
  }
  
  public String toString(){
      return "DiffuseComponent : " + this.baseMat + " SpecColor :  " + this.specColor + " Exp : " + this.specExp + " KRefl : " + kRefl + " KTrans : " + kTrans + " RIndex : " + rIndex;
  
  }

}