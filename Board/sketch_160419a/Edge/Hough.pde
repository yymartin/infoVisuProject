int[] accumulator;
int phiDim;
int rDim;

void hough(PImage edgeImg) {

  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  phiDim = (int) (Math.PI / discretizationStepsPhi);
  rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  houghImg = createImage(rDim + 2, phiDim + 2, RGB);
   // our accumulator (with a 1 pix margin around)
  accumulator = new int[(phiDim + 2) * (rDim + 2)];
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  print("TEST1");
 
 for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      /*
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
         for(float phi = 0; phi < Math.PI; phi+=discretizationStepsPhi){
             for(float r = 0; r < ((edgeImg.width + edgeImg.height)*2+1); r+= discretizationStepsR){
               //print("Looping " + x);
                 if(r == x*Math.cos(phi) + y*Math.sin(phi)){
                   float rShift = r + (rDim - 1)/2;
                   accumulator[Math.round(phi * ((edgeImg.width + edgeImg.height)* 2 + 1) + rShift)] += 1;
                 }
               }
         }
     */    
         if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
         for(float phi = 0; phi < Math.PI; phi+=discretizationStepsPhi){
               //print("Looping " + x);
                 double r = x*Math.cos(phi) + y*Math.sin(phi);
                  r += (rDim - 1)/2;
                   accumulator[Math.round((float)(phi * (rDim+2)*discretizationStepsR + r))] += 1;       
         }
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator with something like: r += (rDim - 1) / 2
      }  
      }
    }
}

void houghDisplay(){
  for (int i = 0; i < accumulator.length; i++) {
  houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
// You may want to resize the accumulator to make it easier to see:
 houghImg.resize(800, 800);
 houghImg.updatePixels();
 // image(houghImg,0,0);
}