void displayQuad(ArrayList<PVector> listRPhi){
  
  qg.build(listRPhi,pWidth,pHeight);
  
  for (int[] quad : qg.findCycles()) {
    PVector l1 = listRPhi.get(quad[0]);
    PVector l2 = listRPhi.get(quad[1]);
    PVector l3 = listRPhi.get(quad[2]);
    PVector l4 = listRPhi.get(quad[3]);
// (intersection() is a simplified version of the
// intersections() method you wrote last week, that simply
// return the coordinates of the intersection between 2 lines)
    PVector c12 = qg.intersection(l1, l2);
    PVector c23 = qg.intersection(l2, l3);
    PVector c34 = qg.intersection(l3, l4);
    PVector c41 = qg.intersection(l4, l1);
  
    if(c12 != null && c23 != null && c34 != null & c41 != null
       && qg.isConvex(c12,c23,c34,c41) 
       && qg.validArea(c12,c23,c34,c41, 1000000, 10000)
       && qg.nonFlatQuad(c12,c23,c34,c41)){
    
// Choose a random, semi-transparent colour
    Random random = new Random();
    fill(color(min(255, random.nextInt(300)),
    min(255, random.nextInt(300)),
    min(255, random.nextInt(300)), 50));
    quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
    }  
  } 
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
  return ((mouseY > pHeight-35 && mouseY < pHeight) || (mouseY > pHeight-90 && mouseY < pHeight - 55) || (mouseY > pHeight-145 && mouseY < pHeight - 110));
}

void selectHBS(PImage img){
    
    float thresholdHue1 = 88;
    float thresholdHue2 = 139; //137
    
    float thresholdBrightness1 = 30; 
    float thresholdBrightness2 = 180; 
    
    float thresholdSaturation1 = 70; //60 --> 70?
    float thresholdSaturation2 = 255;
   
    for (int i = 0; i < img.width * img.height; i++) {
      
      float hue = hue(img.pixels[i]);
      float brightness = brightness(img.pixels[i]);
      float saturation = saturation(img.pixels[i]);
      
      if(hue < thresholdHue1 || hue > thresholdHue2
          || brightness < thresholdBrightness1 || brightness > thresholdBrightness2
          || saturation < thresholdSaturation1 || saturation > thresholdSaturation2) {
        
        img.pixels[i] = color(0);
      } else {
        img.pixels[i] = color(255);
      }
    }
    img.updatePixels();
  }
  
  void selectIntensity(PImage img){
    
    float threshold = 128;
    
    for (int i = 0; i < img.width * img.height; i++) {
      
      float brightness = brightness(img.pixels[i]);
      
      if(brightness < threshold) {
        img.pixels[i] = color(0);
      } else {
        img.pixels[i] = color(255);
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