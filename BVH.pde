import java.util.Comparator;

public class BVHReturn{
  public SceneObject finalObj;
  public float t;
  
  public BVHReturn(SceneObject o, float t){
    this.finalObj = o;
    this.t = t;
  }
}

int MAX_TREE_DEPTH = 20;
Comparator<SceneObject> objCompX = new Comparator<SceneObject>(){

  public int compare(SceneObject obj1, SceneObject obj2){
   
    float n1 = obj1.getBBoxMax().x;
    float n2 = obj2.getBBoxMax().x;
    if ( n1 == n2 ) return 0;
    else if ( n1 > n2) return 1;
    else return -1;
  
  }

};


Comparator<SceneObject> objCompY = new Comparator<SceneObject>(){

  public int compare(SceneObject obj1, SceneObject obj2){
   
    float n1 = obj1.getBBoxMax().y;
    float n2 = obj2.getBBoxMax().y;
    if ( n1 == n2 ) return 0;
    else if ( n1 > n2) return 1;
    else return -1;
  
  }

};

Comparator<SceneObject> objCompZ = new Comparator<SceneObject>(){

  public int compare(SceneObject obj1, SceneObject obj2){
   
    float n1 = obj1.getBBoxMax().z;
    float n2 = obj2.getBBoxMax().z;
    if ( n1 == n2 ) return 0;
    else if ( n1 > n2) return 1;
    else return -1;
  
  }

};

char[] SplitAxis = { 'x', 'y', 'z' };

PVector _garbage = new PVector();



class BVHNode{

  public BVHNode left;
  public BVHNode right;
  public ListObject nodeObj;
  public BoundingBox bbox;
  
  public BVHNode(ListObject obj){
    this.left = null;
    this.right = null;
    
    this.nodeObj = obj;
    
    
    PVector objMax = obj.getBBoxMax();
    PVector objMin = obj.getBBoxMin();
    this.bbox = new BoundingBox(objMin.x, objMin.y, objMin.z, objMax.x, objMax.y, objMax.z);
  }
  
  public BVHNode(BVHNode n1, BVHNode n2){
    this.nodeObj = new ListObject();
    if( n1!=null){
      for( SceneObject obj : n1.nodeObj.objects ){
        nodeObj.addObject(obj);
      }
    }
    
    if( n2 != null ){
      for( SceneObject obj : n2.nodeObj.objects ){
        nodeObj.addObject(obj);
      }
    }
    
    this.left = null;
    this.right = null;
    PVector objMax = nodeObj.getBBoxMax();
    PVector objMin = nodeObj.getBBoxMin();
    nodeObj.initBBox();
    this.bbox = new BoundingBox(objMin.x, objMin.y, objMin.z, objMax.x, objMax.y, objMax.z);
    
  }
  
  public float intersectRay(Ray ray,PVector result, boolean DEBUG, boolean isShadowRay){
    return this.bbox.intersectRay(ray,result,DEBUG,isShadowRay);
  }
  
  public BVHNode merge(BVHNode n){
    this.nodeObj.merge(n.nodeObj);
    PVector objMax = nodeObj.getBBoxMax();
    PVector objMin = nodeObj.getBBoxMin();
    this.bbox = new BoundingBox(objMin.x, objMin.y, objMin.z, objMax.x, objMax.y, objMax.z);
    return this;
  }
  
  public boolean isLeaf(){
    return (left == null && right ==null);
  }
  
  //Usable only when Node is a leaf node
  public BVHReturn getFinalIntersectingObject(Ray ray,PVector result, boolean DEBUG, boolean isShadowRay){
     float t = this.nodeObj.intersectRay(ray,result,DEBUG,isShadowRay);
     SceneObject hit = this.nodeObj.lastQueried;
     return new BVHReturn(hit,t);
  }
  
  
  public void splitNode(int splitAxis){
    char axis = SplitAxis[splitAxis];
    
    
    ListObject leftObj = new ListObject();
    ListObject rightObj = new ListObject();
    
    float splitVal = getMedianSplit(axis);
    
   // println("Splitting along :" + axis + " with value " + splitVal);  
    for ( SceneObject obj : this.nodeObj.objects ){
      float max = -1.0f;
      float min = -1.0f;
      
      if ( axis == 'x' ){
         max = obj.getBBoxMax().x;
         min = obj.getBBoxMin().x;
      }else if ( axis == 'y' ){
         max = obj.getBBoxMax().y;
         min = obj.getBBoxMin().y;
      }else {
         max = obj.getBBoxMax().z;
         min = obj.getBBoxMin().z;
      }
      
      //Completely left of border
     if  ( min > splitVal ){
        rightObj.addObject(obj);
      }
      //Lies on border
      else{
        leftObj.addObject(obj);
        //rightObj.addObject(obj);
      }
    }
    leftObj.initBBox();
    rightObj.initBBox();
     
    // leftObj.setMaterial(_debugGreen);
     
    left = new BVHNode(leftObj);
    right = new BVHNode(rightObj);
    
    //println("Left Split Size:" + left.numObjects());
    //println("Right Split Size:" + right.numObjects());
    
    if ( left.numObjects() == 0 ) left = null;
    if ( right.numObjects() == 0 ) right = null;
    
    
    //Clear object in this node
    this.nodeObj = null;
    
    
    
  }
  
  public float getMedianSplit(char axis){
    
    
    
    if ( axis == 'x' ){
     Collections.sort(nodeObj.objects, objCompX);
     int i = nodeObj.objects.size()/2;
      return (nodeObj.objects.get(i).getBBoxMax().x);
    }else if ( axis == 'y' ){
     Collections.sort(nodeObj.objects, objCompY);
      int i = nodeObj.objects.size()/2;
      return (nodeObj.objects.get(i).getBBoxMax().y);
    }else {
      Collections.sort(nodeObj.objects, objCompZ);
       int i = nodeObj.objects.size()/2;
      return (nodeObj.objects.get(i).getBBoxMax().z);
    }
  }
  
  public int numObjects(){
    return nodeObj.objects.size();
  }
  
}


class BVHTree{

  BVHNode head;
  
  public BVHTree(ListObject obj){
    head =  new BVHNode(obj);
  }
  
  public void build(){
    _buildRecur(head,0,0);
  
  }
  
   public BVHReturn intersect( Ray ray, PVector retIntersectPt, boolean DEBUG, boolean isShadowRay){
    BVHNode leaf = _findLeafRecur(ray, head,DEBUG,isShadowRay);
    if ( leaf == null  ) return new BVHReturn(null,MISSED);
    return leaf.getFinalIntersectingObject(ray,retIntersectPt,DEBUG,isShadowRay);
  }
  
  private BVHNode _findLeafRecur(Ray ray, BVHNode node, boolean DEBUG, boolean isShadowRay){
    if ( node.intersectRay(ray,_garbage,DEBUG,isShadowRay) != MISSED){
      if ( node.isLeaf () ){
        return node;
      }
      
      float left = MISSED;
      float right = MISSED;
      
      if ( node.left != null )
       left = node.left.intersectRay(ray,_garbage,DEBUG,isShadowRay);
       
      if( node.right != null ) 
        right = node.right.intersectRay(ray,_garbage,DEBUG,isShadowRay);
      
      ////Pick left if hits both
      if( left == MISSED && right == MISSED){
       return null; 
      }
      else{
        if ( left != MISSED && right == MISSED ){
         return _findLeafRecur(ray, node.left, DEBUG, isShadowRay);
        }
        else if ( right != MISSED && left == MISSED)
        {
          return _findLeafRecur(ray, node.right, DEBUG, isShadowRay);
         }
        else {
          BVHNode n1=  _findLeafRecur(ray, node.left, DEBUG, isShadowRay);

          BVHNode n2= _findLeafRecur(ray, node.right, DEBUG, isShadowRay);
           return new BVHNode(n1,n2);
        }
      
      }
      
    }else{
    
      return null;
    }
  }
  
  private float getAxisWidth(BVHNode node, int axis){
    char axisC = SplitAxis[axis];
    if ( axisC =='x'){
      return node.bbox.getBBoxMax().x - node.bbox.getBBoxMin().x;
    }
    
    if ( axisC =='y'){
      return node.bbox.getBBoxMax().y - node.bbox.getBBoxMin().y;
    }
    
   
      return node.bbox.getBBoxMax().z - node.bbox.getBBoxMin().z;
    
  }
  
  private void _buildRecur(BVHNode node, int axis, int depth){
    //println("Number of objects to split :" + node.numObjects());
    if ( node != null){
      if ( node.numObjects()> 5 && depth < MAX_TREE_DEPTH){
        node.splitNode(axis);
        
        axis = (axis + 1)%3;
        
        depth++;
        _buildRecur(node.left, axis,depth);
        _buildRecur(node.right, axis,depth);
      
      }
      
    }
  }
  
}