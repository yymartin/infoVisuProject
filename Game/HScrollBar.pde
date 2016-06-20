class HScrollbar {

  float barWidth; //Bar’s width in pixels
float barHeight; //Bar’s height in pixels
float xPosition; //Bar’s x position in pixels
float yPosition; //Bar’s y position in pixels
float sliderPosition, newSliderPosition; //Position of slider
float sliderPositionMin, sliderPositionMax; //Max and min values of slider

boolean mouseOver; //Is the mouse over the slider?
boolean locked; //Is the mouse clicking and dragging the slider now?
/**
* @brief Creates a new horizontal scrollbar
*
* @param x The x position of the top left corner of the bar in pixels
* @param y The y position of the top left corner of the bar in pixels
* @param w The width of the bar in pixels
* @param h The height of the bar in pixels
*/
HScrollbar (float x, float y, float w, float h) {
  barWidth = w;
  barHeight = h;
  xPosition = x;
  yPosition = y;
  sliderPosition = xPosition + barWidth/2 - barHeight/2;
  newSliderPosition = sliderPosition;
  sliderPositionMin = xPosition;
  sliderPositionMax = xPosition + barWidth - barHeight;
}
/**
* @brief Updates the state of the scrollbar according to the mouse movement
*/
void update(){
  mouseOver = isMouseOver();

  if (mousePressed && mouseOver && mouseY < yPosition + barHeight && mouseY > yPosition 
      && mouseX < xPosition + barWidth && mouseX > xPosition) {
      locked = true;
  }
  
  if (!mousePressed) {
      locked = false;
  }
  
  if (locked) {
      newSliderPosition = constrain(mouseX - barHeight/2, sliderPositionMin, sliderPositionMax);
  }
  
  if (abs(newSliderPosition - sliderPosition) > 1) {
      sliderPosition = sliderPosition + (newSliderPosition - sliderPosition);
  }
}
/**
* @brief Clamps the value into the interval
*
* @param val The value to be clamped
* @param minVal Smallest value possible
* @param maxVal Largest value possible
*
* @return val clamped into the interval [minVal, maxVal]
*/
float constrain(float val, float minVal, float maxVal) {
  return min(max(val, minVal), maxVal);
}

/**
* @brief Draws the scrollbar in its current state
*/
void display() {
  noStroke();
  scroll.fill(255,255,204);
  scroll.rect(0, 0, barWidth, barHeight);
  
  if (mouseOver || locked) {
    fill(0, 0, 0);
  } else {
  fill(102, 102, 102);
  }
  scroll.fill(0,204,102);
  scroll.rect(sliderPosition-xPosition, 0, barHeight, barHeight);
}
/**
* @brief Gets the slider position
*
* @return The slider position in the interval [0,1]
* corresponding to [leftmost position, rightmost position]
*/
float getPos() {
  return 0.1+0.9*(sliderPosition - xPosition)/(barWidth - barHeight);
}
}