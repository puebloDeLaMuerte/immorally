import processing.sound.*;

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

void initAudio() {
  
  String audioFolder = "audio/";
  
  //reverb = new Reverb(this);
  //delay = new Delay(this);
  
  lowPass = new LowPass(this);
  lowPass.freq(200);
  
  highPass = new HighPass(this);
  highPass.freq(200);
  
  staticElectric = new SoundFile(this, audioFolder+"401751__zenithinfinitivestudios__electric-sound.wav");
  boom = new SoundFile(this, audioFolder+"412172__inspectorj__cinematic-hit-distorted-a_attribute.wav");
  ding = new SoundFile(this, audioFolder+"406243__stubb__typewriter-ding-near-mono.wav");
  lap  = new SoundFile(this, audioFolder+"557923__conblast__plato-y-cuchara_attribute.mp3");
  engine = new SoundFile(this, audioFolder+"242740__marlonhj__engine.wav");
  highPass.process(engine);
  electric = new SoundFile(this, audioFolder+"155834__felix-blume__electrical-vibration-of-an-electric-transformer-box.wav");
  yeah = new SoundFile(this, audioFolder+"496087__dastudiospr__male-yeah.wav");
  boo = new SoundFile(this, audioFolder+"boo.wav");
  disconnect = new SoundFile(this, audioFolder+"Disconnect.wav");
  love = new SoundFile(this, audioFolder+"Pips_Auto 1 .mp3");
  
  lap.amp(0.1);
  ding.amp(1.4);
  
}

void playLove() {
  println("love");
  love.play();
}

void playStatic(boolean play) {
  if( play && ! staticElectric.isPlaying() ) {
    staticElectric.play(0.1);
  }
  else {
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
  float rate = random(0.9,1.4);
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
  
  if( !engine.isPlaying() ) {
    engine.amp(0.34);
    engine.loop();
  }
  
  speed *= 0.8;
  speed += 0.5;
  
  engine.rate(speed);
}  


void playElectric( float speed ) {
  
  if( !electric.isPlaying() ) {
    electric.amp(0.34);
    electric.loop();
  }
  //println("carspeed: " + speed);
  
  speed *= 0.8;
  speed += 0.9;
  
  electric.rate(speed);
  
}
