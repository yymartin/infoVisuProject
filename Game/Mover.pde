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
float mu = 0.01;
float frictionMagnitude = normalForce * mu;
PVector friction = velocity.copy();
friction.mult(-1);
friction.normalize();
friction.mult(frictionMagnitude);

velocity.add(gravityForce.div(mass));
velocity.add(friction.div(mass));
location.add(velocity);

}

void display(){
pushMatrix();
translate(mover.location.x,-diametre/2 - hauteur,mover.location.y);
noStroke();
fill(255,0,0);
sphere(diametre);
popMatrix();
}

void checkEdges() {
if (location.x >= 250) {
velocity.x *= -1;
location.x = 250;
}
else if (location.x <= -250) {
velocity.x *= -1;
location.x = -250;
}
if (location.y >= 250) {
velocity.y *= -1;
location.y = 250;
}
else if (location.y <= -250) {
velocity.y *= -1;
location.y = -250;
}
}

void checkCylinderCollision()
{
  for (Cylinder c : tabCyl)
  {
    float distance = dist(location.x, location.y, c.posX, c.posY);
    
    PVector n = new PVector(c.posX - location.x, c.posY - location.y);
    n = n.normalize();
    
    if (distance < diametre/2 + c.size)
    {
      PVector v2 = velocity.sub((n.mult(velocity.dot(n))).mult(2));
      velocity = v2.copy();
    }
  }
}
}