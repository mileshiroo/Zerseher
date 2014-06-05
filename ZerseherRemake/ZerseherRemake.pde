// Homage to "Zerseher" by Joachim Sauter, 1992.
//
// Resurrected by Golan Levin and Miles Peyton at the STUDIO 
// for Creative Inquiry. 

PImage caroto; 
PGraphics patch; 
PGraphics carotoGraphics; 
PGraphics carotoBehind;
float resetfade;
float elapsedSec;
int behindDelay = 30*5;
int assumeVisitorLeft = 30*10;
int waiting = 0;
int looktime;
int x, y;
int px, py;
int difx, dify;
int imgx, imgy;
int fadeTime = 1;
boolean looking = true;
TETSimple eyeTribe;


void setup() {
  caroto = loadImage("caroto.jpg"); 
  carotoGraphics = createGraphics (caroto.width, caroto.height); 
  // Buffer to hold older version of image, to create layering effect. 
  carotoBehind = createGraphics (caroto.width, caroto.height);
  reset();
  image (carotoGraphics, 0, 0);
  // Interface to eyeTribe server to get eye position. 
  eyeTribe = new TETSimple();
  eyeTribe.main(eyeTribe);
  size(displayWidth, displayHeight);
  // Calculate offset to center image.
  difx = (width  - caroto.width)/2; 
  dify = (height - caroto.height)/2;
  // Upper-left coordinate of image. 
  imgx = width/2-carotoGraphics.width/2; 
  imgy = height/2-carotoGraphics.height/2;
}

void draw() {
  // Fetch latest eye position. 
  x = int(eyeTribe.getX(eyeTribe)); 
  x = constrain(x, 0, width);
  y = int(eyeTribe.getY(eyeTribe)); 
  y = constrain(y, 0, height);

  checkVisitorLeft();

  if (frameCount % behindDelay == 0) {
    carotoBehind.clear();
    carotoBehind.beginDraw();
    carotoBehind.copy(carotoGraphics, 0, 0, caroto.width, caroto.height, 0, 0, carotoBehind.width, carotoBehind.height);
    carotoBehind.endDraw();
  }

  float minR = 0; 
  float maxR = 30; 

  elapsedSec = (millis() - looktime)/1000.0;
  float minPatchSize = 10 * (1 + elapsedSec*0.25); 
  float maxPatchSize = 30 * (1 + elapsedSec*0.25);

  int mx = (int)(0.5 * abs(x - px));
  int my = (int)(0.5 * abs(y - py));
  mx = min (mx, 30); 
  my = min (my, 30); 

  rectMode (CENTER); 
  int nPatches = 3; 
  float maxOffset = 6.0; 
  float likelihoodOfFetchingBehind = 0.01; 

  if (looking) {

    for (int i=0; i<nPatches; i++) {

      // randomized radial offset
      float radius = random (-maxR, maxR) + random (-maxR, maxR) + random (-maxR, maxR) ; 
      float theta  = random (0, TWO_PI); 

      // source patch location: randomly offset from the mouse
      int sx = (int)(round (x + radius * cos (theta))); // fetch loc
      int sy = (int)(round (y + radius * sin (theta))); 

      // source patch size
      int sw = (int)(round ( random (minPatchSize, maxPatchSize))); 
      int sh = (int)(round ( random (minPatchSize, maxPatchSize))); 

      // destination patch size
      int dw = sw + mx; 
      int dh = sh + my; 

      // add random stretching to patch
      if (random(1.0) < 0.5) {
        dw += 10;
      } else {
        dh += 10;
      }

      patch = createGraphics(dw, dh);

      // destination offset
      int ox = (int)(round (random(-maxOffset, maxOffset))); 
      int oy = (int)(round (random(-maxOffset, maxOffset))); 

      // Either use current carotoGraphics as a source, or carotoBehind which is an older version of carotoGraphics. 
      patch.beginDraw(); 
      if (random(1.0) < likelihoodOfFetchingBehind) { 
        patch.copy (carotoBehind, sx - difx - sw/2, sy- dify - sh/2, sw, sh, 0, 0, dw, dh);
      } else {
        patch.copy (carotoGraphics, sx-sw/2-difx, sy-sh/2-dify, sw, sh, 0, 0, dw, dh);
      }
      patch.endDraw(); 

      carotoGraphics.beginDraw(); 
      carotoGraphics.image (patch, sx+ox-dw/2-difx, sy+oy-dh/2-dify, dw, dh); 
      carotoGraphics.endDraw();
    }
  }
  float fade = elapsedSec/float(fadeTime);
  tint(255, int(fade * 255));
  image (carotoGraphics, imgx, imgy);
  px = x; 
  py = y;
  if (frameCount % 30 == 0) System.gc();
}

// Assumes visitor left if no change in eyePosition for several seconds,
// at which point the sketch resets.
void checkVisitorLeft() {
  if (x == px && y == py) {
    waiting++;
    if (waiting >= assumeVisitorLeft) {
      waiting = 0;
      reset();
    }
  } else if (!looking) {
    looking = true;
  }
} 

void keyPressed() {
  reset();
}

void reset() {
  elapsedSec = 0;
  looking = false;
  looktime = millis();
  carotoGraphics.beginDraw(); 
  carotoGraphics.image (caroto, 0, 0);
  carotoGraphics.endDraw();
  carotoBehind.clear();
  carotoBehind.beginDraw();
  carotoBehind.copy(caroto, 0, 0, caroto.width, caroto.height, 0, 0, carotoBehind.width, carotoBehind.height);
  carotoBehind.endDraw();
}

