float hauteur = 20;
float largeur = 500;
float longueur = 500;
float diametre = 20;
int windowWidth = 1200;
int windowHeight = 800;
int mode = 0; // 0 = game, 1 = SHIFT
int topViewSize = 180;
ArrayList<Cylinder> tabCyl = new ArrayList<Cylinder>();
PGraphics bottomRectangle;
PGraphics topView;

Mover mover = new Mover();

void settings() {
  size(windowWidth, windowHeight, P3D);
}

void setup(){ 
 bottomRectangle = createGraphics(windowWidth, 200, P2D);
 topView = createGraphics(topViewSize,topViewSize, P2D);
}

void draw() {
  drawBottomRectangle();
  drawTopView();
  
  if (mode == 0) {
    drawGame();
  } else if (mode == 1) {
    drawShift();
  }    
  image(bottomRectangle, 0, windowHeight-200);
  image(topView, 10, windowHeight-190);
}

void drawTopView(){
  topView.beginDraw();
  background(255,255,255);
  topView.fill(120);
  topView.rect(0, 0, longueur, longueur);
  topView.fill(127);
  topView.pushMatrix();
  
  topView.ellipse(mover.location.x, mover.location.y, diametre, diametre);
  topView.fill(0);
  for(Cylinder c : tabCyl){
    topView.ellipse(c.posX,c.posY,c.size, c.size);
  }
  
  topView.scale(1/3,1/3);
  topView.translate(10, windowHeight-190);
  topView.popMatrix();
  topView.endDraw();
}

void drawBottomRectangle(){
   bottomRectangle.beginDraw();
   bottomRectangle.background(255,255,102);
   bottomRectangle.endDraw();
}

void drawGame() {
  pushMatrix();
  background(255, 255, 255);
  translate(windowWidth/2, windowHeight/2, 0);
  rotateX(dragX);
  rotateZ(dragZ);
  
  fill(51, 153, 255);
  stroke(0, 102, 204);
  box(longueur, hauteur, largeur);

  for (Cylinder c : tabCyl) {
    c.drawCylinder();
  }
  
  mover.update();
  mover.checkEdges();
  mover.checkCylinderCollision();
  mover.display();
  popMatrix();
}

void drawShift() {
  background(255, 255, 255);
  pushMatrix();
  translate(windowWidth/2, windowHeight/2, 0);
  rotateX(-PI/2);
  noFill();
  stroke(0);
  box(longueur, hauteur, largeur);
  mover.display();
  for (Cylinder c : tabCyl) {
    c.drawCylinder();
  }
  popMatrix();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      mode = 1;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      mode = 0;
    }
  }
}

void mouseClicked() {
  if (mode == 1) {
    Cylinder c = new Cylinder(mouseX-windowWidth/2, mouseY-windowHeight/2);
    
    float distance = dist(mover.location.x, mover.location.y, c.posX, c.posY);

    if ((c.posX < largeur/2 - c.size && c.posY < longueur/2 - c.size && c.posX > -largeur/2 +c.size && c.posY > -longueur/2 +c.size) && (distance > diametre + c.size)) {
      tabCyl.add(c);
    }
  }
}

float xStart, yStart = 0;
float deltaX, deltaY = 0;
float dragX, dragZ = 0;
float wheel = 1;

void mouseDragged() {
  deltaX = -(mouseY - pmouseY);
  dragX += wheel * deltaX / 300;
  clamp(dragX, -PI/3, PI/3);

  deltaY = (mouseX - pmouseX);
  dragZ += wheel * deltaY / 300;
  clamp(dragZ, -PI/3, PI/3);
}

void mouseWheel(MouseEvent event) {
  wheel -= event.getCount() * 0.01;
  if (wheel > 1.5) {
    wheel = 1.5;
  } else if (wheel < 0.2) {
    wheel = 0.2;
  }
}

void clamp(float drag, float min, float max) {
  if (drag > max) {
    drag = max;
  } else if (drag < min) {
    drag = min;
  }
}