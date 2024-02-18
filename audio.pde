import processing.sound.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


HighPass highPass;
LowPass lowPass;
Reverb reverb;
Delay delay;

SoundFile ding;
SoundFile lap;
SoundFile engine;
SoundFile electric;
SoundFile yeah;
SoundFile boo;
SoundFile boom;
SoundFile staticElectric;
SoundFile disconnect;

SoundFile love;
SoundFile[] pipautotracks;
int lastPlayedTrack;

SoundFile[] thunder;

boolean isAudioInitialized = false;
String audioFolder = "audio/";

void initAudioPriority() {
  boom = new SoundFile(this, audioFolder+"412172__inspectorj__cinematic-hit-distorted-a_attribute.wav");
}

void initAudio() {

  //reverb = new Reverb(this);
  //delay = new Delay(this);

  lowPass = new LowPass(this);
  lowPass.freq(200);

  highPass = new HighPass(this);
  highPass.freq(200);

  staticElectric = new SoundFile(this, audioFolder+"401751__zenithinfinitivestudios__electric-sound.wav");
  ding = new SoundFile(this, audioFolder+"406243__stubb__typewriter-ding-near-mono.wav");
  lap  = new SoundFile(this, audioFolder+"557923__conblast__plato-y-cuchara_attribute.mp3");
  engine = new SoundFile(this, audioFolder+"242740__marlonhj__engine.wav");
  highPass.process(engine);
  electric = new SoundFile(this, audioFolder+"155834__felix-blume__electrical-vibration-of-an-electric-transformer-box.wav");
  yeah = new SoundFile(this, audioFolder+"496087__dastudiospr__male-yeah.wav");
  //boo = new SoundFile(this, audioFolder+"boo.wav");     
  boo = new SoundFile(this, audioFolder+"514159__edwardszakal__distorted-beep-incorrect.mp3");     
  boo.amp(0.9);
  disconnect = new SoundFile(this, audioFolder+"Disconnect.wav");
  love = new SoundFile(this, audioFolder+"Pips_Auto 1 .mp3");

  lap.amp(0.1);
  ding.amp(1.4);

  pipautotracks = LoadPipAuto(audioFolder);
  thunder = loadSoundFilesFromFolder( audioFolder+"thunder" );
  
  isAudioInitialized = true; //<>//
}



SoundFile[] LoadPipAuto(String folderPath) {
    
  folderPath = dataPath(folderPath);
  File folder = new File(folderPath);

  File[] listOfFiles = folder.listFiles();
  ArrayList<SoundFile> pipAutoFiles = new ArrayList<SoundFile>();

  // Regex to match the file pattern "Pip(s)_Auto n.mp3"
  String regex = "Pip(s)?_Auto \\d+\\.mp3";
  Pattern pattern = Pattern.compile(regex);

  if (listOfFiles != null) {
    for (File file : listOfFiles) {
      if (file.isFile()) {
        Matcher matcher = pattern.matcher(file.getName());
        if (matcher.find()) {
          // If a file matches the pattern, load it into the SoundFile array
          SoundFile soundFile = new SoundFile(this, file.getAbsolutePath());
          pipAutoFiles.add(soundFile);
        }
      }
    }
  }

  // Convert ArrayList to array
  SoundFile[] pipAutoArray = new SoundFile[pipAutoFiles.size()];
  pipAutoArray = pipAutoFiles.toArray(pipAutoArray);

  return pipAutoArray;
}


SoundFile[] loadSoundFilesFromFolder(String folderPath) {
  folderPath = dataPath(folderPath);
  ArrayList<SoundFile> soundFiles = new ArrayList<SoundFile>();
  loadSoundFilesRecursively(folderPath, soundFiles);
  return soundFiles.toArray(new SoundFile[0]); // Convert ArrayList to array
}


void loadSoundFilesRecursively(String folderPath, ArrayList<SoundFile> soundFiles) {
  
  File folder = new File(folderPath);
  File[] listOfFiles = folder.listFiles();
  if (listOfFiles != null) {
    for (File file : listOfFiles) {
      if (file.isFile()) {
        String fileName = file.getName().toLowerCase();
        if (fileName.endsWith(".mp3") || fileName.endsWith(".wav") || fileName.endsWith(".ogg")) {
          SoundFile soundFile = new SoundFile(this, file.getAbsolutePath());
          //if( soundFile. ) {
            soundFiles.add(soundFile);  
          //}
          //else println("couldn't load sound file: " + file.getAbsolutePath());
        }
      } else if (file.isDirectory()) {
        loadSoundFilesRecursively(file.getAbsolutePath(), soundFiles); // Recursively search in subdirectories
      }
    }
  }
}


void playSomeThunder() {
  
  int r = floor(random(thunder.length));
  if( !thunder[r].isPlaying() ) {
    thunder[r].amp(0.64);
    thunder[r].play();
  }
}


void playSomeLove() {
  
  for( SoundFile sf : pipautotracks ) {
    if( sf.isPlaying() ) return;
  }
  
  int r = lastPlayedTrack;
  while ( r == lastPlayedTrack ) {
    r = floor(random(pipautotracks.length));
  }

  pipautotracks[r].amp(0.7);
  pipautotracks[r].play();
  lastPlayedTrack = r;
}


void playLove() {
  println("love");
  love.play();
}

void playStatic(boolean play) {
  if ( play && ! staticElectric.isPlaying() ) {
    staticElectric.play(0.1);
  } else {
    staticElectric.stop();
  }
}

void playDestruct() {
  boom.play();
}

void playBoom() {
  boom.play();
}

void playYeah() {
  yeah.play();
}


void playLap() {

  lap.cue(0.4f);
  lap.play();
  //lowPass.process(lap);
}

void playDing() {
  float rate = random(0.9, 1.4);
  //println("rate: " + rate);
  ding.rate(rate);
  ding.play();
}


void playBoo() {
  boo.play();
}


void playDisconnect() {
  disconnect.amp(1);
  disconnect.play();
}


void playEngine( float speed ) {

  println("carspeed: " + speed);

  if ( !engine.isPlaying() ) {
    engine.amp(0.34);
    engine.loop();
  }

  speed *= 0.8;
  speed += 0.5;

  engine.rate(speed);
}


void playElectric( float speed ) {

  if ( !electric.isPlaying() ) {
    electric.amp(0.34);
    electric.loop();
  }
  //println("carspeed: " + speed);

  speed *= 0.8;
  speed += 0.9;

  electric.rate(speed);
}
