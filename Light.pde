//Data Structure to store Lights
//Only Point lights for now


public interface Light{

  public PVector getPosition();
  public RGB getColor();
   public void getShadowColor(RGB nonShadowColor, PVector intersectPt,Scene scene, SceneObject obj, boolean DEBUG);
  
}
public class PointLight implements Light{

  PVector position;
  RGB lColor;
  
  public PointLight(PVector position, RGB lColor){
    this.position = position;
    this.lColor = lColor;
  }
  
  public PVector getPosition(){
    return position;
  }
  
  public RGB getColor(){
    return lColor;
  }
  
  public void getShadowColor(RGB nonShadowColor, PVector intersectPt,Scene scene, SceneObject obj, boolean DEBUG){
    PVector toLight = PVector.sub(this.getPosition(), intersectPt).normalize();
    RGB shadowResult = isShadow(intersectPt, toLight, scene, obj, DEBUG);
    nonShadowColor.dot(shadowResult);
  }
  
  public String toString(){
    return "Light: { x:"+ position.x+" y: "+ position.y+" z:"+ position.z+ " Color: " + lColor + " }";
  }
}


public class DiscLight implements Light{

  PVector position;
  RGB lColor;
  PVector normal;
  float radius;
  ArrayList<PVector> samplePoints;
  
  public DiscLight(PVector position, float radius, PVector normal, RGB lColor){
    this.position = position;
    this.radius = radius;
    this.normal = normal;
    this.lColor = lColor;
    samplePoints = new ArrayList<PVector>();
    getRadialSamplesInPlane(10, position, normal, radius,samplePoints);
  }

  public PVector getPosition(){
    return position;
  }
  
  public RGB getColor(){
    return lColor;
  }

  public void getShadowColor(RGB nonShadowColor, PVector intersectPt,Scene scene, SceneObject obj, boolean DEBUG){
    //PVector toLight = PVector.sub(this.getPosition(), intersectPt).normalize();
    //RGB shadowResult = isShadow(intersectPt, toLight, scene, obj, DEBUG);
    
    RGB avgShadow = new RGB(0,0,0);
    for ( PVector sample : samplePoints ){
      PVector toLight = PVector.sub(sample, intersectPt).normalize();
      avgShadow.add(isShadow(intersectPt, toLight, scene, obj, DEBUG));
      
    }
    
    if ( samplePoints.size() > 0 ){
      if( DEBUG) println("TOTAL:" + avgShadow);
      avgShadow.mult(1/float(samplePoints.size()));
      if( DEBUG) println("AVG:" + avgShadow);
      nonShadowColor.dot(avgShadow);
    }
  }
  
  public String toString(){
    return "Light: { x:"+ position.x+" y: "+ position.y+" z:"+ position.z+ " Color: " + lColor + " }";
  }
  
  
}