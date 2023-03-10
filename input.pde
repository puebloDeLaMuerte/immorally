char accelerateKey = 'w';
boolean accelKeyPressed;

char breakKey = 's';
boolean breakKeyPressed;

char turnLeftKey = 'a';
boolean turnLeftPressed;

char turnRightKey = 'd';
boolean turnRightPressed;

char resetKey = 'r';
boolean resetKeyPressed;

char newTrackKey = 'T';
boolean newTrackKeyPressed;

char drawCheckpointsKey = 'c';

char saveTrackKey = 'S';

char loadTrackKey = 'l';

char printDebugInfoKey = 'p';


  float steerInput = 0;
  float accelInput = 0;
  float breakInput = 0;


void keyPressed(KeyEvent e) {
  
  if( e.isAutoRepeat() ) return;
  
  char k = e.getKey(); //<>//
    
  if( k == turnLeftKey ) turnLeftPressed = true;
  if( k == turnRightKey ) turnRightPressed = true;
  if( k == accelerateKey ) accelKeyPressed = true;
  if( k == breakKey ) breakKeyPressed = true;
  
  if( k == resetKey ) resetKeyPressed = true;
  
  if( k == drawCheckpointsKey ) setCheckpoints = !setCheckpoints;
  if( k == newTrackKey ) newTrackKeyPressed = !newTrackKeyPressed;
  
  if( k == saveTrackKey ) saveTrackAs();
  
  //if( k == loadTrackKey ) track.loadTrack = "newTrack.track";
  if( k == loadTrackKey ) loadNextTrack();
  
  if( k == printDebugInfoKey ) printDebugInfo();
}


void keyReleased(KeyEvent e) {
  
  if( e.isAutoRepeat() ) return;
  
  char k = e.getKey();
  
  if( k == turnLeftKey ) turnLeftPressed = false;
  if( k == turnRightKey ) turnRightPressed = false;
  if( k == accelerateKey ) accelKeyPressed = false;
  if( k == breakKey ) breakKeyPressed = false;
  
  if( k == resetKey ) resetKeyPressed = false;
}


public void calculateInput( Car car ) {
  
  if( turnRightPressed && !turnLeftPressed ) steerInput = 1;
  else if( turnLeftPressed && !turnRightPressed ) steerInput = -1;
  else steerInput = 0;
  
  if( accelKeyPressed ) accelInput = 1;
  else accelInput = 0;
  
  if( breakKeyPressed ) breakInput = 1;
  else breakInput = 0;
  
  car.TakeInput(accelInput,breakInput,steerInput);
}


public class Key {     ///////// This is only half done and not yet ready to use
  
  char myChar;
  int  myCode;
  
  public Key( char keyCharacter ) {
    myChar = keyCharacter;
  }
  
  public Key( int keyCode ) {
    myCode = keyCode;
  }
  
  public boolean checkEvent( KeyEvent keyEvent ) {
    
    if( keyEvent.getKey() == myChar ) return true;
    //if( keyEvent
    return false;
  }
}
