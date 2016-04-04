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


public class StoneTexture implements Texture{
  
  public PVector min;
  public PVector max;
  public int numStones;
  RGB filler;
  RGB tileMain;
  RGB tileDust;
  
  public StoneTexture(PVector min, PVector max, int stones){
    this.min = min;
    this.max = max;
    this.numStones = stones;
    
    
    this.filler = new RGB(0.8,0.8,0.8);
    this.tileMain =  new RGB( 255.0f/255.0f,51.0f/255.0f,0.0f/255.0f);
    this.tileDust =  new RGB( 102.0f/255.0f,51.0f/255.0f,0.0f/255.0f);
  }
  
   public RGB getTexColor(float u, float v, float w){
     randomSeed(this.numStones);
     PVector pt = new PVector(u,v,w);
     
     float min = 99999.0f;

     for( int i = 0 ; i < this.numStones; i++){
       PVector rand = getRandomPoint();
      
       float dist = pt.dist(rand);
       if( dist < min ){
         min = dist;
       }
     }
     
     
     randomSeed(this.numStones);
     float min2 =99999.0f;
     for( int i = 0 ; i < this.numStones; i++){
       PVector rand = getRandomPoint();
      
       float dist = pt.dist(rand);
       if( dist < min2 && dist !=min){
         min2 = dist;
       }
     }
     
     if( abs(min -min2) < 0.01) return getFillerColor(pt);
     
     return getTileColor(pt);
   }
   
   private RGB getTileColor(PVector pt){
     float noise = (noise_3d(pt.x * 5, pt.y *5 , pt.z *5) + 1)/2 ;
     return tileMain.clone().mult(noise).add(tileDust.clone().mult(1 - noise));
   }
   
   private RGB getFillerColor(PVector pt){
     float noise = (noise_3d(pt.x * 35, pt.y* 35 , pt.z *35) + 1)/2 + 0.3f ;
     return filler.clone().mult(noise);
   }
   
   private PVector getRandomPoint(){
     PVector ret = new PVector(0,0,0);
     ret.x = random(min.x, max.x);
     ret.y = random(min.y, max.y);
     ret.z = random(min.z, max.z);
     
     return ret;
   }
}