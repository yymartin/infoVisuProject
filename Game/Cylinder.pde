class Cylinder {
 float posX;
 float posY;
 PShape openCylinder;
 PShape closeBottom;
 PShape closeTop;
 float size = 50;
 float cylinderHeight = 50;
 int cylinderResolution = 40;

Cylinder(float posX, float posY){
  
  openCylinder = new PShape();
  closeBottom = new PShape();
  closeTop = new PShape();
 
  this.posX = posX;
  this.posY = posY;
  
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] y = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for (int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * size;
    y[i] = cos(angle) * size;
  }
  openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  //draw the border of the cylinder
  for (int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], y[i], 0);
    openCylinder.vertex(x[i], y[i], cylinderHeight);
  }

 openCylinder.endShape();
 
   closeTop = createShape();
  closeTop.beginShape(TRIANGLES);
    for(int i=0; i<x.length-1; i++){
      closeTop.vertex(x[i], y[i], cylinderHeight);
      closeTop.vertex(0, 0, cylinderHeight);
      closeTop.vertex(x[i+1], y[i+1], cylinderHeight);
    }
  closeTop.endShape();
   
  closeBottom = createShape();
  closeBottom.beginShape(TRIANGLES);
    for(int i=0; i<x.length-1; i++){
      closeBottom.vertex(x[i], y[i], 0);
      closeBottom.vertex(0, 0, 0);
      closeBottom.vertex(x[i+1], y[i+1],0);
    }
  closeBottom.endShape();
}
void drawCylinder() {
  pushMatrix();
  translate(posX, -cylinderHeight, posY);
  rotateX(-PI/2);
  shape(openCylinder);
  shape(closeTop);
  shape(closeBottom);
  popMatrix();
}
}