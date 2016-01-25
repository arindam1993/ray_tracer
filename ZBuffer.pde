float[][] ZBuffer;

void initZbuffer(){
  ZBuffer =  new float[width][height];
  for(int i=0;i<width;i++){
  
    for(int j=0; j<height;j++){
    
      ZBuffer[i][j] = 999999.0f;
    }
  }
}