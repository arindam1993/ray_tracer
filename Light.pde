//Data Structure to store Lights
//Only Point lights for now
public class Light{

  PVector position;
  RGB lColor;
  
  public Light(PVector position, RGB lColor){
    this.position = position;
    this.lColor = lColor;
  }
  
  public PVector getPosition(){
    return position;
  }
  
  public RGB getColor(){
    return lColor;
  }
  
  public String toString(){
    return "Light: { x:"+ position.x+" y: "+ position.y+" z:"+ position.z+ " Color: " + lColor + " }";
  }
}