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

