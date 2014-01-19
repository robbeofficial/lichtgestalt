import java.util.*;
import java.awt.Color;

// TODO: processing.js compatibility

List<DiffuserPatch> patches;
Display display;

// view parameters
float rx = 0.06, ry = -0.31, d = -3100.0;
//float rx = 0.06, ry = 0, d = -3100.0;

float alpha = 0.15;

void setup() {
  size(720,480,P3D);  
  noStroke();
  
  rectMode(CENTER);
  perspective(62, (float) width/height, 1, 100000);
  
  // create volumetric display
  patches = new ArrayList<DiffuserPatch>();
  display = new Display(patches, 16,16,16, 100, 0,0,0);
}

void render(Display display) {
  display.clear();
  
  // view
  display.translate(7.5,7.5,7.5);
  display.rotateZ(frameCount / 10.0f);
  display.rotateY(frameCount / 11.0f);
  display.rotateZ(frameCount / 12.0f);

  // drawing
  int rgb = Color.HSBtoRGB(frameCount / 128.0, 1, 1);
  int r = (rgb>>16) & 0xff;
  int g = (rgb>>8) & 0xff;
  int b = (rgb>>0) & 0xff;
  
  display.setColor(r,g,b);
  display.setAlpha(alpha);
  display.cube(10);
}

// mouse orbit
void mouseDragged() {
  final float speed = 100.0;  
  ry -= (mouseX - pmouseX) / speed;
  rx += (mouseY - pmouseY) / speed;
}

void mouseWheel(MouseEvent event) {
  final float speed = 50.0;
  d -= event.getAmount() * speed;  
}

void keyPressed() {
  switch (key) {
    case '+':
      alpha+=0.1;
      alpha = constrain(alpha, 0, 1);
      break;
    
    case '-':
      alpha-=0.1;
      alpha = constrain(alpha, 0, 1);
      break;
      
    case ' ':
      save("screenshot.tiff");
      break;
  }
  
  
}

void draw() {
  background(64);
  
  // update volumentric display
  render(display);
  
  // view matrix
  //float[][] T = translation(-360,-240,-415.9622); // TODO why?
  float[][] T = identity();
  T = multiply(T, translation(0,0,d));
  T = multiply(T, rotX(rx));
  T = multiply(T, rotY(ry));
  
  resetMatrix();
  applyMatrix(T[0][0],T[0][1],T[0][2],T[0][3],
              T[1][0],T[1][1],T[1][2],T[1][3],
              T[2][0],T[2][1],T[2][2],T[2][3],
              T[3][0],T[3][1],T[3][2],T[3][3]);
 
  // update distances to camera
  for (DiffuserPatch patch : patches) {
    float[] v = multiply(T, new float[]{patch.x, patch.y, patch.z, 1});
    float x = v[0]/v[3]; 
    float y = v[1]/v[3];
    float z = v[2]/v[3];
    patch.d = sqrt(x*x + y*y + z*z);
  }
  
  // sort by distance
  Collections.sort(patches); // not available in processing.js
  
  // draw ground plane
  fill(0,128,128,255);
  pushMatrix();
  translate(0,-850,0);
  rotateX(PI/2);
  rect(0,0,2000,2000);
  popMatrix();  
  
  // draw patches in correct order
  for (DiffuserPatch patch : patches) {
    patch.render();  
  }
  
  // export animation
  if (false) {
    final int animLength = 128;
    ry = (float) frameCount / animLength * 2*PI; 
    if (frameCount == animLength-1) exit();
    saveFrame("###.tiff");
  }
}

// applies homography to PVevtor
PVector transform(float[][] T, PVector pv) {
  float[] v = multiply(T, new float[]{pv.x, pv.y, pv.z, 1});
  float x = v[0]/v[3]; 
  float y = v[1]/v[3];
  float z = v[2]/v[3];
  return new PVector(x,y,z);
}

// simulates a patch of switchable diffuser (allows for depth sorting for proper alpha blending)
class DiffuserPatch implements Comparable<DiffuserPatch> {
  float r,g,b,a;
  float x,y,z;
  float rx,ry,rz;
  float w,h;
  float d; // distance to camera
  
  DiffuserPatch(float z) {
    w = 100; h = 100;
    r = 255; g = 255; b = 255; a = 64;
    this.z = z;
  }
  
  DiffuserPatch(float x, float y, float z, float w, float h, float rx, float ry, float rz) {
    this.x = x; this.y = y; this.z = z;
    this.w = w; this.h = h;
    this.rx = rx; this.ry = ry; this.rz = rz;
    r = 255; g = 255; b = 255; a = 8;
  }  
  
  void setColor(int r, int g, int b, int a) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
  
  void render() {
    pushMatrix();
    translate(x,y,z);
    rotateX(rx);rotateY(ry);rotateZ(rz);
    fill(r,g,b,a);
    rect(0,0,w,h);
    //fill(0);
    //textSize(32);
    //text(d,100,100,0.1);
    //box(10);
    popMatrix();  
  }
  
  int compareTo(DiffuserPatch patch) {
    return (int) ((patch.d - d)*1.0f);
  }
}
