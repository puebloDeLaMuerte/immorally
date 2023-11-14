public class CheckpointManager {

  ArrayList<Checkpoint> checkpoints = new ArrayList();
  ArrayList<Checkpoint> specialCheckpoints = new ArrayList();

  ArrayList<Long> allLapTimes = new ArrayList();
  long medianTime = 0;
  long lastMedianTime = 0;
  long bestLapTime = 999999999999999999l;
  long currentDeltaToBest;
  long currentDeltaToMedian;
  int penalty;
  int lapCount = 0;
  int validLapCount = 0;





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



  public void evaluateCheckpoints() {

    if ( checkpoints.size() == 0 ) return;

    for ( int i = 0; i < checkpoints.size(); i++ ) {
      if ( i == 0 ) {
        //checkpoints.get(0).checkForContact(x,y,s);
        if ( checkpoints.get(0).secondChecked && checkpoints.get(0).left ) {//&& checkpoints.get(checkpoints.size()-1).checked ) {
          newLap();
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
   if( checkpoints.get(0).secondChecked && checkpoints.get(0).left ) {//&& checkpoints.get(checkpoints.size()-1).checked ) { //<>//
   newLap(); //<>//
   }
   }
   else if( checkpoints.get(i-1).checked && !checkpoints.get(i).checked) {
   checkpoints.get(i).checkForContact(x,y,s); //<>//
   } //<>//
   }
   }
   */

  public void newLap() {
    println("newLap");

    boolean allchecked = true;
    for ( Checkpoint cp : checkpoints ) {
      if ( !cp.checked ) allchecked = false;
    }

    long thisLapTime = checkpoints.get(0).secondCheckTime - checkpoints.get(0).checkTime;
    lapCount++;
    currentDeltaToBest = thisLapTime - bestLapTime;

    /*
    for( Checkpoint cp : checkpoints ) {
     cp.newLap();
     }
     */

    // IS IT A VALID LAP?
    if ( !allchecked ) {
      playBoo();
      for ( Checkpoint cp : checkpoints ) {
        cp.newLap();
      }
      return; //<>//
    } //<>//
    validLapCount++;

    lastMedianTime = medianTime;
    allLapTimes.add(new Long(thisLapTime));
    long ats = 0;
    for (Long t : allLapTimes) {
      ats += t.l;
    }
    medianTime = ats / (long)validLapCount;
    currentDeltaToMedian = medianTime - lastMedianTime;

    boolean isAbsolute = false;
    if ( thisLapTime < bestLapTime ) {
      bestLapTime = thisLapTime;
      playYeah();
      isAbsolute = true;
    }

    deltaPanel.showPanel( getCurrentDeltaToBest(), getCurrentDeltaToMedian(), currentDeltaToBest >= 0d, isAbsolute, false );

    for ( Checkpoint cp : checkpoints ) {
      cp.newLap();
    }
    for( Checkpoint scp : specialCheckpoints ) {
      scp.newLap();
    }
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
    playLap();
  }


  protected void drawCheckpoint() {
    //text(checkPointNumber,tile.center.x,tile.center.y);
    if ( !checked) {
      strokeWeight(3);
      if ( checkPointNumber != 1 ) {
        stroke(palette.mainColorPrimary);
      } else {
        stroke(palette.darkGlow);
      }
    } else {
      strokeWeight(1);
      if ( checkPointNumber != 1 ) {
        stroke(palette.mainColorSecondary);
      } else {
        stroke(palette.darkGlow);
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





public class PowerDownCheckpoint extends Checkpoint { //<>//
  
  
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
    car.triggerStatus( new CarStatus( millis(), 1000, StatusType.POWER_DOWN) );
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
