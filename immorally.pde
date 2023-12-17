import javax.swing.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

Palette palette = new Palette();
Track track;
Car car;
Sparks sparks;

PGraphics skidLayer;
PGraphics trackLayer;

PGraphics noiseMap;
float noiseMapSeed = 1;

DPlott dplott;

PFont font;

float lastFrameMillis;
float deltaTime;
float deltaFactor = 0.1;//0.1;
float delta;

DeltaPanel deltaPanel = new DeltaPanel(0);

CheckpointManager cpm = new CheckpointManager();

boolean setCheckpoints = false;

int noiseMapSizeFactor = 20;

ArrayList<String> trackFiles;
int trackIndex = 0;

enum State { RACE, TRACK_SELECT, INTRO };
State gameState = State.INTRO;

void settings() {
  fullScreen(P2D);
  //pixelDensity(2);
  smooth();
}


void setup() {
  frameRate(120);
  noCursor();
  

  dplott = new DPlott();

  trackFiles = new ArrayList<String>();
  File folder = new File(sketchPath()+"/data/tracks");
  File[] listOfFiles = folder.listFiles();
  for( File f : listOfFiles ) {
    if( f.getName().endsWith(".track") ) {
      println("+t+ "+f.getName());
      trackFiles.add(f.getAbsolutePath());
    }
  }

  font = createFont("RacelineDemo", deltaPanel.size);
  initAudio();

  initSkidLayer();
  noiseMap = createGraphics(width/noiseMapSizeFactor, height/noiseMapSizeFactor);
  trackLayer = createGraphics(width,height);
  noiseDetail(5,0.6);

  track = new Track(null);
  car = new Car(width/2, height/2, 0);
  sparks = new Sparks();
}


void initSkidLayer() {
  skidLayer = createGraphics(width, height);
}


void draw() {
  
  //println("frame");
  
  background(0);

  switch(gameState) {
    case RACE:
      raceLoop();
      break;
    case TRACK_SELECT:
      trackSelectLoop();
      break;
    case INTRO:
      introLoop();
      break;
  }
  

  if( newTrackKeyPressed || track.splitException ) {
  
    newTrackKeyPressed = false;
    track = new Track(null);
    skidLayer = createGraphics(width,height);
    cpm.reset();
    
    //playYeah();
    playLove();
  }
  

  if( setCheckpoints ) {
    for( Tile t : track.tiles ) {
      t.mouseOver(mouseX,mouseY);
      t.drawMouseOver();
    }
  } //<>//
}


void saveTrackAs() {
  
  String userInput = JOptionPane.showInputDialog(this, "name the track");
    if (userInput != null) {
        println("User entered: " + userInput);
    } else {
        println("No input was given.");
    }
  
  track.saveTrack(userInput);
}




void mousePressed() {
  if( setCheckpoints ) {
    for( Tile t : track.tiles ) {
      if( t.isMouseOver ) {
        
        if( t.checkpoint == null ) {
          Checkpoint c = new Checkpoint(t, cpm.getLowestAvailableCheckpointNr());
          t.checkpoint = c;
          cpm.checkpoints.add(c);
        }
        else if( t.checkpoint.getClass() == Checkpoint.class ) {
          cpm.checkpoints.remove(t.checkpoint);
          PowerDownCheckpoint pdcp = new PowerDownCheckpoint(t);
          cpm.specialCheckpoints.add( pdcp );
          t.checkpoint = pdcp;
        }
        else {
          cpm.specialCheckpoints.remove(t.checkpoint);
          cpm.checkpoints.remove(t.checkpoint);
          t.checkpoint = null;
        }
      }
      cpm.sortCheckpoints();
    }
  }
}


public void loadNextTrack() {
  
  initSkidLayer();
  cpm = new CheckpointManager();
  trackIndex++;
  if( trackIndex >= trackFiles.size() ) trackIndex = 0;
  loadTrack(trackIndex);
}


public void loadTrack(int i) {
  
  println("load Track Nr " + i);
  track = new Track( trackFiles.get(i) );
}


public void loadTrack(String ts) {
  println("load track: " + ts);
  track = new Track(ts);
}


public void printDebugInfo() {
  println("*** debug info ***");
  println("track tiles: " + track.tiles.size());
}

/*
void mouseReleased() {

}
*/
