Maxim maxim;
Board board;
ControlPanel cpanel1;
ControlPanel cpanel2;
Master master;
  
void setup()
{
  size(1000, 500);
  background(BLUE);
  maxim = new Maxim(this);
  
  board = new Board();
  cpanel1 = new ControlPanel(0, 0, 400, 500);
  master = new Master(400, 0, 200, 500);
  cpanel2 = new ControlPanel(600, 0, 400, 500);
  cpanel1.load(TRK1_DEF);
  cpanel2.load(TRK2_DEF);
  
}

void draw()
{
  background(BLUE);
  board.draw();
  cpanel1.draw();
  master.draw();
  cpanel2.draw();
}

void mousePressed()
{
  cpanel1.mousePressed();
  cpanel2.mousePressed();
  master.mousePressed();
}

void mouseClicked()
{
  if (master.playButton.mouseOver()) {
    master.playClicked();
  }
  if (cpanel1.playButton.mouseOver()){
    cpanel1.playClicked();
  }
  if (cpanel1.loopButton.mouseOver()) {
    cpanel1.loopClicked();
  }
  if (cpanel1.chooseButton.mouseOver()) {
    cpanel1.chooseClicked();
  }
  if (cpanel2.playButton.mouseOver()){
    cpanel2.playClicked();
  }
  if (cpanel2.loopButton.mouseOver()) {
    cpanel2.loopClicked();
  }
  if (cpanel2.chooseButton.mouseOver()) {
    cpanel2.chooseClicked();
  }
}

void mouseDragged()
{
  cpanel1.mouseDragged();
  cpanel2.mouseDragged(); 
  master.mouseDragged();
}

