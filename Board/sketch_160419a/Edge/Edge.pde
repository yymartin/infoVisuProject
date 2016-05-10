import processing.video.*;

Capture cam;
PImage img, houghImg;
HScrollbar hs1, hs2 ,hs3;

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
  size(640, 480, P2D);
}

void setup() {
  
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
  


}

void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  
  PImage finalimg = sobel(img);
  hough(finalimg);
  image(img, 0, 0);
  houghLinePlot(finalimg, 6);
  getIntersections(candidatesAsVectors);
  
//image(filterBinary(img, true, 255*hs1.getPos()), 0, 0);
//image(filterHue(img),0,0);
//image(selectHue(img),0,0);
//image(convolute(img,gaussian),0,0);
  //PImage finalimg = selectHue(img);
//  finalimg = convolute(finalimg,gaussian);
//  finalimg = filterBinary(finalimg, true, 255*hs3.getPos());
 // finalimg = convolute(finalimg,gaussian);
  //image(finalimg,0,0);
//  image(finalimg,0,0);
 //houghDisplay();
 //drawScrollBar();
}

void drawScrollBar() {
  hs1.update();
  hs1.display();
  hs2.update();
  hs2.display();
  hs3.update();
  hs3.display();
}

boolean isMouseOver() {
  return ((mouseY > 600-35 && mouseY < 600) || (mouseY > 600-90 && mouseY < 600 - 55) || (mouseY > 600-145 && mouseY < 600 - 110));
}

PImage selectHue(PImage img){
  PImage result = createImage(img.width, img.height, RGB); // create a new, initially transparent, ’result’ image
  float range = Math.abs((hs1.getPos()-hs2.getPos())*255);
  float minHue = Math.min(hs1.getPos(), hs2.getPos())*255;
  
  for(int i = 0; i < img.width * img.height; i++) {
      if(hue(img.pixels[i]) > minHue && hue(img.pixels[i]) < minHue + range ){
        result.pixels[i] = color(img.pixels[i]);
      } else {
      result.pixels[i] = color(0);
      }
  } 
  return result;
}

PImage filterHue(PImage img){
  PImage result = createImage(img.width, img.height, RGB); // create a new, initially transparent, ’result’ image
  for(int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(hue(img.pixels[i]));
  } 
  return result;
}

PImage filterBinary(PImage img, boolean invert, float threshold){
  int color1, color2;
  PImage result = createImage(img.width, img.height, RGB); // create a new, initially transparent, ’result’ image
  if(invert){
    color1 = color(0);
    color2 = color(255);
  } else {
    color1 = color(255);
    color2 = color(0);
  }
  for(int i = 0; i < img.width * img.height; i++) {
    if(brightness(img.pixels[i]) > threshold){
       result.pixels[i] = color1; 
    } else {
       result.pixels[i] = color2; 
    }
}
  return result;
}

PImage convolute(PImage img, float[][] kernel) {
float weight = 1f;
// create a greyscale image (type: ALPHA) for output
PImage result = createImage(img.width, img.height,ALPHA);
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

PImage sobel(PImage img) {
  float[][] hKernel = { { 0, 1, 0 },
                        { 0, 0, 0 },
                        { 0, -1, 0 } };

  float[][] vKernel = { { 0, 0, 0 },
                        { 1, 0, -1},
                        { 0, 0, 0 } };
                        
  PImage result = createImage(img.width, img.height, RGB);
// clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
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
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}