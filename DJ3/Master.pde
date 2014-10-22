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
