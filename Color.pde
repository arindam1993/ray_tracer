
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
  
  public RGB sub(RGB c){
    this.r -= c.r;
    this.g -= c.g;
    this.b -= c.b;
    return this;
  }
  
  public RGB mult(float f){
    this.r*=f;
    this.g*=f;
    this.b*=f;
    
    if( this.r > 1.0f) this.r = 1.0f;
    if( this.g > 1.0f) this.g = 1.0f;
    if( this.b > 1.0f) this.b = 1.0f;
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
  
  public RGB negate(){
    this.r = 1 - this.r;
    this.g = 1 - this.g;
    this.b = 1 - this.b;
    return this;
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
  
  public float mag(){
    return sqrt(r*r + g*g + b*b);
  }
  
  
}


RGB WHITE = new RGB(1,1,1);
RGB BLACK = new RGB(0,0,0);

public RGB MakeColor(float r, float g, float b){
  return new RGB(r,g,b);
}

public  RGB GetPixelColor(int x, int y){
    color pix = get(x,y);
    return new RGB(red(pix), green(pix), blue(pix));
  }