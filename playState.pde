

public void raceLoop() {


  //pushStyle();
  //pushMatrix();

  /*
  // DEBUG draw tyre collision points
   rect( car.getTyreWorldPos().get(0).x, car.getTyreWorldPos().get(0).y, 2,2 );
   rect( car.getTyreWorldPos().get(1).x, car.getTyreWorldPos().get(1).y, 2,2 );
   rect( car.getTyreWorldPos().get(2).x, car.getTyreWorldPos().get(2).y, 2,2 );
   rect( car.getTyreWorldPos().get(3).x, car.getTyreWorldPos().get(3).y, 2,2 );
   */

  handleLightning();

  updateSkidLayer();

  sparks.updateSparks(deltaTime);


  skidLayer.updatePixels();
  sparks.drawSparks(skidLayer, 7);
  skidLayer.endDraw();
  noiseMap.updatePixels();
  noiseMap.endDraw();


  track.updateTrack();

  if ( !track.isGenerated ) return;

  track.checkCarPos(car);


  sparks.drawSparks(g, 200);

  //updateDelta();
  car.updateStatus();
  calculateInput(car);
  car.updatePhysics();
  car.calculatePenalty();

  pushStyle();
  //tint(0, 0, 0, 126);
  image(skidLayer, 0, 0);
  popStyle();
  cpm.drawCheckpoints();

  panCarSounds();
  //playEngine(car.getSpeed());
  playElectric(car.getSpeed());
  //playScratch(car.skidAmount);
  //playElectric(car.getEngineLevel()*10);
  car.drawCar(skidLayer);

  // execution gets to  draw car but not to here on explosion. why?

  cpm.evaluateCheckpoints();

  deltaPanel.drawPanel();

  //rect(car.worldPosTest.x,car.worldPosTest.y,30,30);

  drawUI();


  if ( resetKeyPressed ) {
    resetCar();
  }

  if ( drawFrameRate ) debugPrintFPS(width/2-50, height-100);

  dplott.draw();

  


  //popMatrix();
  //popStyle();
}


void resetCar( float x, float y ) {
  
  println("resetting the car to: " + x + "/" + y);
  
  car = new Car( x,y,0 );
  
  //StackTraceElement[] stackTraceElements = Thread.currentThread().getStackTrace();
  //for (StackTraceElement element : stackTraceElements) {
  //  System.out.println(element.toString());
  //}
}


void resetCar() {
  
  PVector initPos = new PVector( width/2, height/2 );

  if ( cpm != null ) {
    if( cpm.checkpoints != null && cpm.checkpoints.size() > 0 ) {
      Checkpoint base = cpm.checkpoints.get(0);
      if ( base != null ) {
        initPos.x = base.tile.center.x;
        initPos.y = base.tile.center.y;
        cpm.newLap(true);
      }
    }
  }
  resetCar( initPos.x, initPos.y );
  
  
}




void drawUI() {

  int gfirst = 70;
  int gsecond = 100;


  pushStyle();
  textSize(25);
  fill(palette.darkGlow);
  text("track:", 50, gfirst);
  fill(palette.mainColorSecondary);
  text( track.trackName, 50, gsecond);
  
  fill(palette.darkGlow);
  text("personal best:", 250, gfirst);
  fill(palette.mainColorSecondary);
  text(cpm.highscores.getPreviousBestTime(), 250, gsecond);

  //fill(palette.darkGlow);
  //text("rank: ", 430, gfirst);
  fill(palette.white);
  text("#"+cpm.highscores.previousHotlapWorldRank, 405, gsecond);

  fill(palette.darkGlow);
  text("session best:", 530, gfirst);
  fill(palette.mainColorSecondary);
  text(cpm.getBestTime(), 530, gsecond);

  //fill(palette.darkGlow);
  //text("rank: ", 710, gfirst);
  fill(palette.white);
  text("#"+cpm.highscores.currentHotlapWorldRank, 685, gsecond);

  fill(palette.darkGlow);
  text("median:", width/2 + 200, gfirst);
  fill(palette.mainColorSecondary);
  text(cpm.getMedianTime(), width/2 + 200, gsecond);

  // draw lap nr
  fill(palette.darkGlow);
  text("Lap:", width/2 - 70, gfirst);
  fill(palette.white);
  text( cpm.validLapCount, (width/2) /*- textWidth(""+cpm.validLapCount)*/, gfirst);

  // draw lapTime
  String timeString = cpm.getTimeElapsed();
  drawLaptime( (width/2) - 90, gsecond, timeString);
  //text(timeString, width/2-textWidth(timeString)/2, gsecond);

  fill(palette.darkGlow);
  text("tires:", width-200, gfirst);
  if ( car.tyreTempPenalty > 0.3 ) {
    if ( car.tyreTempPenalty > 0.8 && frameCount % 20 < 10) {
      fill(0);
    } else {
      fill(255);
    }
    text("hot", width-200, gsecond);
  } else if (car.tyreTempPenalty < -0.3) {
    if ( car.tyreTempPenalty < -0.8 && frameCount % 20 < 10) {
      fill(0);
    } else {
      fill(palette.mainColorPrimary);
    }
    text("cold", width-200, gsecond);
  } else {
    fill(palette.mainColorSecondary);
    text("optimal", width-200, gsecond);
  }
  popStyle();
  
  if ( drawTyreInfo ) {

    pushStyle();
    textSize(25);
    line( 50, 110, 50, 160);
    line( 150, 110, 150, 160);
    line( 250, 110, 250, 160);
    line( 350, 110, 350, 160);
    line( 450, 110, 450, 160);
    rect( 50, 120, 2*car.tyreSurfaceTemp, 10 ); // debug tyreTemp     2*car.tyreSurfaceTemp / car.tyreTempMaxDisplay
    rect( 50, 140, 2*car.tyreCarcasseTemp, 10 ); // debug tyreTemp     2*car.tyreSurfaceTemp / car.tyreTempMaxDisplay
    text( ""+(int)(car.tyreSurfaceTemp/10), 10, 125);
    text( ""+(int)(car.tyreCarcasseTemp/10), 10, 155);

    if ( car.tyreTempPenalty > 0 ) {
      stroke( 200, 0, 0 );
      fill( 180, 20, 20 );
    } else {
      stroke( 0, 0, 200 );
      fill( 20, 20, 180 );
    }
    rect( 50, 131, abs(car.tyreTempPenalty) * 100, 5 );
    popStyle();
  }
}


void drawLaptime(int x, int y, String timeString) {

  fill(palette.mainColorPrimary);

  //x -= textWidth(timeString)/2;

  // Iterate over each character in the timeString
  for (int i = 0; i < timeString.length(); i++) {
    char c = timeString.charAt(i);
    // Draw the character at the current position
    text(c, x, y);
    // Move x to the right by the width of the character
    x += textWidth(c);
  }
}




public void updateDelta() {

  //deltaTime = (1000 / frameRate);


  int millis = millis();
  deltaTime = millis - lastFrameMillis;
  lastFrameMillis = millis;

  delta = deltaTime * deltaFactor;
}



public void updateSkidLayer() {

  /// POPULATE THE NOISE MAP

  noiseMap.beginDraw();
  noiseMap.loadPixels();
  //noiseMap.background(0,255,0);
  for (int x = 0; x < noiseMap.width; x++) {
    for (int y = 0; y < noiseMap.height; y++) {

      float n = noise(x/50f, y/50f, noiseMapSeed)*255;
      noiseMap.pixels[y*noiseMap.width+x] = color(0, 0, n);
    }
  }
  noiseMapSeed += 0.003;

  // MULTIPLY SKID LAYER WITH NOISE MAP

  skidLayer.beginDraw();
  skidLayer.loadPixels();

  for (int x = 0; x < skidLayer.width; x++ ) {
    for (int y = 0; y < skidLayer.height; y++ ) {
      if (skidLayer.pixels[y*skidLayer.width+x] != 0 ) {
        int noiseX = x/noiseMapSizeFactor;
        int noiseY = y/noiseMapSizeFactor;
        int noiseP = noiseY*noiseMap.width+noiseX;
        if ( noiseP < noiseMap.pixels.length ) {
          int n = noiseMap.pixels[noiseP] & 0xFFFFFF; // get r,g,b,noalpha
          int a = skidLayer.pixels[y*skidLayer.width+x] & 0xFF000000; // get only alpha
          skidLayer.pixels[y*skidLayer.width+x] = a | n;
        }
      }
    }
  }
}
