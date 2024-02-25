public class Sparks {
  
  ArrayList<Spark> sparks;
  ArrayList<Spark> childSparks;
  ArrayList<Spark> removeSparks;
  
  public Sparks() {
    sparks = new ArrayList();
    childSparks = new ArrayList();
    removeSparks = new ArrayList();
  }
  
  public void releaseSpark(PVector startPos, PVector carDir) {
    sparks.add( new Spark( startPos, carDir, false) );
  }
  
  public void drawSparks(PGraphics marksLayer, float alphaMultiplier) {
    for( Spark s : sparks ) s.drawSpark(marksLayer, alphaMultiplier);
    for( Spark s : childSparks ) s.drawSpark(marksLayer, alphaMultiplier);
  }
  
  public void updateSparks(float deltaTime) {
    for( Spark s : childSparks ) sparks.add(s);
    childSparks.clear();
    for( Spark s : sparks ) {
      s.updateSpark(deltaTime);
      if( !s.isActive ) {
        removeSparks.add(s);
      }
    }
    for( Spark r : removeSparks ) sparks.remove(r);
  }

  class Spark {
    PVector lastPos, pos, vec, startSpeed;
    float intensity, intensityDecline;
    public boolean isActive;
    float inertia;
    boolean isChild;
    
    public Spark( PVector startPos, PVector carDir, boolean isChild) {
      this.pos = startPos.copy();
      this.lastPos = startPos.copy();
      this.vec = carDir.copy();
      this.startSpeed = carDir.copy();
      this.isChild = isChild;
      inertia = random( 0.002, 0.004 );
      intensityDecline = random( 0.0004, 0.002);
      intensity = 1;
      isActive = true;
    }
    
    public void updateSpark(float deltaTime) {
      if( ! isActive ) return;
      lastPos = pos.copy();
      vec.setMag( vec.mag() - (inertia*deltaTime) );
      pos.add( vec );
      intensity -= intensityDecline * deltaTime;
      if(intensity < 0) isActive = false;
      
      if( !isChild ) {
        if( random(0,1) > 0.995f ) {
          releaseChildSpark();
          releaseChildSpark();
        }  
      }
    }
    
    public void drawSpark(PGraphics gr, float alphaMultiplier) {
      if( ! isActive ) return;
      gr.pushStyle();
      gr.strokeWeight(1);
      if( random(0,1) > 0.5 ) {
        gr.stroke( palette.mainColorPrimary, intensity * alphaMultiplier);  
      } else {
        gr.stroke( palette.mainColorSecondary, intensity * alphaMultiplier);
      }
      if( random(0,1) > 0.5 ) {
        gr.strokeWeight( 5 );  
      } else {
        gr.strokeWeight( 2 );
      }
      
      gr.line(lastPos.x,lastPos.y,pos.x,pos.y);
      gr.popStyle();
    }
    
    private void releaseChildSpark() {
      float r = random(TWO_PI);
        PVector dir = PVector.fromAngle(r);
        dir.setMag(startSpeed.mag()* 0.25);
        childSparks.add( new Spark(pos, dir, true) );
    }
  }
}
