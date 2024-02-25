import http.requests.*; //<>//
import javax.swing.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

Palette palette = new Palette();
Track track;
Car car;
Sparks sparks;

User user;

String apiKey = "Schnablerm1Schnabler";

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

boolean drawTyreInfo = false;
boolean drawFrameRate = false;

boolean paused = false;

enum State {
  RACE, USER_LOGIN, INTRO, LOADING
};
State gameState = State.INTRO;

void settings() {
  //size(1800,1169);
  //fullScreen();
  fullScreen(P2D);
  //fullScreen(JAVA2D);
  //fullScreen(P3D);
  //pixelDensity(2);
  smooth();
}


void setup() {
  //println("swc: " + red(sketchWindowColor()) + " " + green(sketchWindowColor()) + " " + blue(sketchWindowColor()) );

  frameRate(120);
  noCursor();
  background(0);

  dplott = new DPlott();

  trackFiles = new ArrayList<String>();
  File folder = new File(dataPath("tracks"));

  if ( folder.exists() ) {


    File[] listOfFiles = folder.listFiles();

    if ( listOfFiles != null ) {
      for ( File f : listOfFiles ) {

        if ( f != null ) {
          if ( f.getName().endsWith(".track") ) {
            println("+t+ "+f.getName());
            trackFiles.add(f.getAbsolutePath());
          }
        } else {
          background(color(0, 255, 0));
          println("f is null");
        }
      }
    } else {
      background(color(255, 0, 0));
      println("listOfFiles is null");
    }
  } else {
    background(color(0, 0, 255));
    println("tracks-folder doesnt exist");
  }


  font = createFont("RacelineDemo", deltaPanel.size);
  
  initAudioPriority();
  thread("initAudio");

  initSkidLayer();
  noiseMap = createGraphics(width/noiseMapSizeFactor, height/noiseMapSizeFactor);
  trackLayer = createGraphics(width, height);
  noiseDetail(5, 0.6);

  track = new Track(null);
  car = new Car(width/2, height/2, 0);
  sparks = new Sparks();
}


void initSkidLayer() {
  skidLayer = createGraphics(width, height);
}


void draw() {

  //println("frame");
  updateDelta();

  if( !paused ) background(0);

  switch(gameState) {
  case LOADING:
    loadingLoop();
    break;
  case RACE:
    if( !paused ) {
      raceLoop();  
    }
    break;
  case USER_LOGIN:
    introLoop();
    userLoginLoop();
    break;
  case INTRO:
    introLoop();
    break;
  }


  if ( newTrackKeyPressed || track.splitException ) {

    newTrackKeyPressed = false;
    track = new Track(null);
    skidLayer = createGraphics(width, height);
    cpm.reset();

    //playYeah();
    playLove();
  }


  if ( setCheckpoints ) {
    for ( Tile t : track.tiles ) {
      t.mouseOver(mouseX, mouseY);
      t.drawMouseOver();
    }
  }
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
  if ( setCheckpoints ) {
    for ( Tile t : track.tiles ) {
      if ( t.isMouseOver ) {

        if ( t.checkpoint == null ) {
          Checkpoint c = new Checkpoint(t, cpm.getLowestAvailableCheckpointNr());
          t.checkpoint = c;
          cpm.checkpoints.add(c);
        } else if ( t.checkpoint.getClass() == Checkpoint.class ) {  // it has a normal checkpoint
          cpm.checkpoints.remove(t.checkpoint);
          PowerDownCheckpoint pdcp = new PowerDownCheckpoint(t);
          cpm.specialCheckpoints.add( pdcp );
          t.checkpoint = pdcp;
        } else if ( t.checkpoint.getClass() == PowerDownCheckpoint.class ) { // it has a powerDownCheckpoint
          cpm.specialCheckpoints.remove( t.checkpoint );
          DestructionCheckpoint dcp = new DestructionCheckpoint(t);
          cpm.specialCheckpoints.add( dcp );
          t.checkpoint = dcp;
        } else {
          cpm.specialCheckpoints.remove(t.checkpoint);
          cpm.checkpoints.remove(t.checkpoint);
          t.checkpoint = null;
        }
      }
      cpm.sortCheckpoints();
    }
  }
}


public void loadNextTrack(int delta) {

  initSkidLayer();
  cpm = new CheckpointManager();
  trackIndex += delta;
  if ( trackIndex >= trackFiles.size() ) trackIndex = 0;
  if ( trackIndex < 0 ) trackIndex = trackFiles.size()-1;
  loadTrack(trackIndex);
  resetCar(); 
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
