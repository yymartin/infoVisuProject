class Mover {
  PVector location, velocity, gravityForce;
  float mass, gravityConstant;
  
 Mover(){
    location = new PVector(0,0);
    velocity = new PVector(0,0);
    gravityConstant = -1;
    gravityForce = new PVector(0,0);
    mass = 1;
  }
  
void update(){
    gravityForce.x = -sin(dragZ) * gravityConstant;
    gravityForce.y = sin(dragX) * gravityConstant;
    
    float normalForce = 1;
    float mu = 0.1;
    float frictionMagnitude = normalForce * mu;
    PVector friction = velocity.copy();
 
    friction.mult(-1).normalize().mult(frictionMagnitude);
    velocity.add(gravityForce.div(mass)).add(friction.div(mass));
    location.add(velocity);
}

void display(){
  pushMatrix();
  translate(mover.location.x,-diametre/2-15,mover.location.y);
  fill(255,153,153);
  stroke(255,51,51);
  sphere(diametre);
  popMatrix();
}

void checkEdges() {
  if (location.x >= largeur/2) {
    velocity.x *= -1;
    location.x = largeur/2;
    updateScore(-velocity.mag());
  } else if (location.x <= -largeur/2) {
    velocity.x *= -1;
    location.x = -largeur/2;
    updateScore(-velocity.mag());
  }

if (location.y >= largeur/2) {
    velocity.y *= -1;
    location.y = largeur/2;
    updateScore(-velocity.mag());
} else if (location.y <= -largeur/2) {
    velocity.y *= -1;
    location.y = -largeur/2;
    updateScore(-velocity.mag());
}
}

void checkCylinderCollision(){
  for (Cylinder c : tabCyl){
    
    float distance = dist(location.x, location.y, c.posX, c.posY);
    
    if (distance < diametre + c.size){
        PVector n = new PVector(c.posX - location.x, c.posY - location.y);
        n.normalize();
        location.x = n.copy().mult(c.size + diametre).mult(-1).x + c.posX;
        location.y = n.copy().mult(c.size + diametre).mult(-1).y + c.posY;
        velocity.sub((n.mult(velocity.dot(n))).mult(2));
        updateScore(velocity.mag());
    }
  }
}

void updateScore(float velocity){  
    java.util.Collections.rotate(tabScore,-1);
    tabScore.set(tabScore.size()-1,tabScore.get(tabScore.size()-2) + velocity);
    
    if(tabScore.get(tabScore.size()-1) < 0){
      tabScore.set(tabScore.size()-1,0.0); 
    }
    
    maxScore = max(maxScore, tabScore.get(tabScore.size()-1));
  }
}