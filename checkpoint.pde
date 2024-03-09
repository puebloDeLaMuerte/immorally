long maxLapTime = 999999999999999999l;

public class CheckpointManager {

  ArrayList<Checkpoint> checkpoints = new ArrayList();
  ArrayList<Checkpoint> specialCheckpoints = new ArrayList();
  ArrayList<Checkpoint> allCheckpoints = null;

  ArrayList<Lap> allLaps = new ArrayList();

  long sessionBestLapTime = maxLapTime;
  int currentBestLapTotalNr = -1;

  boolean displaySessionBestTimeAsNew = false;
  boolean displaySessionBestRankAsNew = false;
  boolean displaySessionMedianTimeAsNew = false;
  boolean displaySessionMedianTimeAsAbsolute = false;

  long medianTime = 0;
  long lastMedianTime = 0;
  long sessionBestMedianTime = maxLapTime;

  long currentDeltaToBest;
  long currentDeltaToMedian;

  int penalty;
  int lapCount = 0;
  int validLapCount = 0;

  Highscores highscores = new Highscores();

  int[] tierLaps = {5, 10, 20, 40, 80, 160};
  int tierMultiple = 80;

  LapTracker lapTracker;
  LapTracker ghostCarLapTracker;
  
  public void reset() {
    checkpoints = new ArrayList();
    specialCheckpoints = new ArrayList();
    sessionBestLapTime = 999999999999999999l;
  }


  public ArrayList<Checkpoint> getAllCheckpoints() {
    if ( allCheckpoints == null ) {
      allCheckpoints = new ArrayList<Checkpoint>();
      allCheckpoints.addAll(checkpoints);
      allCheckpoints.addAll(specialCheckpoints);
    }
    return allCheckpoints;
  }


  public int getLowestAvailableCheckpointNr() {

    if ( checkpoints == null || checkpoints.size() == 0 ) return 1;

    int prevInt = 0;
    int newInt = 0;

    while ( newInt == prevInt ) {
      prevInt = newInt;
      newInt ++;
      for ( Checkpoint cp : checkpoints ) {
        if ( cp.getCheckpointData() == newInt ) {
          prevInt = newInt;
          break;
        }
      }
    }
    return newInt;
  }


  public double getCurrentBestLapTimeAsDouble() {

    for (int i = allLaps.size()-1; i > 0; i--) {
      Lap l = allLaps.get(i);
      if ( l.getTotalLapNr() == currentBestLapTotalNr ) {
        return l.getLapTimeAsDouble();
      }
    }
    return maxLapTime;
  }

  public int getCurrentBestLapTimeAsInt() {
    return (int)getCurrentBestLapTimeAsDouble();
  }



  public String getMedianTime() {

    return timeAsDisplayString(medianTime);
  }


  public String getBestTime() {

    if ( sessionBestLapTime == maxLapTime ) return timeAsDisplayString(-1);

    return timeAsDisplayString(sessionBestLapTime);
  }
  
  
  
  public int getTimeElapsedAsInt() {
    if ( checkpoints == null || checkpoints.size() == 0 ) return -1;
    Checkpoint c = checkpoints.get(0);
    return millis() - (int)c.checkTime - pausedMillis;
  }



  public String getTimeElapsedAsString() {

    if ( checkpoints == null || checkpoints.size() == 0 ) return timeAsDisplayString(-1);

    Checkpoint c = checkpoints.get(0);
    long t = (long)(millis()-c.checkTime);
    t -= pausedMillis;
    
    return timeAsDisplayString(t);
  }


  public String getCurrentDeltaToBest() {
    //return "debug";
    return timeAsDisplayString((long)currentDeltaToBest);
  }


  public String getCurrentDeltaToMedian() {

    return timeAsDisplayString(currentDeltaToMedian);
  }

  public boolean isLapReadyForFinish() {

    for ( int i = 1; i < checkpoints.size(); i++) {
      if ( !checkpoints.get(i).checked ) {
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
   newLap();
   }
   }
   else if( checkpoints.get(i-1).checked && !checkpoints.get(i).checked) {
   checkpoints.get(i).checkForContact(x,y,s);
   }
   }
   }
   */

  public void newLap( boolean invalidateLap ) {
    //println("newLap");

    boolean allchecked = true;
    for ( Checkpoint cp : checkpoints ) {
      if ( !cp.checked ) allchecked = false;
    }
    if ( invalidateLap ) allchecked = false;

    highscores.newLap();
    displaySessionBestTimeAsNew = false;
    displaySessionBestRankAsNew = false;
    displaySessionMedianTimeAsNew = false;
    displaySessionMedianTimeAsAbsolute = false;

    long thisLapTime = checkpoints.get(0).secondCheckTime - checkpoints.get(0).checkTime - pausedMillis;
    lapCount++;
    pausedMillis = 0;

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
      this.lapTracker = new LapTracker();
      return;
    }
    validLapCount++;

    thisLap.setIsValid(true);
    thisLap.setValidLapNr(validLapCount);    
    thisLap.setLapTracker(lapTracker);
    this.lapTracker = new LapTracker();
    
    lastMedianTime = medianTime;

    currentDeltaToBest = thisLapTime - sessionBestLapTime;

    // calculate current median time

    long ats = 0;
    for (Lap lap : allLaps) {
      if ( lap.isValid() ) {
        ats += lap.getLapTimeAsDouble();
      }
    }
    medianTime = ats / (long)validLapCount;
    currentDeltaToMedian = medianTime - lastMedianTime;
    thisLap.medianTime = new Long( medianTime );

    if ( medianTime < lastMedianTime ) {
      displaySessionMedianTimeAsNew = true;
    }
    if ( medianTime < sessionBestMedianTime ) {
      sessionBestMedianTime = medianTime;
      displaySessionMedianTimeAsAbsolute = true;
    }

    // calculate isPersonalBest

    boolean isSessionBest = false;
    boolean isPersonalBest = false;

    if ( isTierLap(validLapCount) ) {
      //println("TIIIIIIIIIIER LAP: " + validLapCount);
      TierScore ts = highscores.getLatestTierScore();
      if( ts == null || ts.tier != validLapCount) {
        highscores.tierScores.add(new TierScore(validLapCount,(int)medianTime));
        thread("submitTierHighscore");
      }
      else if( ts.tier == validLapCount ) {
        println("Something went wrong here, TierScore already present for validLapCount: " + validLapCount);
      }
    }

    if ( thisLap.getLapTimeAsDouble() < getCurrentBestLapTimeAsDouble() ) {
      sessionBestLapTime = thisLapTime;
      currentBestLapTotalNr = thisLap.getTotalLapNr();

      thread("sendHighscore");
      
      ghostCarLapTracker = thisLap.getLapTracker();
      
      playYeah();
      isSessionBest = true;
      displaySessionBestTimeAsNew = true;
    }
    thisLap.setIsPersonalBestThisSession(isSessionBest);

    if ( thisLapTime < highscores.previousBestLapTime || highscores.previousBestLapTime == -1) {
      highscores.setNewPreviousLapTime((int)thisLapTime);
      isPersonalBest = true;
    }

    thisLap.finalize();

    if ( validLapCount > 1 ) {
      deltaPanel.showPanel( getCurrentDeltaToBest(), getCurrentDeltaToMedian(), currentDeltaToBest >= 0d, isPersonalBest, false );
    }

    for ( Checkpoint cp : checkpoints ) {
      cp.newLap();
    }
    for ( Checkpoint scp : specialCheckpoints ) {
      scp.newLap();
    }
    playLap();
  }

  private boolean isTierLap(int lapNr) {
    boolean r = false;
    for ( int i : tierLaps ) {
      if ( i == lapNr ) return true;
    }
    return isInSequence(lapNr);
  }

  // sequencially calculate if this lap is a valid multiple of the tier-lap array...
  private boolean isInSequence(int num) {

    int start = tierMultiple;

    // Continue until num is less than start
    while (num >= start) {
        if (num == start) {
            return true; // num is in the sequence
        }
        start *= 2; // Move to the next number in the sequence
    }
    return false;
}


  public String timeAsDisplayString(long t) {
    

    if( t == -1l ) {
      return "-- : -- : ---";
    }
    if( t == maxLapTime ) {
      return "-- : -- : ---";
    }
    
    if( t < 0 ) t *= -1l;
    
    long totalSeconds = t / 1000l;
    long milli = t % 1000;
    //long hours = totalSeconds / 3600;
    long minutes = (totalSeconds % 3600) / 60;
    long seconds = totalSeconds % 60;
    return String.format("%02d : %02d : %03d", minutes, seconds, milli);
  }




  public void handleLapTracker() {
    
    if( lapTracker != null ) {
      if( frameCount % 20 == 0 ) {
        lapTracker.addRecord( getTimeElapsedAsInt(), new PVector(car.pos.x, car.pos.y), car.rotation);  
      }
        
    }
    
    if( drawGhostCar && ghostCarLapTracker != null ) {
      PositionRecord pr = ghostCarLapTracker.getRecord( getTimeElapsedAsInt() );
      if( pr != null ) {
        pushStyle();
        pushMatrix();
        noFill();
        stroke(palette.darkGlow);
        translate(pr.position.x, pr.position.y);
        rotate(pr.rotation);
        line(-25,-10,20,0);
        line(-25, 10,20,0);
        popMatrix();
        popStyle();
      }
    }
  }




  public void drawCheckpoints() {

    for ( Checkpoint cp : checkpoints ) {
      cp.drawCheckpoint();
    }
    for ( Checkpoint scp : specialCheckpoints ) {
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
  private LapTracker lapTracker;

  public Lap(Long lapTime, int totalLapNr, boolean isValid) {
    this.isValid = isValid;
    this.lapTime = lapTime;
    this.totalLapNr = totalLapNr;
  }

  public void finalize() {
    isFinalized = true;
  }

  public void setLapTracker(LapTracker lt) {
    this.lapTracker = lt;
  }

  public LapTracker getLapTracker() {
    return lapTracker;
  }

  public void setValidLapNr(int vlnr) {
    if ( !isFinalized ) {
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
    if ( !isFinalized ) {
      isValid = valid;
    }
  }

  public boolean isValid() {
    return isValid;
  }

  public void setMedianTime(Long mt) {
    if ( !isFinalized ) {
      medianTime = mt;
    }
  }

  public Long getMedianTime() {
    return medianTime;
  }

  public void setBestTime(Long bt) {
    if ( !isFinalized ) {
      bestTime = bt;
    }
  }

  public Long getBestTime() {
    return bestTime;
  }

  public void setIsPersonalBestThisSession(boolean b) {
    if ( !isFinalized ) {
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
    return 1;
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

    if ( millis() - lastContactMillis < cooldownMillis ) return;

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

    if ( checkPointNumber == 1 ) { // is it the 'startFinish' checkpoint?
      stroke( palette.darkGlow );
      if ( cpm.isLapReadyForFinish() ) {
        strokeWeight(3);
      } else {
        strokeWeight(1);
      }
    } else { // it's a normal checkpoint

      if ( !checked ) {
        strokeWeight(3);
        stroke(palette.mainColorPrimary);
      } else {
        strokeWeight(1);
        stroke(palette.mainColorSecondary);
      }
    }

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
    return 2;
  }

  @Override
    protected void doEffect( Car car ) {
    playDisconnect();
    car.triggerStatus( new CarStatus( millis(), 600, StatusType.POWER_DOWN) );

    for (int i = 0; i < 10; i++) {
      sparks.releaseSpark(car.pos, new PVector((car.lastMove.x*0.2) + random(-1.2, 1.2), (car.lastMove.y*0.2) + random(-1.2, 1.2)), palette.geilOrange );
    }
  }

  @Override
    protected void drawCheckpoint() {

    // drawing checkpoints double to get a "smoothing" effect takes too much off of the framerate
    /*
    stroke( red(palette.powerDownHighlight), green(palette.powerDownHighlight), blue(palette.powerDownHighlight), 40 );
     strokeWeight(6);
     //noFill();
     shape(tile.shape);
     */

    stroke( palette.powerDownHighlight );
    if ( car != null ) {
      strokeWeight(3);
    } else strokeWeight(1);
    shape(tile.shape);
  }
}


public class DestructionCheckpoint extends Checkpoint {

  public DestructionCheckpoint(Tile t) {
    super(t, 0);
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

    for (int i = 0; i < 10; i++) {
      sparks.releaseSpark(car.pos, new PVector(car.lastMove.x + random(-1, 1), car.lastMove.y + random(-1, 1)));
    }
    for (int i = 0; i < 20; i++) {
      sparks.releaseSpark(car.pos, new PVector(car.lastMove.x + random(-1, 1), car.lastMove.y + random(-1, 1)), palette.destruction);
    }
    for (int i = 0; i < 10; i++) {
      sparks.releaseSpark(car.pos, new PVector(random(-2, 2), random(-2, 2)));
    }
    for (int i = 0; i < 20; i++) {
      sparks.releaseSpark(car.pos, new PVector(random(-2, 2), random(-2, 2)), palette.destruction);
    }
  }

  @Override
    protected void drawCheckpoint() {
    stroke( palette.destruction );
    if ( car != null ) {
      strokeWeight(3);
    } else strokeWeight(1);
    shape(tile.shape);
  }
}
