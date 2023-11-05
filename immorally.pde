Palette palette = new Palette();
Track track;
Car car;
Sparks sparks;

PGraphics skidLayer;
PGraphics trackLayer;

PGraphics noiseMap;
float noiseMapSeed = 1;


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
}


void setup() {
  frameRate(120);
  noCursor();

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

  skidLayer = createGraphics(width, height);
  noiseMap = createGraphics(width/noiseMapSizeFactor, height/noiseMapSizeFactor);
  trackLayer = createGraphics(width,height);
  noiseDetail(5,0.6);

  track = new Track(null);
  car = new Car(width/2, height/2, 0);
  sparks = new Sparks();
}



void draw() {
  
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
    cpm.checkpoints = new ArrayList();
    cpm.bestLapTime = 999999999999999999l;
    //playYeah();
  }
  

  if( setCheckpoints ) {
    for( Tile t : track.tiles ) {
      t.mouseOver(mouseX,mouseY);
      t.drawMouseOver();
    }
  } //<>//
}


void saveTrackAs() {
  track.saveTrack("newTrack");
}







void mousePressed() {
  if( setCheckpoints ) {
    for( Tile t : track.tiles ) {
      if( t.isMouseOver && t.checkpoint == null ) {
        Checkpoint c = new Checkpoint(t, cpm.checkpoints.size()+1);
        t.checkpoint = c;
        cpm.checkpoints.add(c);
      }
    }
  }
}


public void loadNextTrack() {
  
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
