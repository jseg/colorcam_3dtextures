//think about calculating z displacemt based on zx and zy rotations

import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;
import processing.video.*;
int rows = 36;
int cols = 20;
PVector[] org = new PVector[((rows+1)*(cols+1))]; //vector to cell origin
PShape cell; //textured quad
PImage mask;
Capture cam;
AniSequence seq_x;
AniSequence seq_y;
AniSequence seq_d;
float s = 1.0;  //zoom as a fraction of display height
float s_t = 1.0;
float rrz = 0; //rotation of cell to right
float rrz_t = 0; //target rotation of cell to right
float brz = 0; //roation of cell below
float brz_t = 0;//target rotation of cell below
float drz = 0; //roation of cell diagonal
float drz_t = 0;//target rotation of cell diagonal
float ry = 0; //roation about the y axis
float ry_t = 0; //target rotation about the y axis
float zDis_y = 0; //z displacement while flipping about y
float rx = 0; //roation about the x axis
float rx_t = 0; //target rotation about the x axis
float zDis_x = 0; //z displacement while flipping about x
float zDis_d = 0; //z displacement while flipping diadonal tiles
float slide = 1;
float slideTarget = slide*height;
float slidePos = slideTarget;
int isOn = 0;
float root2 = sqrt(2);
float aniSpeed = 80;

void setup(){
  size(1280,720,P3D);
  textureMode(NORMAL);
  Ani.setDefaultTimeMode(Ani.FRAMES);
  noStroke();
  mask = loadImage("mask.png");
  camSetup();
  origins();
  Ani.init(this);
  slideTarget = slide*height;
  slidePos = slideTarget;
  frameRate(100);
  }

void draw(){
  background(0);
  if(isOn == 1){
      zdepth();
      updateCell();
      for (int i=0; i<rows+1; i++){
      for (int j=0; j<cols+1; j++){
         int n=(i*(cols+1))+j;
         PVector c = new PVector(org[n].x,org[n].y,org[n].z);
         c.mult(s*cam.height);
         if(((abs(c.x)-(0.5*s*cam.width))<(width/2))&&((abs(c.y)-(0.5*s*cam.height))<(height/2))){
           pushMatrix();
             translate(width/2,height/2,0);
             if(j%2>0){
               if(i%2>0){
                   translate(c.x,c.y,zDis_d);
                   rotateZ(drz);
                   rotateY(ry);
                   rotateX(rx);
                   shape(cell); //diagonal ie both odd
               }
               else{
                 translate(c.x,c.y,zDis_x);
                 rotateZ(rrz); //to the right j odd i even
                 rotateX(rx);
                 shape(cell);
               }
             }
             else {          //j is even
                 if(i%2>0){  //i is odd
                   translate(c.x,c.y,zDis_y);
                   rotateZ(brz);
                   rotateY(ry);
                   shape(cell);
                 } 
                 else{
                   translate(c.x,c.y,0);
                   shape(cell);    //both even
                 }
             }
          popMatrix();
        }
      }
    }
    pushMatrix();
      translate(0,slidePos,1);
      image(mask,0,0);
    popMatrix();
    text(frameRate,20,20);
  }  
}

void zdepth(){
  zDis_y = ((-s*cam.height/2)*sin(ry));
  zDis_x = (s*cam.height/2)*sin(rx);
  zDis_d = ((s*cam.height/2)*sin(rx))+(zDis_y*cos(rx));
  zDis_y = -(abs(zDis_y));
  zDis_x = -(abs(zDis_x));
  zDis_d = zDis_y+zDis_x;
}

void captureEvent(Capture cam){
  cam.read();
   isOn = 1;
}

void updateCell(){
  cell = createShape();
  cell.beginShape();
  cell.texture(cam);
  cell.vertex((-cam.height*s/2),(-cam.height*s/2),.28125,0);
  cell.vertex((cam.height*s/2),(-cam.height*s/2),.84375,0);
  cell.vertex((cam.height*s/2),(cam.height*s/2),.84375,1);
  cell.vertex((-cam.height*s/2),(cam.height*s/2),.28125,1);
  cell.endShape(CLOSE);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      s_t *= 1.15;
      if(s_t>1.0){
        s_t = 1.0;
      }
      Ani.to(this, aniSpeed, "s",s_t);
      }
    else if (keyCode == DOWN) {
     s_t *= .85;
      if(s_t<0.05){
        s_t = 0.05;
      }
      Ani.to(this, aniSpeed, "s",s_t);
    }
    else if (keyCode == LEFT) {
      if(slide > -2){
        slide--;
      }
      slideTarget = slide*height;
      Ani.to(this,1.5*aniSpeed,"slidePos",slideTarget);
    }
    else if (keyCode == RIGHT) {
      if(slide < 1){
        slide++;
      }
      slideTarget = slide*height;
      Ani.to(this,1.5*aniSpeed,"slidePos",slideTarget);
    }
  }
  else if (key == 'a'){ //spin right tiles
    rrz_t += HALF_PI;
    Ani.to(this,aniSpeed,"rrz",rrz_t);
  }
  else if (key == 'w'){ //spin below tiles
    brz_t += HALF_PI;
    Ani.to(this,aniSpeed,"brz",brz_t);
  }
  else if (key == 's'){ //spin diagonal tiles
    drz_t += HALF_PI;
    Ani.to(this,aniSpeed,"drz",drz_t);
  }
  else if (key == 'd'){ //flip right tiles about y
    ry_t += PI;
    Ani.to(this,aniSpeed,"ry",ry_t,Ani.EXPO_IN_OUT);
  }
  else if (key == 'f'){
    rx_t += PI;
    Ani.to(this,aniSpeed,"rx",rx_t,Ani.EXPO_IN_OUT);
  }
  else if (key == 'g'){ //reset rotations
    rrz_t = 0;
    Ani.to(this,aniSpeed*2,"rrz",rrz_t,Ani.EXPO_IN_OUT);
    brz_t = 0;
    Ani.to(this,aniSpeed*2,"brz",brz_t,Ani.EXPO_IN_OUT);
    drz_t = 0;
    Ani.to(this,aniSpeed*2,"drz",drz_t,Ani.EXPO_IN_OUT);
    ry_t = 0;
    Ani.to(this,aniSpeed*2,"ry",ry_t,Ani.EXPO_IN_OUT);
    rx_t = 0;
    Ani.to(this,aniSpeed*2,"rx",rx_t,Ani.EXPO_IN_OUT);
  }
  
}

void camSetup(){
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, width, height);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } 
  else {
    println("Available cameras:");
    printArray(cameras);
    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);
    //cam = new Capture(this, width, height);
    cam.start();
  }
}

void origins(){
  int index = 0;
  for (int i = -rows/2; i<rows/2+1; i++){
    for (int j = -cols/2; j<cols/2+1; j++){
     org[index] = new PVector(i*1.0,j*1.0,0.0); 
     index++;
    }
  }
}
