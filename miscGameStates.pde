boolean boomPlayed = false;
float opa = 255;
float opa2 = 0;

public void trackSelectLoop() {
  
  
  
  
}



public void introLoop() {
  
  
  if( !boomPlayed ) {
    playBoom();
    boomPlayed = true;
    playStatic(true);
  }
  
  float titleSize = 150;
  String title = "ImmoRally";
  
  skidLayer.beginDraw();
  skidLayer.pushStyle();
  skidLayer.fill(palette.black);
  skidLayer.textFont(font);
  skidLayer.fill(palette.mainColorPrimary);
  skidLayer.textSize(titleSize);
  skidLayer.text( title, width/2 - skidLayer.textWidth(title)/2, height/2 );
  skidLayer.endDraw();
  skidLayer.popStyle();
  
  
  updateSkidLayer();
  image(skidLayer, 0, 0);
  
  pushStyle();
  
  textFont(font);
  fill(palette.mainColorPrimary, opa);
  if( opa > 1 ) {
    opa-=0.11;  
  }
  textSize(titleSize);
  text( title, 3+width/2 - textWidth(title)/2, height/2 );
  
  
  if( frameCount > 900 ) {
    if( opa2 < 1 ) opa2 = 1;
    String pressPlay = "press key to play";
    textSize(30);
    fill(palette.darkGlow, opa2 );
    text(pressPlay, width/2 - textWidth(pressPlay)/2, height/2 + 100 );
    //text(pressPlay, mouseX,mouseY );
    opa2 += 0.08;
  }
  popStyle();
  
  int k = 0+key;
  //println(k);
  if( k != 0 ) {
    skidLayer = createGraphics(width, height);
    gameState = State.RACE;
  }
}
