public class CheckpointManager {

  ArrayList<Checkpoint> checkpoints = new ArrayList();
  ArrayList<Checkpoint> specialCheckpoints = new ArrayList();
  ArrayList<Checkpoint> allCheckpoints = null;

  long maxLapTime = 999999999999999999l;

  ArrayList<Lap> allLaps = new ArrayList();
  
  long bestLapTime = maxLapTime;
  int currentBestLapTotalNr = -1;
  
  long medianTime = 0;
  long lastMedianTime = 0;
  
  long currentDeltaToBest;
  long currentDeltaToMedian;
  
  int penalty;
  int lapCount = 0;
  int validLapCount = 0;

  Highscores highscores = new Highscores();

  public void reset() {
    checkpoints = new ArrayList();
    specialCheckpoints = new ArrayList();
    bestLapTime = 999999999999999999l;
  }
  
  
  public ArrayList<Checkpoint> getAllCheckpoints() {
    if( allCheckpoints == null ) {
      allCheckpoints = new ArrayList<Checkpoint>();
      allCheckpoints.addAll(checkpoints);
      allCheckpoints.addAll(specialCheckpoints);
    }
    return allCheckpoints;
  }


  public int getLowestAvailableCheckpointNr() {
    
    if( checkpoints == null || checkpoints.size() == 0 ) return 1;
    
    int prevInt = 0; //<>//
    int newInt = 0;
    
    while( newInt == prevInt ) {
      prevInt = newInt; //<>//
      newInt ++;
      for( Checkpoint cp : checkpoints ) {
        if( cp.getCheckpointData() == newInt ) {
          prevInt = newInt;
          break;
        }
      }
    }
    return newInt;
  }
  
  
  public double getCurrentBestLapTimeAsDouble() {
    
    for(int i = allLaps.size()-1; i > 0; i--) {
      Lap l = allLaps.get(i);
      if( l.getTotalLapNr() == currentBestLapTotalNr ) {
        return l.getLapTimeAsDouble();
      }
    }
    return maxLapTime;
  }
  
  public int getCurrentBestLapTimeAsInt() {
    return (int)getCurrentBestLapTimeAsDouble();
  }
  
  

  public String getMedianTime() {

    long totalSeconds = medianTime / 1000;
    long milli = medianTime % 1000;
    //long hours = totalSeconds / 3600;
    long minutes = (totalSeconds % 3600) / 60;
    long seconds = totalSeconds % 60;
    return String.format("%02d : %02d : %03d", minutes, seconds, milli);
  }


  public String getBestTime() {

    long totalSeconds = (long)bestLapTime / 1000l;
    long milli = (long)bestLapTime % 1000l;
    long minutes = (long)(totalSeconds % 3600l) / 60l;
    long seconds = (long)totalSeconds % 60l;
    return String.format("%02d : %02d : %03d", minutes, seconds, milli);
  }
  
  public String getTimeElapsed() {
    
    if( checkpoints == null || checkpoints.size() == 0 ) return "--:--:--";
    
    Checkpoint c = checkpoints.get(0);
    long t = (long)(millis()-c.checkTime);
    long totalSeconds = t / 1000l;
    long milli = (long)t % 1000l;
    long minutes = (long)(totalSeconds % 3600l) / 60l;
    long seconds = (long)totalSeconds % 60l;
    return String.format("%02d : %02d : %03d", minutes, seconds, milli);
  }


  public String getCurrentDeltaToBest() {

    long totalSeconds = (long)currentDeltaToBest / 1000l;
    long milli = (long)currentDeltaToBest % 1000l;
    //long minutes = (long)(totalSeconds % 3600l) / 60l;
    long seconds = (long)totalSeconds % 60l;
    if ( milli < 0 ) milli *= -1l;
    if ( seconds < 0 ) seconds *= -1l;
    return String.format("%03d : %03d", seconds, milli);
  }


  public String getCurrentDeltaToMedian() {

    long totalSeconds = (long)currentDeltaToMedian / 1000l;
    long milli = (long)currentDeltaToMedian % 1000l;
    //long minutes = (long)(totalSeconds % 3600l) / 60l;
    long seconds = (long)totalSeconds % 60l;
    if ( milli < 0 ) milli *= -1l;
    if ( seconds < 0 ) seconds *= -1l;
    return String.format("%03d : %03d", seconds, milli);
  }

  public boolean isLapReadyForFinish() {
    
    for( int i = 1; i < checkpoints.size(); i++) {
      if( !checkpoints.get(i).checked ) {
        return false;
      }
    }
    return true;
  }


  public void evaluateCheckpoints() {

    if ( checkpoints.size() == 0 ) return;

    for ( int i = 0; i < checkpoints.size(); i++ ) {
      if ( i == 0 ) {
        //checkpoints.get(0).checkForContact(x,y,s);
        if ( checkpoints.get(0).secondChecked && checkpoints.get(0).left ) {//&& checkpoints.get(checkpoints.size()-1).checked ) {
          newLap(false);
        }
      }/*
      else if( !checkpoints.get(i).checked) {
       checkpoints.get(i).checkForContact(x,y,s);
       }*/
    }
  }

  /*
  public void evaluateCarPos_Hotlap( float x, float y, float carSize) {
   if( checkpoints.size() == 0 ) return;
   
   float s = carSize * 0.9;
   
   for( int i = 0; i < checkpoints.size(); i++ ) {
   if( i == 0 ) {
   checkpoints.get(0).checkForContact(x,y,s);
   if( checkpoints.get(0).secondChecked && checkpoints.get(0).left ) {//&& checkpoints.get(checkpoints.size()-1).checked ) {
   newLap(); //<>//
   }
   }
   else if( checkpoints.get(i-1).checked && !checkpoints.get(i).checked) {
   checkpoints.get(i).checkForContact(x,y,s);
   } //<>//
   }
   }
   */

  public void newLap( boolean invalidateLap ) {
    //println("newLap");

    boolean allchecked = true;
    for ( Checkpoint cp : checkpoints ) {
      if ( !cp.checked ) allchecked = false;
    }
    if( invalidateLap ) allchecked = false;
    
    long thisLapTime = checkpoints.get(0).secondCheckTime - checkpoints.get(0).checkTime;
    lapCount++;
    
    Lap thisLap = new Lap(new Long(thisLapTime), lapCount, allchecked); 
    allLaps.add( thisLap );
    

    // IS IT A VALID LAP?
    if ( !allchecked ) {
      
      thisLap.setIsValid(false);
      thisLap.finalize();
      playBoo();
      
      for ( Checkpoint cp : checkpoints ) {
        cp.newLap();
      }
      return;
    }
    validLapCount++;

    thisLap.setIsValid(true);
    thisLap.setValidLapNr(validLapCount);

    lastMedianTime = medianTime;
    
    currentDeltaToBest = thisLapTime - bestLapTime;
    
    // calculate current median time
    
    long ats = 0;
    for (Lap lap : allLaps) {
      if( lap.isValid() ) {
        ats += lap.getLapTimeAsDouble();  
      }
    }
    medianTime = ats / (long)validLapCount;
    currentDeltaToMedian = medianTime - lastMedianTime;
    thisLap.medianTime = new Long( medianTime );
    
    // calculate isPersonalBest

    boolean isPersonalBest = false;
    if ( thisLap.getLapTimeAsDouble() < getCurrentBestLapTimeAsDouble() ) {
      bestLapTime = thisLapTime;
      currentBestLapTotalNr = thisLap.getTotalLapNr();
      
      thread("sendHighscore");
      
      playYeah();
      isPersonalBest = true;
    }
    thisLap.setIsPersonalBestThisSession(isPersonalBest);

    thisLap.finalize();

    if( validLapCount > 1 ) {
      deltaPanel.showPanel( getCurrentDeltaToBest(), getCurrentDeltaToMedian(), currentDeltaToBest >= 0d, isPersonalBest, false );  
    }
    
    for ( Checkpoint cp : checkpoints ) {
      cp.newLap();
    }
    for( Checkpoint scp : specialCheckpoints ) {
      scp.newLap();
    }
    playLap();
  }


  public void drawCheckpoints() {

    for ( Checkpoint cp : checkpoints ) {
      cp.drawCheckpoint();
    }
    for( Checkpoint scp : specialCheckpoints ) {
      scp.drawCheckpoint();
    }
  }


  public void sortCheckpoints() {
    Collections.sort(checkpoints, new Comparator<Checkpoint>() {
      @Override
        public int compare(Checkpoint o1, Checkpoint o2) {
        return Integer.compare(o1.checkPointNumber, o2.checkPointNumber);
      }
    }
    );
  }
}





public class Lap {
  
  private boolean isFinalized = false;
  
  private boolean isValid = false;
  private boolean isPersonalBestThisSession = false;
  private Long lapTime;
  private Long medianTime;
  private Long bestTime;
  private int totalLapNr;
  private int validLapNr;
  
  public Lap(Long lapTime, int totalLapNr, boolean isValid) {
    this.isValid = isValid;
    this.lapTime = lapTime;
    this.totalLapNr = totalLapNr;
  }
  
  public void finalize() {
    isFinalized = true;
  }
  
  public void setValidLapNr(int vlnr) {
    if( !isFinalized ) {
      this.validLapNr = vlnr;
    }
  }
  
  public int getValidLapNr() {
    return validLapNr;
  }
  
  public int getTotalLapNr() {
    return totalLapNr;
  }
  
  
  public Long getLapTime() {
    return lapTime;
  }
  
  public double getLapTimeAsDouble() {
    return lapTime.l;
  }
  
  public void setIsValid(boolean valid) {
    if( !isFinalized ) {
      isValid = valid;
    }
  }
  
  public boolean isValid() {
    return isValid;    
  }
  
  public void setMedianTime(Long mt) {
    if( !isFinalized ) {
      medianTime = mt;
    }
  }
  
  public Long getMedianTime() {
    return medianTime;
  }
  
  public void setBestTime(Long bt) {
    if( !isFinalized ) {
      bestTime = bt;
    }
  }
  
  public Long getBestTime() {
    return bestTime;
  }
  
  public void setIsPersonalBestThisSession(boolean b) {
    if( !isFinalized ) {
      isPersonalBestThisSession = b;
    }
  }
  
  public boolean getIsPersonalBestThisSession() {
    return isPersonalBestThisSession;
  }
}








public class Long {
  double l;
  public Long(long l) {
    this.l = l;
  }

  public void add(double a) {
    l += a;
  }
}







public class Checkpoint {

  Tile tile;

  Car car = null;
  
  int     cooldownMillis = 500;
  int     lastContactMillis;
  boolean checked;
  boolean secondChecked;
  boolean left;
  //boolean secondLeft;

  long checkTime = -1;
  long secondCheckTime = -1;

  int checkPointNumber = -1;

  public Checkpoint(Tile t, int number) {
    tile = t;
    checkPointNumber = number;
    println("New Checkpoint: " + number);
  }

  protected int getCheckpointData() {
    return checkPointNumber;
  }
  

  public int getTypeNr() {
    return 1; //<>//
  }

  public void contact( Car car ) {
    
    lastContactMillis = millis();
    
    if ( !checked ) {
      this.car = car;
      checked = true;
      left = false;
      checkTime = millis();
      doEffect(car);
    } else {
      if ( left ) {
        secondChecked = true;
        secondCheckTime = millis();
        //left = false;
      }
    }
  }
  
  protected void doEffect( Car car ) {
    playDing();
  }

  public void checkForLeft( PShape shape) {

    if( millis() - lastContactMillis < cooldownMillis ) return;
    
    if ( !PGS_ShapePredicates.containsPoint(shape, car.pos) ) {
      car = null;
      left = true;
    }
  }

  public void newLap() {

    checked = false;
    secondChecked = false;
    left = false;
    checkTime = -1;
    secondCheckTime = -1;
  }


  protected void drawCheckpoint() {
    //text(checkPointNumber,tile.center.x,tile.center.y);
    
    if( checkPointNumber == 1 ) { // is it the 'startFinish' checkpoint?
      stroke( palette.darkGlow );
      if( cpm.isLapReadyForFinish() ) {
        strokeWeight(3);
      }
      else {
        strokeWeight(1);
      }
    }
    else { // it's a normal checkpoint
      
      if ( !checked ) {
        strokeWeight(3);
        stroke(palette.mainColorPrimary);
      } else {
        strokeWeight(1);
        stroke(palette.mainColorSecondary);
      }
    }
     //<>//
    shape(tile.shape);
  }
}




public class SpecialCheckpointManager {
  
  ArrayList<Checkpoint> checkpoints = new ArrayList();
  
  public void drawCheckpoints() {

    for ( Checkpoint cp : checkpoints ) {
      cp.drawCheckpoint();
    }
  }
}





public class PowerDownCheckpoint extends Checkpoint {
  
  
  public PowerDownCheckpoint(Tile t) {
    
    super(t, 0);
    
    println("New PowerDownCheckpoint");
  }
  
  @Override
  public int getTypeNr() {
    return 2; //<>//
  }
  
  @Override
  protected void doEffect( Car car ) {
    playDisconnect();
    car.triggerStatus( new CarStatus( millis(), 600, StatusType.POWER_DOWN) );
    
    for(int i = 0; i < 10; i++) {
      sparks.releaseSpark(car.pos, new PVector((car.lastMove.x*0.2) + random(-1.2,1.2), (car.lastMove.y*0.2) + random(-1.2,1.2)), palette.geilOrange );
    }
  }
  
  @Override
  protected void drawCheckpoint() {
    stroke( palette.powerDownHighlight );
    if( car != null ) {
      strokeWeight(3);
    } else strokeWeight(1);
    shape(tile.shape);
  } 
}


public class DestructionCheckpoint extends Checkpoint {
  
  public DestructionCheckpoint(Tile t) {
    super(t,0);
    println("New DestructionCheckpoint");
  }
  
  @Override
  public int getTypeNr() {
    return 3;
  }
  
  
  @Override
  protected void doEffect( Car car ) {
    
    playDestruct();
    car.triggerStatus( new CarStatus( millis(), 1600, StatusType.DESTRUCTION) );
    car.explosion = new Explosion(car.getCarComponents(), car.lastMove);
    
    for(int i = 0; i < 10; i++) {
      sparks.releaseSpark(car.pos, new PVector(car.lastMove.x + random(-1,1), car.lastMove.y + random(-1,1)));
    }
    for(int i = 0; i < 20; i++) {
      sparks.releaseSpark(car.pos, new PVector(car.lastMove.x + random(-1,1), car.lastMove.y + random(-1,1)), palette.destruction);
    }
  }
  
  @Override
  protected void drawCheckpoint() {
    stroke( palette.destruction );
    if( car != null ) {
      strokeWeight(3);
    } else strokeWeight(1);
    shape(tile.shape);
  } 
}
