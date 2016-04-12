int windowWidth = 1200;
int windowHeight = 800;
int mode = 0; // 0 = game, 1 = SHIFT
int topViewSize = 180;
int barChartWidth = 750;
int nbCol = 150;

float hauteur = 20;
float largeur = 350.0;
float longueur = 350.0;
float diametre = 10;
float maxScore = 0;
float factor = topViewSize/largeur;

ArrayList<Cylinder> tabCyl = new ArrayList<Cylinder>();
ArrayList<Float> tabScore = new ArrayList<Float>();

PGraphics bottomRectangle;
PGraphics topView;
PGraphics score;
PGraphics barChart;
PGraphics scroll;

HScrollbar hs;

Mover mover = new Mover();

void settings() {
  size(windowWidth, windowHeight, P3D);
}

void setup(){ 
 hs = new HScrollbar(80+2*topViewSize, windowHeight-40, 300, 20);
 tabScore.add(0.0);
 tabScore.add(0.0);
 bottomRectangle = createGraphics(windowWidth, 200, P2D);
 topView = createGraphics(topViewSize,topViewSize, P2D);
 score = createGraphics(topViewSize+700, topViewSize+700, P2D);
 barChart = createGraphics(barChartWidth, topViewSize-50, P2D);
 scroll = createGraphics(barChartWidth/2, 50, P2D);
}

void draw() {
  if (mode == 0) {
    drawGame();
  } else if (mode == 1) {
    drawShift();
  }    
  image(bottomRectangle, 0, windowHeight-200);
  image(topView, 10, windowHeight-190);
  image(score, 20+topViewSize, windowHeight-190); 
  image(barChart, 80+2*topViewSize, windowHeight-190);
  image(scroll, 80+2*topViewSize, windowHeight-40);
  drawBottomRectangle();
  drawTopView();
  drawScore();
  drawBarChart();
  drawScrollBar();
}

void drawScrollBar(){
scroll.beginDraw();
hs.update();
hs.display();
scroll.endDraw();
}

void drawBarChart(){
 barChart.beginDraw();
 barChart.fill(255);
 barChart.stroke(0);
 barChart.rect(0,0,barChartWidth-1, topViewSize-51);
 for(int i = 0; i < tabScore.size(); i++){
    barChart.fill(0);
    barChart.stroke(255);
    barChart.rect(i*barChartWidth/(nbCol*hs.getPos()),topViewSize-52,barChartWidth/(nbCol*hs.getPos()), -(6.0*tabScore.get(i))/(7.0*maxScore)*(topViewSize-51));    
 }
 barChart.endDraw();
}

void drawTopView(){
  topView.beginDraw();
  background(255,255,255);
  topView.fill(127);
  topView.pushMatrix();
  topView.fill(120);
  topView.rect(0, 0, largeur*factor, largeur*factor);
  topView.ellipse((mover.location.x+largeur/2)*factor, (mover.location.y+largeur/2)*factor, diametre*2*factor, diametre*2*factor);
  topView.fill(0);
  for(Cylinder c : tabCyl){
    topView.ellipse((c.posX+largeur/2)*factor,(c.posY+largeur/2)*factor,(c.size)*2*factor, (c.size)*2*factor);
  }
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
  translate(windowWidth/2, 2*windowHeight/5, 0);
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

void drawScore(){
  score.beginDraw();
  score.rect(0,0, topViewSize+50, topViewSize);
  fill(120);
  pushMatrix();
  translate(30, largeur + 125);
  textSize(15);
  text("Total Score : " + tabScore.get(tabScore.size()-1) + "\n\nVelocity : " + mover.velocity.mag() + "\n\nLast Score : " + tabScore.get(tabScore.size()-2), topViewSize , topViewSize);
  popMatrix();
  score.endDraw();
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
  if(!hs.mouseOver){
  deltaX = -(mouseY - pmouseY);
  dragX += wheel * deltaX / 300;
  clamp(dragX, -PI/3, PI/3);

  deltaY = (mouseX - pmouseX);
  dragZ += wheel * deltaY / 300;
  clamp(dragZ, -PI/3, PI/3);
  }
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

/**
* @brief Gets whether the mouse is hovering the scrollbar
*
* @return Whether the mouse is hovering the scrollbar
*/
boolean isMouseOver() {
return (mouseY > windowHeight-200);
}