void setup() {
  size(1000, 1000, P2D);
}

void draw() {
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  
  //rotated around x
  float[][] transform1 = rotateXMatrix(PI/8);
  input3DBox = transformBox(input3DBox, transform1);
  projectBox(eye, input3DBox).render();
  
  //rotated and translated
  float[][] transform2 = translationMatrix(200, 200, 0);
  input3DBox = transformBox(input3DBox, transform2);
  projectBox(eye, input3DBox).render();
  
  //rotated, translated, and scaled
  float[][] transform3 = scaleMatrix(2, 2, 2);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

class My2DPoint {
  float x;
  float y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x;
  float y;
  float z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  return new My2DPoint((p.x - eye.x)*eye.z/(-p.z + eye.z), (p.y - eye.y)*eye.z/(-p.z + eye.z));
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  void render() {
    for(int i = 0; i < 4; i++) {
      line(s[i].x, s[i].y, s[(i+1)%4].x, s[(i+1)%4].y);
    }
    for(int i = 0; i < 4; i++) {
      line(s[i+4].x, s[i+4].y, s[(i+1)%4 +4].x, s[(i+1)%4 +4].y);
    }
    for(int i = 0; i < 4; i++) {
      line(s[i].x, s[i].y, s[i+4].x, s[i+4].y);
    }
  }
}

class My3DBox {
  My3DPoint[] p;
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ) {
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[] { 
      new My3DPoint(x, y+dimY, z+dimZ), 
      new My3DPoint(x, y, z+dimZ), 
      new My3DPoint(x+dimX, y, z+dimZ), 
      new My3DPoint(x+dimX, y+dimY, z+dimZ), 
      new My3DPoint(x, y+dimY, z), 
      origin, 
      new My3DPoint(x+dimX, y, z), 
      new My3DPoint(x+dimX, y+dimY, z)
    };
  }
  My3DBox(My3DPoint[] p) {
    this.p = p;
  }
}

My2DBox projectBox(My3DPoint eye, My3DBox box) {
  My2DPoint[] tab = new My2DPoint[box.p.length];
  
  for(int i = 0; i < box.p.length; i++){
    My2DPoint point = projectPoint(eye, box.p[i]);
    tab[i] = point;
  }
  return new My2DBox(tab);
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0, 0, 0},
                        {0, cos(angle), sin(angle), 0},
                        {0, -sin(angle), cos(angle), 0},
                        {0, 0, 0, 1}});
}

float[][] rotateYMatrix(float angle) {
  return(new float[][] {{cos(angle), 0, sin(angle), 0},
                        {0, 1, 0, 0},
                        {-sin(angle), 0, cos(angle), 0},
                        {0, 0, 0, 1}});
}

float[][] rotateZMatrix(float angle) {
  return(new float[][] {{0, cos(angle), -sin(angle), 0},
                        {0, sin(angle), cos(angle), 0},
                        {0, 0, 1, 0},
                        {0, 0, 0, 1}});
}

float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {{x, 0, 0, 0},
                        {0, y, 0, 0},
                        {0, 0, z, 0},
                        {0, 0, 0, 1}});
}

float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {{1, 0, 0, x},
                        {0, 1, 0, y},
                        {0, 0, 1, z},
                        {0, 0, 0, 1}});
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] res = new float[b.length];
  for(int i = 0; i < 4; i++){
    int val = 0;
    for(int j = 0; j < 4; j++){
      val += a[i][j]*b[j];
    }
    res[i] = val;
  }
  return res;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix){
  My3DPoint[] tab = new My3DPoint[box.p.length];
  for(int i=0; i < box.p.length; i++){
    tab[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(tab);
}

My3DPoint euclidian3DPoint(float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}





  






