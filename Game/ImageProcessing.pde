import processing.video.*;
import java.util.*;

class ImageProcessing extends PApplet {
  int phiDim;
  int rDim;  
  int pWidth = 1280;
  int pHeight = 720;
  int minVotes = 100;
  
  int[] accumulator;
  
  float discretizationStepsPhi = 0.02f;
  float discretizationStepsR = 2.f;
  
  float[] tabCos, tabSin;
  
  float[][] kernel1 = { { 0, 0, 0 },
                        { 0, 2, 0 },
                        { 0, 0, 0 } };
  float[][] kernel2 = { { 0, 1, 0 },
                        { 1, 0, 1 },
                        { 0, 1, 0 } };
  float[][] gaussian = { { 9, 12, 9 },
                         { 12, 15, 12 },
                         { 9, 12, 9 } };
  
  QuadGraph qg;
  TwoDThreeD td;
  Movie cam;

  Map<Integer, PVector> bestCandidates;
  ArrayList<Integer> bestKey;

  PImage img, img1, houghImg;
                         
  PVector rotation;
  
  void settings() {
    size(pWidth, pHeight, P2D);
  }
    
  void setup(){  
    qg = new QuadGraph();  
    cam = new Movie(this, "testvideo.mp4");
    cam.loop();
 
  phiDim = (int) (Math.PI / discretizationStepsPhi);
  rDim = (int) (((pWidth + pHeight) * 2 + 1) / discretizationStepsR);
  
  tabSin = new float[phiDim];
  tabCos = new float[phiDim];
  float ang = 0;
  
// float inverseR = 1.f / discretizationStepsR;

  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
// we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (Math.sin(ang));
    tabCos[accPhi] = (float) (Math.cos(ang));
  }
  
  td = new TwoDThreeD(pWidth, pHeight);
 }
  void draw(){
    if (cam.available() == true) {
      cam.read();
    }
  
    img = cam.get();
 
    img1 = img.copy();
 
    selectHBS(img1);
    img1 = convolute(img1, gaussian);
    selectIntensity(img1);
    sobel(img1);
    hough(img1);
    houghLinePlot(img1, 6);
    
    image(img1,0,0);
 
    ArrayList<PVector> listRPhi = new ArrayList<PVector>();    
    int j = 0;
    for(int i : bestKey){
      if(j < 6){
        listRPhi.add(bestCandidates.get(i));
      }
      j++;
    }
    
    getIntersections(listRPhi);
  
   displayQuad(listRPhi);
  }
  
  PVector getRotation(){
    if (rotation != null){
     return new PVector(rotation.x, rotation.y); 
    } else {
     return null; 
    }
  }
  
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
       && qg.validArea(c12,c23,c34,c41, pWidth*pHeight, 100*100)
       && qg.nonFlatQuad(c12,c23,c34,c41)){
    
// Choose a random, semi-transparent colour
    Random random = new Random();
    fill(color(min(255, random.nextInt(300)),
    min(255, random.nextInt(300)),
    min(255, random.nextInt(300)), 50));
    quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
    
    ArrayList<PVector> listIntersection = new ArrayList<PVector>(); 
    listIntersection.add(c12);
    listIntersection.add(c23);
    listIntersection.add(c34);
    listIntersection.add(c41);
  
  rotation = td.get3DRotations(listIntersection);
    }  
  }
}

void selectHBS(PImage img){
    
    float thresholdHue1 = 88;
    float thresholdHue2 = 139;
    
    float thresholdBrightness1 = 30; 
    float thresholdBrightness2 = 180; 
    
    float thresholdSaturation1 = 70;
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
void hough(PImage edgeImg) {

  bestCandidates = new HashMap<Integer,PVector>();

  // dimensions of the accumulator
  houghImg = createImage(rDim + 2, phiDim + 2, RGB);
   // our accumulator (with a 1 pix margin around)
  accumulator = new int[(phiDim + 2) * (rDim + 2)];
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
 
 for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?   
         if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
         for(float phi = 0; phi < Math.PI; phi+=discretizationStepsPhi){
              double r = x*Math.cos((phi)) + y*Math.sin((phi));
                 int rIndex = (int) Math.round(r / discretizationStepsR);
                  rIndex += (rDim - 1)/2;
                  int phiIndex = (int) Math.round(phi / discretizationStepsPhi); 
                   accumulator[((phiIndex + 1)*(rDim+2) + (rIndex + 1))] += 1;    
         }
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator with something like: r += (rDim - 1) / 2
      }  
      }
    }
    
  // size of the region we search for a local maximum
  int neighbourhood = 10;
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              // check we are not outside the image
            if(accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if(accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
          }
          if(!bestCandidate) break;
        }
        if(bestCandidate) {
          // the current idx *is* a local maximum
          PVector rPhi = new PVector((accR - (rDim - 1) * 0.5f) * discretizationStepsR,accPhi*discretizationStepsPhi);
          bestCandidates.put(idx,rPhi);
        }    
      }
    }
  }
  
  bestKey = new ArrayList<Integer>(bestCandidates.keySet());
  Collections.sort(bestKey, new HoughComparator(accumulator));

}

void houghDisplay(){
  for (int i = 0; i < accumulator.length; i++) {
  houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
// You may want to resize the accumulator to make it easier to see:
 houghImg.resize(400, 300);
 houghImg.updatePixels();
 image(houghImg,400,0);
}

ArrayList<PVector> getIntersections(List<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
        
      // compute the intersection and add it to 'intersections'
     double d = tabCos[Math.round(line2.y/discretizationStepsPhi)]*tabSin[Math.round(line1.y/discretizationStepsPhi)] 
               - tabCos[Math.round(line1.y/discretizationStepsPhi)]*tabSin[Math.round(line2.y/discretizationStepsPhi)];
     double x = (line2.x*tabSin[Math.round(line1.y/discretizationStepsPhi)] - line1.x*tabSin[Math.round(line2.y/discretizationStepsPhi)]) / d;
     double y = (line1.x*tabCos[Math.round(line2.y/discretizationStepsPhi)] - line2.x*tabCos[Math.round(line1.y/discretizationStepsPhi)]) / d;
      
      // draw the intersection
      fill(255, 128, 0);
      ellipse((float)x, (float)y, 5, 5);
    }
  }

  return intersections;
}

void houghLinePlot(PImage edgeImg, int nLines) {
  
  if (bestCandidates.size() < nLines)
    nLines = bestCandidates.size();
    
  for (int i = 0; i < nLines; i++) {
    int idx = bestKey.get(i);
    //PVector rPhi = bestCandidates.get(bestKey.get(i));
    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / (rDim + 2)) - 1;
    int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
    float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image
    int x0 = 0;
    int y0 = (int) (r / tabSin[Math.round(phi/discretizationStepsPhi)]);
    int x1 = (int) (r / tabCos[Math.round(phi/discretizationStepsPhi)]);
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-tabCos[Math.round(phi/discretizationStepsPhi)] / tabSin[Math.round(phi/discretizationStepsPhi)] * x2 + r / tabSin[Math.round(phi/discretizationStepsPhi)]);
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / tabSin[Math.round(phi/discretizationStepsPhi)]) * (tabSin[Math.round(phi/discretizationStepsPhi)] / tabCos[Math.round(phi/discretizationStepsPhi)]));
    // Finally, plot the lines
    stroke(204,102,0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    }
    else {
      if (x1 > 0) {
        if (y2 > 0)
      line(x1, y1, x2, y2);
        else
      line(x1, y1, x3, y3);
    }
    else
      line(x2, y2, x3, y3);
    }
  }
}
}