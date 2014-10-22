/* Slider controls */

/* Scale objects map a range of pixel values to a range of float values */
class Scale
{
 int domainMin, domainMax; /* min and max coordinates on screen */
 float rangeMin, rangeMax; /* the range to map coordinates to */

  Scale(int dmin, int dmax, float rmin, float rmax)
  {
    domainMin = dmin;
    domainMax = dmax;
    rangeMin = rmin;
    rangeMax = rmax;
  }
  
  float value(int arg) { // arg is a screen coordinate
    return map(arg, domainMin, domainMax, rangeMin, rangeMax);
  }
}

/* the Slider class is a draggable rectangle
that reports its position and value
*/
class Slider
{
 float value; /* the value selected given slider position */
 int sw, sh; // dimensions of the draggable rect
 int offSet, position, maxPos, minPos; // see constructor for explanation
 boolean selected = false; // determines whether the slider moves when mouse is dragged
 Scale scale;
 
 PImage img;
 
 Slider(int offset, Scale s, int w, int h, float initial)
 {
   offSet = offset; // offset on screen, for positioning of the control
   scale = s; // scale to be used, determines range of motion
   
   /* maxPos and minPos constrain the motion of the slider
      max() and min() are used because we could have domainMax < domainMin
   */
   maxPos = max(scale.domainMax, scale.domainMin); // bottom of the slider background on screen
   minPos = min(scale.domainMin, scale.domainMax); // top of the slider background on screen
      
   position = map(initial, scale.rangeMin, scale.rangeMax, scale.domainMin, scale.domainMax); // position of the slider along its range
   
   sw = w;
   sh = h;
   value = initial;
 }    
}

class VSlider extends Slider
{ 
  VSlider(int offset, Scale s, float initial) {
     super(offset, s, 50, 20, initial);
     img = loadImage(VSLIDE);
   }
   
  void drawBackground() {
    String valStr = value.toString().substring(0, 5);
    textAlign(CENTER);
    textSize(14);
    fill(200);
    text(valStr, offSet+sw/2, minPos - 25);
  }

  boolean mouseOver() {
    if (mouseX > offSet && mouseX < offSet + sw &&
        mouseY > position && mouseY < position + sh) {
      return true;
    } else return false;
  }

  void draw() {
    drawBackground();
    int a;
    if (selected) {
      a = 255;
    } else {
      a = 128;
    }
    image(img, offSet, position, sw, sh);
  }

  void move() {
    if (mouseY - sh/2 < minPos || mouseY - sh/2 > maxPos) {
        return;
    } else {
      position = mouseY - sh/2; // pointer in center of image
      value = scale.value(position);
    }
  }
}

class HSlider extends Slider
{
  HSlider(int offset, Scale s, float initial) {
    super(offset, s, 20, 50, initial);
    img = loadImage(HSLIDE);
  }

  boolean mouseOver() {
    if (mouseX > position && mouseX < position + sw &&
        mouseY > offSet && mouseY < offSet + sh)
      return true;
    else return false;
  }
  
  void draw() {
    // no background for this one
    int a;
    if (selected) {
      a = 255;
    } else {
      a = 128;
    }
    image(img, position, offSet, sw, sh);
  }
  
  void move() {
    if (mouseX - sw/2 < minPos || mouseX - sw/2 > maxPos) {
        return;
    } else {
      position = mouseX - sw/2; // pointer in center of image
      value = scale.value(position);
    }
  }
}
