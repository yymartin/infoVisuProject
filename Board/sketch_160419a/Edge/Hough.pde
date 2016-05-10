import java.util.*;

int[] accumulator;
int phiDim;
int rDim;
float discretizationStepsPhi = 0.06f;
float discretizationStepsR = 2.5f;
ArrayList<Integer> bestCandidates;
ArrayList<PVector> candidatesAsVectors;
int minVotes = 200;

void hough(PImage edgeImg) {

  bestCandidates = new ArrayList<Integer>();
  candidatesAsVectors = new ArrayList<PVector>();

  // dimensions of the accumulator
  phiDim = (int) (Math.PI / discretizationStepsPhi);
  rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  houghImg = createImage(rDim + 2, phiDim + 2, RGB);
   // our accumulator (with a 1 pix margin around)
  accumulator = new int[(phiDim + 2) * (rDim + 2)];
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
 
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
          bestCandidates.add(idx);
        }
      }
    }
  }

  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  for (int i : bestCandidates) {
    candidatesAsVectors.add(getCoordinatesFromIndex(i));
  }
}

void houghDisplay(){
  for (int i = 0; i < accumulator.length; i++) {
  houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
// You may want to resize the accumulator to make it easier to see:
 houghImg.resize(640, 480);
 houghImg.updatePixels();
 image(houghImg,0,0);
}

PVector getCoordinatesFromIndex(int index) {
  int r, phi = 0;
  int temp = index;
  while (temp > 0) {
    temp -= (phiDim + 1);
    phi++;
  }
  phi--;
  phi *= discretizationStepsPhi;
  r = 1 + (index % (phiDim + 1));
  r *= discretizationStepsR;
  
  return new PVector(phi, r);
}

ArrayList<PVector> getIntersections(List<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
        
      // compute the intersection and add it to 'intersections'
      double d = cos(line2.x)*sin(line1.x) - cos(line1.x)*sin(line2.x);
      
      double x = (line2.y*sin(line1.x) - line1.y*sin(line2.x)) / d;
      double y = (line1.y*cos(line2.x) - line2.y*cos(line1.x)) / d;
      
      // draw the intersection
      fill(255, 128, 0);
      ellipse((float)x, (float)y, 10, 10);
    }
  }

  return intersections;
}

void houghLinePlot(PImage edgeImg, int nLines) {
  
  if (bestCandidates.size() < nLines)
    nLines = bestCandidates.size();
    
  for (int i = 0; i < nLines; i++) {
    int idx = bestCandidates.get(i);
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
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
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