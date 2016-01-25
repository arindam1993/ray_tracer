
//Data Structure to store color
public class RGB{
  public float r;
  public float g;
  public float b;
  
  public RGB(float r, float g, float b){
    this.set(r,g,b);
  }
  
  public void set(float r, float g, float b){
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  public void copyTo(RGB c){
    this.r = c.r;
    this.g = c.g;
    this.b = c.b;
  }
  
  public RGB add(RGB c){
    this.r += c.r;
    this.g += c.g;
    this.b += c.b;
    return this;
  }
  
  public RGB mult(float f){
    this.r*=f;
    this.g*=f;
    this.b*=f;
    return this;
  }
  
  public RGB dot(RGB c){
    this.r*=c.r;
    this.g*=c.g;
    this.b*=c.b;
    return this;
  }
  
  public RGB clone(){
   return new RGB(this.r, this.g, this.b);
  }
  
  public int getPColor(){
    return color(r, g, b );
  }
  
  public String toString(){
    return "RGB("+r+","+g+","+b+")";
  }
  
  public boolean equals(RGB other){
    if( other.r == this.r && other.g == this.g && other.b == this.b) return true;
    
    return false;
  }
  
  
}

public RGB MakeColor(float r, float g, float b){
  return new RGB(r,g,b);
}

public  RGB GetPixelColor(int x, int y){
    color pix = get(x,y);
    return new RGB(red(pix), green(pix), blue(pix));
  }