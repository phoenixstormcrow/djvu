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
