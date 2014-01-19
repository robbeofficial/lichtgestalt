class Display {
  final int[] off = {255,255,255,8}; // clear color (including minumum alpha)
  final int on = 192; // maximum alpha  
  
  // voxel display
  int w,h,d;
  Voxel[][][] voxels;
  
  // render state
  float[][] T;
  Stack<float[][]> matrixStack; // 
  int r,g,b,a;
  
  public Display(List<DiffuserPatch> patches, int w,int h,int d, float s, float px,float py,float pz) {
    // create volumetric display
    this.w = w; this.h = h; this.d = d;
    voxels = new Voxel[w][h][d];
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        for (int z=0; z<d; z++) {
          voxels[x][y][z] = new Voxel(patches, px+(x-w/2)*100,py+(y-h/2)*100,pz+(z-d/2)*100, 97);
        }
      }
    }
    
    // init render state
    matrixStack = new Stack<float[][]>();
    setColor(255,255,255);
    setAlpha(1);
    clear();  
  }
  
  // boundary-safe
  private void setVoxel(int x, int y, int z, int r,int g,int b,int a) {
    if (x>=0 && x<w && y>=0 && y<h && z>=0 && z<d) {
      voxels[x][y][z].setColor(r,g,b,a);
    }
  }  
  
  void setColor(int r, int g, int b) {
    this.r = r; this.g = g; this.b = b;
  }
  
  void setClear() {
    setColor(off[0],off[1],off[2]);
    setAlpha(0);   
  }
  
  void setAlpha(float alpha) {
    float max = on, min = off[3];
    a = (int) map(alpha, 0,1, min,max);  
  }
  
  void pushMatrix() {
    matrixStack.push(T);  
  }
  
  void popMatrix() {
    T = matrixStack.pop();  
  }
  
  void translate(float tx, float ty, float tz) {
    T = multiply(T, translation(tx,ty,tz));
  }
  
  void rotateX(float phi) {
    T = multiply(T, rotX(phi));
  }
  
  void rotateY(float phi) {
    T = multiply(T, rotY(phi));
  }
  
  void rotateZ(float phi) {
    T = multiply(T, rotZ(phi));
  }  

  void resetMatrix() {
    T = identity();
  }  
  
  void voxel() {
    int x = (int)(T[0][3]/T[3][3]+0.5); 
    int y = (int)(T[1][3]/T[3][3]+0.5);
    int z = (int)(T[2][3]/T[3][3]+0.5);
    setVoxel(x,y,z, r,g,b,a);
  }
  
  // solid rectangle (drawing supersampled voxels)
  void rect(int w, int h) {
    pushMatrix();    
    for (int x=0; x<2*w; x++) {      
      for (int y=0; y<2*h; y++) {
         voxel();
         translate(0,.5,0);
      }      
      translate(.5,-w,0);
    }
    /*for (int y=0; y<h; y++) {
      translate(0,1,0); voxel(0,128,128);
    }    
    for (int x=0; x<w; x++) {
      translate(-1,0,0); voxel(0,128,128);
    }    
    for (int y=0; y<h; y++) {
      translate(0,-1,0); voxel(0,128,128);
    } 
 */   
    popMatrix();
  }
  
  void cube(int s) {
    pushMatrix();
    translate(-s/2,-s/2,s/2);
    rect(s,s);
    translate(0,0,-s);    
    rect(s,s);
    popMatrix();
    
    pushMatrix();
    rotateX(PI/2);
    translate(-s/2,-s/2,s/2);
    rect(s,s);
    translate(0,0,-s);    
    rect(s,s);
    popMatrix();
    
    pushMatrix();
    rotateY(PI/2);
    translate(-s/2,-s/2,s/2);
    rect(s,s);
    translate(0,0,-s);    
    rect(s,s);
    popMatrix();    
  }  
  
  // solid cube
  void __cube(int s) {
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        for (int z=0; z<d; z++) {
          
          // nope: 
          //PVector a = transform(T, new PVector(0,0,0));
          //PVector b = transform(T, new PVector(s,s,s));
          //if (x>=a.x && x<b.x && y>=a.y && y<b.y && z>=a.z && z<b.z) {
          //  voxels[x][y][z].setColor(255,0,0,192);
          //}
        }
      }
    }
  }
  
  // solid sphere
  void sphere(float px, float py, float pz, float r) {
    for (int x=0; x<w; x++) {
      for (int y=0; y<h; y++) {
        for (int z=0; z<d; z++) {
          float dx = px-x, dy = py-y, dz = pz-z;
          float dsq = dx*dx + dy*dy + dz*dz;
          if (dsq <= r*r) {
            voxels[x][y][z].setColor(255,0,0,192);  
          }
        }
      }
    }
  }
  
  void clear() {
    T = identity();
    for (int x=0; x<w; x++)
      for (int y=0; y<h; y++)
        for (int z=0; z<d; z++)
          voxels[x][y][z].setColor(off[0],off[1],off[2],off[3]);
  }
}

class Voxel {
  DiffuserPatch top, bottom, left, right, front, back; 
  
  Voxel(List<DiffuserPatch> patches, float x, float y, float z, float s) {
    front = new DiffuserPatch(x,y,z+s/2, s,s, 0,0,0);
    back = new DiffuserPatch(x,y,z-s/2, s,s, 0,0,0);
    
    right = new DiffuserPatch(x+s/2,y,z, s,s, 0,PI/2,0);
    left = new DiffuserPatch(x-s/2,y,z, s,s, 0,PI/2,0);

    top = new DiffuserPatch(x,y+s/2,z, s,s, PI/2,0,0);
    bottom = new DiffuserPatch(x,y-s/2,z, s,s, PI/2,0,0); 
 
    patches.add(top); patches.add(bottom); patches.add(left); patches.add(right); patches.add(front); patches.add(back);  
  }
  
  void setColor(int r, int g, int b, int a) {
    top.setColor(r,g,b,a);
    bottom.setColor(r,g,b,a);
    left.setColor(r,g,b,a);
    right.setColor(r,g,b,a);
    front.setColor(r,g,b,a);
    back.setColor(r,g,b,a);
  }
}
