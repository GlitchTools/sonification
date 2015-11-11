

// Sonification, image as sound

// Reimplementation of image -> raw -> wav -> audacity filters -> wav -> raw -> image process
// Tomasz Sulej, generateme.blog@gmail.com, http://generateme.tumblr.com
// Bob Verkouteren, bob.verkouteren@gmail.com, http://applesandchickens.com 
// Modified for web by Thijs
// Licence: http://unlicense.org/

// Usage:
//   * press SPACE to save
//   * c or click to randomize effect settings
//   * f to randomize filters
//   * r to randomize raw settings
//   * b to batch process files from folder, set folder and filename below
// set up filename
/* @pjs preload="test.jpg"; */
String filename = "test";
String fileext = ".jpg";
String foldername = ""; // it is used also for batch processing

int max_display_size = 1600; // viewing window size (regardless image size)

boolean do_blend = false; // blend image after process
int blend_mode = OVERLAY; // blend type

boolean make_equalize = true; // equalize and normalize histogram

// image reader config
int r_rawtype = PLANAR; // planar: rrrrr...ggggg....bbbbb; interleaved: rgbrgbrgb...
int r_law = A_LAW; // NONE, A_LAW, U_LAW
int r_sign = UNSIGNED; // SIGNED or UNSIGNED
int r_bits = B8; // B8, B16 or B24, bits per sample
int r_endianess = LITTLE_ENDIAN; // BIG_ENDIAN or LITTLE_ENDIAN
int r_colorspace = RGB; // list below 

// image writer config
int w_rawtype = PLANAR; // planar: rrrrr...ggggg....bbbbb; interleaved: rgbrgbrgb...
int w_law = A_LAW; // NONE, A_LAW, U_LAW
int w_sign = UNSIGNED; // SIGNED or UNSIGNED
int w_bits = B8; // B8, B16 or B24, bits per sample
int w_endianess = LITTLE_ENDIAN; // BIG_ENDIAN or LITTLE_ENDIAN
int w_colorspace = RGB; // list below
final static int[] blends = {ADD, SUBTRACT, DARKEST, LIGHTEST, DIFFERENCE, EXCLUSION, MULTIPLY, SCREEN, OVERLAY, HARD_LIGHT, SOFT_LIGHT, DODGE, BURN};

// put list of the filters { name, sample rate }
float[][] filters = {
//  {DJEQ, 44100},
//  {COMB, 44100},
//  {VYNIL, 44100},
  {CANYONDELAY, 44100}, 
//  {VCF303 , 44100},
//  {ECHO, 44100},
//  {PHASER, 44100},
//  {WAHWAH , 44100},
//  {BASSTREBLE, 44100},
//  {SHIFTR, 44100},
//  {TAPSIGMOID, 44100},
//  {TAPAUTOPAN, 44100},
//  {RANDMIX, 44100},
//  {DIVIDER, 44100},
//  {LFOPHASER, 44100},
//  {FOURBYFOURPOLE, 44100},
//  {AUTOPHASER, 44100},
//  {AUAMPLIFY, 44100},
//  {TREVERB, 44100},
//  {VACUUMTAMP, 44100},
//  {ZAMTUBE, 44100}, // this is insanely slow!
//  {RESON, 44100},
//    {PLUCKEDSTRING,44100},
};

// add here filters you don't want to see in random mode ('f')
// int[] excluded_filters = { ZAMTUBE };

// this function is called before each file processing in batch mode
// adjust your parameters here
// step has value from 0 (inclusive) to 1 (exclusive)
void batchCallback(float step) {
  // example, setup filters[][] to have only FOURBYFOURPOLE 
//  
//  DjEq f = (DjEq)filterchain.get(0);
//  f.lo = map(sin(step*TWO_PI),-1,1,100,1000);
//  f.shelf_slope = map(sin(step*TWO_PI+1.0),-1,1,0.1,1.1);
//  f.initialize();
//  
//    FourByFourPole f = (FourByFourPole)filterchain.get(0);
//    float bf = map(sin(step*TWO_PI),-1,1,100,1000);
//    f.f0 = bf;
//    f.f1 = bf+4000.0;
//    f.f2 = bf+8000.0;
//    f.f3 = bf+12000.0;
//    f.fb0 = cos(step*TWO_PI)/10;
//    f.fb1 = cos(step*TWO_PI+1)/8.0+0.01;
//    f.fb2 = cos(step*TWO_PI+2)/6.0-0.1;
//    f.fb3 = cos(step*TWO_PI-1)/12.0+0.2;
//    f.initialize();
}

// EFFECTS!
final static int NOFILTER = -1;
final static int DJEQ = 0;
final static int COMB = 1;
final static int VYNIL = 2;
final static int CANYONDELAY = 3; 
final static int VCF303 = 4;
final static int ECHO = 5; 
final static int PHASER = 6;
final static int WAHWAH = 7;
final static int BASSTREBLE = 8; 
final static int SHIFTR = 9;
final static int TAPSIGMOID = 10;
final static int TAPAUTOPAN = 11;
final static int RANDMIX = 12;
final static int DIVIDER = 13;
final static int LFOPHASER = 14;
final static int FOURBYFOURPOLE = 15;
final static int AUTOPHASER = 16;
final static int AUAMPLIFY = 17;
final static int TREVERB = 18;
final static int VACUUMTAMP = 19;
final static int ZAMTUBE = 20; // this is insanely slow!
final static int RESON = 21;
final static int PLUCKEDSTRING = 22;

// colorspaces, NONE: RGB
final static int OHTA = 1001;
final static int CMY = 1002;
final static int XYZ = 1003;
final static int YXY = 1004;
final static int HCL = 1005;
final static int LUV = 1006;
final static int LAB = 1007;

// configuration constants
final static int A_LAW = 0;
final static int U_LAW = 1;
final static int NONE = 2;

final static int UNSIGNED = 0;
final static int SIGNED = 1;

final static int B8 = 8;
final static int B16 = 16;
final static int B24 = 24;

final static int LITTLE_ENDIAN = 0;
final static int BIG_ENDIAN = 1;

final static int PLANAR = 0;
final static int INTERLEAVED = 1;

// working buffer
PGraphics buffer;

// image
PImage img;

String sessionid;

AFilter afilter; // filter handler
RawReader isr; // image reader
RawWriter isw; // image writer
ArrayList<AFilter> filterchain = new ArrayList<AFilter>();



void setup() { 

  sessionid = hex((int)random(0xffff),4);
  img = loadImage(foldername+filename+fileext);
 
  buffer = createGraphics(img.width, img.height);
  buffer.beginDraw();
  buffer.noStroke();
  buffer.smooth(8);
  buffer.background(0);
  buffer.image(img,0,0);
  buffer.endDraw();

  // calculate window size
  float ratio = (float)img.width/(float)img.height;
  int neww, newh;
  if(ratio < 1.0) {
    neww = (int)(max_display_size * ratio);
    newh = max_display_size;
  } else {
    neww = max_display_size;
    newh = (int)(max_display_size / ratio);
  } 

  size(neww,newh);
  background(0);

//init_helper();

  isr = new RawReader(img.get(), r_rawtype, r_law, r_sign, r_bits, r_endianess);
  isr.r.convertColorspace(r_colorspace);
  isw = new RawWriter(img.get(), w_rawtype, w_law, w_sign, w_bits, w_endianess);

  //prepareFilters(filters);
  afilter = new CanyonDelay(isr, 44100.0);
  afilter.initialize();

  noLoop();
  //printConfig();

  //processImage()
}
void draw() { 
  
  // afilter.randomize();
   for(int i=0; i<img.width*img.height*3;i++) {
   isw.write(afilter.read());
   }
   
//   equalize(isw.w.wimg.pixels);
//   isw.w.wimg.updatePixels();
   
   image(isw.w.wimg,0,0);
   
   isr.reset();
   isw.reset();
}



