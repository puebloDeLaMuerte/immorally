public void debugPrintFPS(int x, int y ) {
  pushStyle();
  //fill(255);
  textSize(25);
  fill(palette.darkGlow);
  text( frameRate, x,y);
  popStyle();
}


public void debugPrintDeltas() {
  text("deltaTime:" + deltaTime, 230, 300);
  text("delta    :" + delta, 230, 330);
}

void debugDrawCarData(Car car, int inx, int iny) {
  pushStyle();
  rectMode(RADIUS);
  int w  =15;
  int x = inx;
  int y = iny;
  fill(140,0,0);
  rect( x,y, car.acceleration * 3000, w);
  //rect( x,y, car.)
  
  y += 30;
  fill(0,0140,0);
  rect( x,y, car.breaking * 3000, w);
  
  y += 30;
  fill(0,0,100);
  rect( x,y, car.getSpeed() * 20, w);
  
  y += 30;
  fill(200);
  rect( x,y, car.skidAmount * 20, w);
  
  popStyle();
}
