//Data Structue to hold a ray
public class Ray{
  
  public PVector origin;
  public PVector direction;
  
  public Ray(PVector origin, PVector direction){
    this.origin = origin;
    this.direction = direction;
    
  }
  
  public void setEndPoint(PVector point){
    this.direction = PVector.sub(point, this.origin).normalize();
  }
  
  public Ray reflect(PVector normal, PVector hitPoint){
     
    PVector reflected = Reflect2(this.direction, normal);
    
    this.direction.set(reflected.x, reflected.y, reflected.z);

    this.origin.set(hitPoint.x, hitPoint.y, hitPoint.z);
    
    return this;
  }
  
  public Ray refract(SceneObject obj){
    ////Refract Once
    //this.origin = hitPt.add(normal.copy().mult(0.1));
    //this.direction = Refract(this.direction, normal, ((SpecularMaterial)(hitObject.getMaterial())).getRefractiveIndex());
    
    ////Intersect with the other side
    //PVector result = new PVector(0,0,0);
    //hitObject.intersectRay(this, result);
    
    //PVector newNormal = hitObject.getSurfaceNormalAtPt(result);
    //this.origin = result;
    
    ////refract again
    //this.direction = Refract(this.direction, newNormal.copy().mult(1) , 1 / ((SpecularMaterial)(hitObject.getMaterial())).getRefractiveIndex());
    
    Ray refract = obj.getRefractedRay(this);
    this.origin = refract.origin;
    this.direction = refract.direction;
    return this;
  }
  
  public Ray clone(){
    return new Ray(this.origin.copy(), this.direction.copy());
  }
  
  public String toString(){
    return "Ray: { origin: " + origin.x +" " + origin.y + " " + origin.z +" , direction: " + direction.x + " " + direction.y + " " + direction.z + " }";
  }


}