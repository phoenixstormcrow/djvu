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
