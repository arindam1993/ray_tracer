public interface Texture{
  public RGB getTexColor(float u, float v, float w);
}
 
public class NoTexture implements Texture{

  public RGB getTexColor(float u, float v, float w){
    return new RGB(1,1,1);
  }
}


public class NoiseTexture implements Texture{

  float scale;
  
  public NoiseTexture(float scale){
    this.scale= scale;
  }
  
   public RGB getTexColor(float u, float v, float w){
   
     float noise = noise_3d(u*scale,v*scale,w*scale) ;
     noise =( noise +1 )/2;
     return new RGB(1,1,1).mult(noise);
   }
}

public class WoodTexture implements Texture{
  
  PVector axis;
  PVector origin;

  RGB woodLow;
  RGB woodHigh;
  public WoodTexture(PVector axis, PVector origin){
    this.axis = axis;
    this.origin = origin;
    
    this.woodLow = new RGB( 186.0f/255.0f,130.0f/255.0f,39.0f/255.0f);
    this.woodHigh = new RGB( 115.0f/255.0f,64.0f/255.0f,23.0f/255.0f);
  }
  
  /*public RGB getTexColor(float u, float v, float w){
    float t = getDistanceFromAxis(new PVector(u,v,w));
    t+=noise(t*5);
    float tP = t%1.0f;
   
    //print(tP +" ");
    return woodLow.clone().add((woodHigh.clone().sub(woodLow)).mult(tP));
    
  }
  
  private float getDistanceFromAxis(PVector pt){
    PVector localPt = PVector.sub(pt, origin);
    float ptProj = localPt.dot(axis);
    
    float angle = PVector.angleBetween(PVector.add(origin,axis.copy().mult(ptProj)).sub(pt), new PVector(0,1,0));
    
    float distance = PVector.add(origin,axis).mult(ptProj).sub(pt).mag();
    return distance + noise(angle/(PI));
  }*/
  
  
    public RGB getTexColor(float u, float v, float w){
    float dist = getDistanceFromAxis(new PVector(u,v,w))  ;
   
    dist+=noise(dist*2);
   
    float t = (sin(dist*(20*PI))+1.0f)*0.5f;

    return woodLow.clone().add((woodHigh.clone().sub(woodLow)).mult(t));
  }
  
   private float getDistanceFromAxis(PVector pt){
    PVector localPt = PVector.sub(pt, origin);
    float ptProj = localPt.dot(axis);
    
    float angle = PVector.angleBetween(PVector.add(origin,axis.copy().mult(ptProj)).sub(pt), new PVector(0,1,0));
    float distance = PVector.add(origin,axis.copy().mult(ptProj)).sub(pt).mag();
    return distance + noise(angle/(2*PI));
  }
}

public class MarbleTexture implements Texture{
  
  PVector axis;
  PVector origin;
  
  RGB marbleLow ;
  RGB marbleHigh;
  public MarbleTexture(PVector axis, PVector origin){
    this.axis = axis;
    this.origin = origin;
      
    this.marbleLow = new RGB(0,0,0);
    this.marbleHigh = new RGB(1,1,1);
}
  
  public RGB getTexColor(float u, float v, float w){
    float dist = getDistanceFromAxis(new PVector(u,v,w)) + noise(u*2,v*2,w*2) ;
   
   dist+=noise(dist*5);
   
    float t = (sin(dist*(15*PI + noise(dist) ))+1.0f)*0.5f;
    print(t + " ");
    
    return marbleHigh.clone().mult(t);
  }
  
   private float getDistanceFromAxis(PVector pt){
    PVector localPt = PVector.sub(pt, origin);
    float ptProj = localPt.dot(axis);
    
    float angle = PVector.angleBetween(PVector.add(origin,axis.copy().mult(ptProj)).sub(pt), new PVector(0,1,0));
    float distance = PVector.add(origin,axis.copy().mult(ptProj)).sub(pt).mag();
    return distance + noise(angle/(2*PI));
  }
}