public void raceLoop() {
  
  
  
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
  calculateInput(car);
  car.updatePhysics();
  
  pushStyle();
  //tint(0, 0, 0, 126);
  image(skidLayer, 0, 0);
  popStyle();
  cpm.drawCheckpoints();
  
  //playEngine(car.getSpeed());
  playElectric(car.getSpeed());
  car.drawCar(skidLayer);
  
  cpm.evaluateCheckpoints();

  deltaPanel.drawPanel();

  //rect(car.worldPosTest.x,car.worldPosTest.y,30,30);

  

  textSize(25);
  fill(palette.darkGlow);
  text("best:", 100, 100);
  text(cpm.getBestTime(), 230, 100);
  text("median:", 100, 130);
  text(cpm.getMedianTime(), 230, 130);
  
  
  
  if ( resetKeyPressed ) {
    car = new Car( width/2, height/2, 0);
    //iptrack = new Track();
    /*skidLayer = createGraphics(width,height);
    cpm.checkpoints = new ArrayList();
    cpm.bestLapTime = 999999999999999999l;
    playYeah();*/
  }
  
  debugPrintFPS(width/2, 100);
  dplott.draw();
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
