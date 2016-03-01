import java.util.*;

public class MatrixStack{

 
  Stack<PMatrix3D> matStack;
  
  public MatrixStack(){
   matStack = new Stack<PMatrix3D>();
   
   matStack.push(new PMatrix3D());
  }
  
  public void push(){
    PMatrix3D top = matStack.peek().get();
    
    matStack.push(top);
    
  }
  
  
   public void pop(){
    
    matStack.pop();
    
  }
  
  
  public void translateTop(float x, float y, float z){
   matStack.peek().translate(x,y,z);
    
  }
  
  
  public void rotateTop(float angle, float x, float y, float z){
   matStack.peek().rotate(angle, x,y,z);
    
  }
  
  public PMatrix3D top(){
  
    return matStack.peek();
  }
  
  public void scaleTop(float x, float y, float z){
   matStack.peek().scale(x,y,z);
    
  }
 

}