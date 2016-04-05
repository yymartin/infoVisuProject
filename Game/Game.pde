float hauteur = 20;
float largeur = 500;
float longueur = 500;
float diametre = 20;
int mode = 0; // 0 = game, 1 = SHIFT
ArrayList<Cylinder> tabCyl = new ArrayList<Cylinder>();

Mover mover = new Mover();

void setup(){
 size(1000,1000,P3D); 
}

void draw(){
  if(mode == 0){
     drawGame(); 
  } else if (mode == 1){
    drawShift();
  }
}

void drawGame(){
background(255,255,255);
fill(0);
translate(500, 500, 0);
rotateX(dragX);
rotateZ(dragZ);
box(longueur, hauteur, largeur);

mover.update();
mover.checkEdges();
mover.checkCylinderCollision();
mover.display();
for (Cylinder c : tabCyl){
    c.draw();
 }
}

void drawShift(){
background(255,255,255);
translate(500, 500, 0);
rotateX(-PI/2);
noFill();
stroke(0);
box(longueur, hauteur, largeur);
mover.display();
for (Cylinder c : tabCyl){
    c.draw();
 }

}

void keyPressed(){
  if(key == CODED){
     if(keyCode == SHIFT){
       mode = 1; 
     }
  }
}
  
void keyReleased(){
  if(key == CODED){
     if(keyCode == SHIFT){
       mode = 0; 
     }
 }
}

void mouseClicked(){
    if(mode == 1){
       Cylinder c = new Cylinder(mouseX-500, mouseY-500);
       tabCyl.add(c);
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

void clamp(float drag, float min, float max){
   if(drag > max){
     drag = max;
   } else if (drag < min){
     drag = min;
   }
}