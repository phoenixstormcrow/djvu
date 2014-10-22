/* this is the entire mixing board interface
   all the components will be children of this object
   in an upcoming version
*/

class Board {
  PImage bimg;
  
  Board() {
    bimg = loadImage("board.png");
  }
  
  void draw() {
    image(bimg, 0, 0, 1000, 500);
  }
  
}
