public void raceLoop() {
  
  if( car.hasStatus(StatusType.DESTRUCTION) ) {
    println("explo");
  }
  
  //pushStyle();
  //pushMatrix();
  
  /*
  // DEBUG draw tyre collision points
  rect( car.getTyreWorldPos().get(0).x, car.getTyreWorldPos().get(0).y, 2,2 );
  rect( car.getTyreWorldPos().get(1).x, car.getTyreWorldPos().get(1).y, 2,2 );
  rect( car.getTyreWorldPos().get(2).x, car.getTyreWorldPos().get(2).y, 2,2 );
  rect( car.getTyreWorldPos().get(3).x, car.getTyreWorldPos().get(3).y, 2,2 );
  */
  
  
  updateSkidLayer();
  
  sparks.updateSparks(deltaTime);
  
  
  skidLayer.updatePixels();
  sparks.drawSparks(skidLayer, 7);
  skidLayer.endDraw();
  noiseMap.updatePixels();
  noiseMap.endDraw();

  
  track.updateTrack();  
  
  if( !track.isGenerated ) return;
  
  track.checkCarPos(car);
  
  
  sparks.drawSparks(g, 200);
  
  updateDelta();
  car.updateStatus();
  calculateInput(car);
  car.updatePhysics();
  
  pushStyle();
  //tint(0, 0, 0, 126);
  image(skidLayer, 0, 0);
  popStyle();
  cpm.drawCheckpoints();
  
  //playEngine(car.getSpeed());
  playElectric(car.getSpeed());
  
  //playElectric(car.getEngineLevel()*10);
  car.drawCar(skidLayer);
  
    // execution gets to  draw car but not to here on explosion. why?
  
  cpm.evaluateCheckpoints();

  deltaPanel.drawPanel();

  //rect(car.worldPosTest.x,car.worldPosTest.y,30,30);

  int gfirst = 70;
  int gsecond = 100;

  textSize(25);
  fill(palette.darkGlow);
  text("track:", 50,gfirst);
  fill(palette.mainColorSecondary);
  text( track.trackName, 50, gsecond);
  
  fill(palette.darkGlow);
  text("best:", 250, gfirst);
  fill(palette.mainColorSecondary);
  text(cpm.getBestTime(), 250, gsecond);
  
  fill(palette.darkGlow);
  text("median:", 450, gfirst);
  fill(palette.mainColorSecondary);
  text(cpm.getMedianTime(), 450, gsecond);
  
  
  if ( resetKeyPressed ) {
    car = new Car( width/2, height/2, 0);
  }
  
  debugPrintFPS(width/2, height-100);
  
  dplott.draw();
  line( 50, 110, 50, 160);
  line( 150, 110, 150, 160);
  line( 250, 110, 250, 160);
  line( 350, 110, 350, 160);
  line( 450, 110, 450, 160);
  rect( 50, 120, 2*car.tyreSurfaceTemp , 10 ); // debug tyreTemp     2*car.tyreSurfaceTemp / car.tyreTempMaxDisplay
  rect( 50, 140, 2*car.tyreCarcasseTemp , 10 ); // debug tyreTemp     2*car.tyreSurfaceTemp / car.tyreTempMaxDisplay
  text( ""+(int)(car.tyreSurfaceTemp/10), 10,125);
  text( ""+(int)(car.tyreCarcasseTemp/10), 10,155);
  //popMatrix();
  //popStyle();
}



public void updateDelta() {
  
  deltaTime = (1000 / frameRate);
  
  /*
  int millis = millis();
  deltaTime = millis - lastFrameMillis;
  lastFrameMillis = millis;
  */
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
      noiseMap.pixels[y*noiseMap.width+x] = color(0,0,n);
    }
  }
  noiseMapSeed += 0.003;
  
  // MULTIPLY SKID LAYER WITH NOISE MAP
  
  skidLayer.beginDraw();
  skidLayer.loadPixels();

  for(int x = 0; x < skidLayer.width; x++ ) {
    for(int y = 0; y < skidLayer.height; y++ ) {
      if(skidLayer.pixels[y*skidLayer.width+x] != 0 ) {
        int noiseX = x/noiseMapSizeFactor;
        int noiseY = y/noiseMapSizeFactor;
        int noiseP = noiseY*noiseMap.width+noiseX;
        if( noiseP < noiseMap.pixels.length ) {
          int n = noiseMap.pixels[noiseP] & 0xFFFFFF; // get r,g,b,noalpha
          int a = skidLayer.pixels[y*skidLayer.width+x] & 0xFF000000; // get only alpha
          skidLayer.pixels[y*skidLayer.width+x] = a | n;  
        }
      }
    }            
  }
}
