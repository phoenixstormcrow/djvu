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
/* the control panel for a track.
   there will be two of these in the app.
*/

class ControlPanel
{
  AudioPlayer player;
  Scale volumeScale;
  VSlider volumeSlider;
  Scale speedScale;
  VSlider speedSlider;
  Scale freqScale;
  VSlider freqSlider;
  Scale QScale;
  VSlider QSlider;
  
  ProgressBar progressBar;
  
  Button playButton;
  Button loopButton;
  Button chooseButton;
  
  String track;
  
  int panelWidth, panelHeight, panelX, panelY; // dimensions and offsets
  
  float freq, q;
  
  float sampLength = 0; // ms
  float playStart; // time at which track starts
  float playProgress; // how much of track has played
  
  var chooser; // Chooser object defined in filechooser.js
  boolean choosing = false;
  
  ControlPanel(int x, int y, int w, int h) {
    panelWidth = w;
    panelHeight = h;
    panelX = x;
    panelY = y;
    
    volumeScale = new Scale(160, 60, 0, 1.0);
    volumeSlider = new VSlider(panelX + 25, volumeScale, INIT_VOL);
    speedScale = new Scale(160, 60, 0, 2.0);
    speedSlider = new VSlider(panelX + 125, speedScale, INIT_SPEED);
    freqScale = new Scale(160, 60, 40, 20000);
    freqSlider = new VSlider(panelX + 225, freqScale, INIT_FREQ);
    QScale = new Scale(160, 60, 0, 1);
    QSlider = new VSlider(panelX + 325, QScale, INIT_Q);
    
    freq = freqSlider.value;
    q = QSlider.value * Q_MULT;
    
    progressBar = new ProgressBar(panelX + 50, panelY + 300, panelWidth - 100, 30);
    
    playButton = new Button(PLAY, ALTPLAY, 50, 50, panelX + 75, panelY + panelHeight - 125);
    loopButton = new Button(LOOP, ALTLOOP, 50, 50, panelX + 175, panelY + panelHeight - 125);
    chooseButton = new Button(CHOOSE, ALTCHOOSE, 50, 50, panelX + 275, panelY + panelHeight - 125);
    
    chooser = new Chooser(fsys);
  }
  
  void load(String filename) {
    track = filename;
    if (player) player.stop();
    if (playButton.on) playButton.toggle();
    player = maxim.loadFile(filename);
    // loop by default
    player.setLooping(true);
    if (!loopButton.on) {
      loopButton.toggle();
    }
    player.volume(volumeSlider.value * master.volumeSlider.value);
    // setting speed here doesn't work. perhaps it has to be playing?
  }
  
  void draw() {
    volumeSlider.draw();
    speedSlider.draw();
    freqSlider.draw();
    QSlider.draw();
    
    // if not looping and at end of track we need to stop
    if (!loopButton.on && (millis() - playStart) > sampLength) {
      player.stop();
      if (playButton.on) playButton.toggle();
    }
      
    //progress bar
    if (player.isPlaying()) {     
      progressBar.draw();
    } else {
      if (!player.loaded) {
        progressBar.loading(player.progress);
      }
    }
    
    playButton.draw();
    loopButton.draw();
    
    if (!chooser.visible) {
        chooseButton.on = false;
    }
    chooseButton.draw();
    
    if (choosing && chooser.selected) {
      choosing = false;
      load(chooser.selected);
      chooseButton.toggle();
    }
  }
  

  void play() {
    if (loopButton.on) {
      player.setLooping(true);
    } else {
      player.setLooping(false);
    }
    
    player.play();
    playStart = millis();
    sampLength = player.getLengthMs();
    
    player.speed(speedSlider.value);
    setFilter(freq, q);
    progressBar.configure(sampLength, playStart, speedSlider.value);
  }
  
  void playClicked() {
    playButton.toggle();
    if (playButton.on) {
      if (!master.playButton.on) {
        master.playButton.toggle();
      }
      play();
    } else {
      player.stop();
    }
  }

  void loopClicked() {
    loopButton.toggle();
    if (loopButton.on) {
      player.setLooping(true);
    } else {
      if (player.isPlaying()) { //not happy with the way this works. Should play to end then stop
        player.stop();
      }
      if (playButton.on) {
        playButton.toggle();
      }
      player.setLooping(false);
     }
  }
  
  void chooseClicked() {
    chooseButton.toggle();
    chooser.show();
    choosing = true;
  }
  
  void mouseDragged() {
    if (volumeSlider.selected) {
      volumeSlider.move();
      player.volume(volumeSlider.value * master.volumeSlider.value); // master is global
    }
    if (speedSlider.selected) {
      speedSlider.move();
      player.speed(speedSlider.value);
      progressBar.configure(sampLength, playStart, speedSlider.value);
    }
    if (freqSlider.selected) {
      freqSlider.move();
      freq = freqSlider.value;
      setFilter(freq, q);
    }
    if (QSlider.selected) {
      QSlider.move();
      q = QSlider.value * Q_MULT;
      setFilter(freq, q);
    }
  }

  void mousePressed() {
    if (volumeSlider.mouseOver() && !volumeSlider.selected) {
      volumeSlider.selected = true;
    }
    if (!volumeSlider.mouseOver() && volumeSlider.selected) {
      volumeSlider.selected = false;
    }
    if (speedSlider.mouseOver() && !speedSlider.selected) {
      speedSlider.selected = true;
    }
    if (!speedSlider.mouseOver() && speedSlider.selected) {
      speedSlider.selected = false;
    }
    if (freqSlider.mouseOver() && !freqSlider.selected) {
      freqSlider.selected = true;
    }
    if (!freqSlider.mouseOver() && freqSlider.selected) {
      freqSlider.selected = false;
    }
    if (QSlider.mouseOver() && !QSlider.selected) {
      QSlider.selected = true;
    }
    if (!QSlider.mouseOver() && QSlider.selected) {
      QSlider.selected = false;
    }
  }
  
  void setFilter(float freq, float q) {
  /* adapted from http://www.html5rocks.com/en/tutorials/webaudio/intro/js/filter-sample.js */
    freq = pow(2, N_OCTAVES * ((freq / FREQ_MAX) - 1)) * FREQ_MAX;
    player.setFilter(freq, q);
  }   
}
/* the master panel
   controls master volume and crossfade between tracks,
   has a play button which starts both tracks
*/

class Master
{
  Scale volumeScale;
  VSlider volumeSlider;
  Scale crossFadeScale;
  HSlider crossFadeSlider;
  
  Button playButton;
  
  int masterX, masterY, masterWidth, masterHeight;
  
  Master(int x, int y, int w, int h) {
    masterX = x;
    masterY = y;
    masterWidth = w;
    masterHeight = h;
    
    volumeScale = new Scale(160, 60, 0, 1.0);
    volumeSlider = new VSlider(masterX + 75, volumeScale, INIT_VOL);
    
    crossFadeScale = new Scale(masterX + 140, masterX + 40, 0, 1.0);
    crossFadeSlider = new HSlider(masterY + 250, crossFadeScale, INIT_CROSS);
    
    playButton = new Button(PLAY, ALTPLAY, 50, 50, masterX + 75, masterY + masterHeight - 125);
  }
  
  void draw() {
    volumeSlider.draw();
    crossFadeSlider.draw();
    playButton.draw();
  }
  
  void mousePressed() {
    if (volumeSlider.mouseOver() && !volumeSlider.selected) {
      volumeSlider.selected = true;
    }
    if (!volumeSlider.mouseOver() && volumeSlider.selected) {
      volumeSlider.selected = false;
    }
   if (crossFadeSlider.mouseOver() && !crossFadeSlider.selected) {
      crossFadeSlider.selected = true;
    }
    if (!crossFadeSlider.mouseOver() && crossFadeSlider.selected) {
      crossFadeSlider.selected = false;
    }
  }
  
  void playClicked() {
    playButton.toggle();
    cpanel1.playButton.on = playButton.on;
    cpanel2.playButton.on = playButton.on;
    
    if (playButton.on) {
      cpanel1.play();
      cpanel2.play();
    } else {
      cpanel1.player.stop();
      cpanel2.player.stop();
    }
  }

  void mouseDragged() { // cpanel1 and 2 are globals
    if (volumeSlider.selected) {
      volumeSlider.move();
      cpanel1.player.volume(cpanel1.volumeSlider.value * volumeSlider.value);
      cpanel2.player.volume(cpanel2.volumeSlider.value * volumeSlider.value);
    }
    if (crossFadeSlider.selected) {
    /* crossfade using equal-power curve.
       adapted from http://www.html5rocks.com/en/tutorials/webaudio/intro/js/crossfade-sample.js
    */
      float val;
      crossFadeSlider.move();
      val = crossFadeSlider.value;
      cpanel2.player.volume(cos(val * HALF_PI) * volumeSlider.value);
      cpanel1.player.volume(cos((1.0 - val) * HALF_PI) * volumeSlider.value);
    }
  }
}
class ProgressBar
{
  float sampLength, playStart, playProgress, speed;
  int x;
  int y, w, h;
  
  ProgressBar(int X, int Y, int W, int H) {
    x = X;
    y = Y;
    w = W;
    h = H;
  }
    
  void configure(float l, float st, float sp) {
    sampLength = l;
    playStart = st;
    speed = sp;
  }
  
  void draw() {
    playProgress = ((millis() - playStart) % (sampLength / speed)) / (sampLength / speed);
    fill(PROGRESS);
    rect(x, y, w * playProgress, 30);
  }
  
  void loading(float progress) {
    fill(LOAD_PROGRESS);
    noStroke();
    rect(x, y, w * progress, 30);
  }
}
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
/*

there is a bug with the crossfade. The crossfade value gets overridden whenever another volume control is changed.
probably not gonna fix it today.

*/
/* I should go back and use these constants at some point */
int WIDTH = 1000;
int HEIGHT = 500;

color BLUE = color(33, 33, 236);//hex: 2121ec
//color PANEL = color(100);
color PROGRESS = color(33, 33, 236, 128);
color LOAD_PROGRESS = color(236, 33, 33, 128);

String TRK1_DEF = "dub-breakbeat.wav";
String TRK2_DEF = "choir-nec-invenit-requiem.wav";

float INIT_VOL = 0.0;
float INIT_SPEED = 1.0;
float INIT_CROSS = 0.5;
float INIT_FREQ = 20000;
float INIT_Q = 0;
float FREQ_MAX = 20000;
float FREQ_MIN = 40;
float N_OCTAVES = log(FREQ_MAX / FREQ_MIN) / log(2);
float Q_MULT = 30;

String VSLIDE = "vslider.png";
String HSLIDE = "hslider.png";
String PLAY = "playbtn.png";
String ALTPLAY = "altplaybtn.png";
String LOOP = "loopbtn.png";
String ALTLOOP = "altloopbtn.png";
String CHOOSE = "choosebtn.png";
String ALTCHOOSE = "altchoosebtn.png";

/*

sounds:

choir-nec-invenit-requiem.wav
from http://www.freesound.org/people/klankbeeld/

dub-breakbeat.wav
from http://www.freesound.org/people/usinggarageband/sounds/152652/

____________
maxim.js:

aside from some simple callbacks I stuck in there, maxim is due to these fine folks.

Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies

__________________
filesystem api:
I could not have implemented the ability to import local audio files into the app without the tutorial at
http://www.html5rocks.com/en/tutorials/file/filesystem

*/

