//Data Structue to hold a ray
public class Ray{
  
  public PVector origin;
  public PVector direction;
  private float timeStamp;
  
  public Ray(PVector origin, PVector direction){
    this.origin = origin;
    this.direction = direction;
    timeStamp = 0;
    
  }
  
  public void setEndPoint(PVector point){
    this.direction = PVector.sub(point, this.origin);//.normalize();
  }
  
  public Ray reflect(PVector normal, PVector hitPoint){
     
    PVector reflected = Reflect2(this.direction, normal);
    
    this.direction.set(reflected.x, reflected.y, reflected.z);

    this.origin.set(hitPoint.x, hitPoint.y, hitPoint.z);
    
    return this;
  }
  
  public void setTimestamp(float t){
    this.timeStamp = t;
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
  
  public void randomlyBlur(float lensRadius, float focalDistance){
    float t = -1 * (focalDistance)/this.direction.z;
    
    PVector endPoint = PVector.add(this.origin, this.direction.copy().mult(t));
    PVector randVec = new PVector(random(1) -0.5f, random(1) - 0.5f ,0).mult(lensRadius);
   
    this.origin = randVec;//(randVec.x, randVec.y, randVec.z);
    //print(endPoint);
    this.direction = PVector.sub(endPoint, randVec).normalize();
    
  
  }
  
  public Ray transform(PMatrix3D mat){
    PVector newOrigin = new PVector(0,0,0);
    newOrigin = mat.mult(this.origin, newOrigin);
    

    PMatrix3D matC = mat.get();
    
  
    matC.transpose();
    
    PVector newDirection = new PVector(0,0,0);
    
    newDirection = matC.mult(this.direction,newDirection);

    //newDirection.normalize();
    //PVector oldEndPt = PVector.add(this.origin, this.direction);
    //PVector newEndPt = new PVector(0,0,0);
    //newEndPt = mat.mult(oldEndPt, newEndPt);
    //newEndPt.sub(newOrigin).normalize();
    return new Ray(newOrigin,newDirection);
  }
  
  public String toString(){
    return "Ray: { origin: " + origin.x +" " + origin.y + " " + origin.z +" , direction: " + direction.x + " " + direction.y + " " + direction.z + " }";
  }


}