import processing.video.*;

Capture cam;
PImage img, houghImg;
HScrollbar hs1, hs2 ,hs3;
QuadGraph qg;

float[] tabCos, tabSin;

int pWidth = 640;
int pHeight = 480;

float[][] kernel1 = { { 0, 0, 0 },
                      { 0, 2, 0 },
                      { 0, 0, 0 } };
float[][] kernel2 = { { 0, 1, 0 },
                      { 1, 0, 1 },
                      { 0, 1, 0 } };
float[][] gaussian = { { 9, 12, 9 },
                       { 12, 15, 12 },
                       { 9, 12, 9 } };
                         
void settings() {
  size(1000, 1000, P2D);
}

void setup() {
  qg = new QuadGraph();
  hs1 = new HScrollbar(0, pHeight-35, pWidth, 35);
  hs2 = new HScrollbar(0, pHeight - 90, pWidth, 35); 
  hs3 = new HScrollbar(0, pHeight - 145, pWidth, 35);
  
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } 
  else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
  
  phiDim = (int) (Math.PI / discretizationStepsPhi);
  rDim = (int) (((pWidth + pHeight) * 2 + 1) / discretizationStepsR);
  
  tabSin = new float[phiDim];
  tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
// we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }
  for(int i = 0; i < tabSin.length; i++){
   println("TabSin = " + tabSin[i]); 
  }

}

void draw() {
 /* if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  */
 
 
 img = loadImage("board1.jpg");
 selectHue(img);
 selectSaturation(img);
 img = convolute(img, gaussian);
 filterBinary(img, false, 2);
 sobel(img);
 hough(img);
  
 image(img, 0, 0);
 houghLinePlot(img, 6);
   ArrayList<PVector> listRPhi = new ArrayList<PVector>();    
  int j = 0;
  for(int i : bestKey){
    if(j < 6){
    listRPhi.add(bestCandidates.get(i));
    }
    j++;
  }
  getIntersections(listRPhi);
  qg.build(listRPhi,pWidth,pHeight);
  
  for (int[] quad : qg.cycles) {
  PVector l1 = listRPhi.get(quad[0]);
  PVector l2 = listRPhi.get(quad[1]);
  PVector l3 = listRPhi.get(quad[2]);
  PVector l4 = listRPhi.get(quad[3]);
    println("L1 : " + l1.x + " , " + l1.y);
  println("L2 : " + l2.x + " , " + l2.y);
  println("L3 : " + l3.x + " , " + l3.y);
  println("L4 : " + l4.x + " , " + l4.y);

// (intersection() is a simplified version of the
// intersections() method you wrote last week, that simply
// return the coordinates of the intersection between 2 lines)
  PVector c12 = qg.intersection(l1, l2);
  PVector c23 = qg.intersection(l2, l3);
  PVector c34 = qg.intersection(l3, l4);
  PVector c41 = qg.intersection(l4, l1);
// Choose a random, semi-transparent colour
  Random random = new Random();
  fill(color(min(255, random.nextInt(300)),
  min(255, random.nextInt(300)),
  min(255, random.nextInt(300)), 50));
  println("c12 : " + c12.x + " , " + c12.y);
  println("c12 : " + c23.x + " , " + c23.y);
  println("c12 : " + c34.x + " , " + c34.y);
  println("c12 : " + c41.x + " , " + c41.y);
  quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
}
  
 //houghDisplay();
 
//drawScrollBar();
}

void drawScrollBar() {
  hs1.update();
  hs1.display();
 // hs2.update();
 // hs2.display();
 // hs3.update();
 // hs3.display();
}

boolean isMouseOver() {
  return ((mouseY > pHeight-35 && mouseY < pHeight) || (mouseY > pHeight-90 && mouseY < pHeight - 55) || (mouseY > pHeight-145 && mouseY < pHeight - 110));
}

void selectHue(PImage img){
  float range = Math.abs(119-134);
  float minHue = Math.min(119, 134);
  
  for(int i = 0; i < img.width * img.height; i++) {
      if(hue(img.pixels[i]) > minHue && hue(img.pixels[i]) < minHue + range ){
        img.pixels[i] = color(img.pixels[i]);
      } else {
      img.pixels[i] = color(0);
      }
  } 
  img.updatePixels();
}

void selectSaturation(PImage img){
  float range = Math.abs(70-255);
  float minHue = Math.min(70, 255);
  
  for(int i = 0; i < img.width * img.height; i++) {
      if(saturation(img.pixels[i]) > minHue && saturation(img.pixels[i]) < minHue + range ){
        img.pixels[i] = color(img.pixels[i]);
      } else {
      img.pixels[i] = color(0);
      }
  } 
  img.updatePixels();
}


void filterHue(PImage img){
  for(int i = 0; i < img.width * img.height; i++) {
      img.pixels[i] = color(hue(img.pixels[i]));
  }
  img.updatePixels();
}

void filterBinary(PImage img, boolean invert, float threshold){
  int color1, color2;
  if(invert){
    color1 = color(0);
    color2 = color(255);
  } else {
    color1 = color(255);
    color2 = color(0);
  }
  for(int i = 0; i < img.width * img.height; i++) {
    if(brightness(img.pixels[i]) > threshold){
       img.pixels[i] = color1; 
    } else {
       img.pixels[i] = color2; 
    }
}
  img.updatePixels();
}

void selectIntensity(PImage img, float thresholdMin, float thresholdMax){

  int color1 = color(0);
  int color2 = color(255);
  for(int i = 0; i < img.width * img.height; i++) {
    if(brightness(img.pixels[i]) > thresholdMin && brightness(img.pixels[i]) < thresholdMax){
       img.pixels[i] = color1; 
    } else {
       img.pixels[i] = color2; 
    }
}
  img.updatePixels();
}

PImage convolute(PImage img, float[][] kernel) {
float weight = 1f;
// create a greyscale image (type: ALPHA) for output
PImage result = createImage(img.width, img.height, RGB);
  for(int i = 1; i < img.width-1; i++){
    for(int j = 1; j < img.height-1; j++){
        float sum = 0;
        for(int k = -1; k <= 1; k++){
           for(int l = -1; l <= 1; l++){
               sum += ((img.pixels[(i+k) + ((j+l))*img.width]) * kernel[k+1][l+1]);
        }
       }
        result.pixels[j*img.width + i] = (int) (sum/weight);    
   }
  }
  return result;
}

void sobel(PImage img) {
  float[][] hKernel = { { 0, 1, 0 },
                        { 0, 0, 0 },
                        { 0, -1, 0 } };

  float[][] vKernel = { { 0, 0, 0 },
                        { 1, 0, -1},
                        { 0, 0, 0 } };
                        
  float max = 0.0f;
  float weight = 1.0f;
  float[] buffer = new float[img.width * img.height];
  
// *************************************
// Implement here the double convolution
// *************************************
  for(int i = 1; i < img.width-1; i++){
    for(int j = 1; j < img.height-1; j++){
        int sum_h = 0;
        int sum_v = 0;
        for(int k = -1; k <= 1; k++){
           for(int l = -1; l <= 1; l++){
               sum_h += ((img.pixels[(i+k) + ((j+l))*img.width]) * hKernel[k+1][l+1]);
               sum_v += ((img.pixels[(i+k) + ((j+l))*img.width]) * vKernel[k+1][l+1]);
        }
       }
        float compound = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        buffer[j*img.width + i] = (compound/weight); 
        max = Math.max(max,compound);
   }
  }
  
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
        img.pixels[y * img.width + x] = color(255);
      } else {
        img.pixels[y * img.width + x] = color(0);
      }
    }
  }
  img.updatePixels();
}