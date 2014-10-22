/* the Button gui elements */

class Button
{
  PImage offImg, onImg, img;
  int bw, bh;
  int bx, by; // offsets
  boolean on;
  
  Button(String imgfile, String altimgfile, int w, int h, int x, int y) {
    offImg = loadImage(imgfile);
    onImg = loadImage(altimgfile);
    img = offImg;
    bw = w;
    bh = h;
    bx = x;
    by = y;
    on = false;
  }
  
  boolean mouseOver() {
    if (mouseX > bx && mouseX < bx + bw &&
        mouseY > by && mouseY < by + bh)
      return true;
    else return false;
  }
  
  void toggle() {
    on = !on;
    if (on) {
      img = onImg;
    } else {
      img = offImg;
    }
  }
  
  void draw() {
    if (on) {
      img = onImg;
    } else {
      img = offImg;
    }
    image(img, bx, by, bw, bh);
  }
}
