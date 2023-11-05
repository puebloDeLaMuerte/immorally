public class Car {

  //private float carWidth, carHeight;
  private int carColor = color(200, 0, 0);

  private PVector pos = new PVector();
  
  private float rotation;
  private float currentDirection;
  //private float speed;

  public PVector tyreFLworldPos = new PVector(0,0);
  public PVector tyreFRworldPos = new PVector(0,0);
  public PVector tyreRLworldPos = new PVector(0,0);
  public PVector tyreRRworldPos = new PVector(0,0);

  private float maxSpeed = 8;

  private float steering;
  private float maxSteering = 0.03;
  private float steeringSensibility = 0.002f;

  private float acceleration;
  private float enginePower = 0.007f;
  private float maxAcceleration = 0.04;

  private float breaking;
  private float breakPower = 0.018;
  private float maxBreaking = 0.035;

  private float carFriction = 0.001;

  private float maxGripTotal = 0.08;
  private boolean maxGripExceeded;
  
  private float sparksSpeed = 3.5;
  
  float carlength = 20;
  float carheight = 5.8;

  float tyreOutnessR = 4.2f;
  float tirewidthR = 9.5f;
  float tireradiusR = 16;

  float tyreOutnessF = 4;
  float tirewidthF = 8f;
  float tireradiusF = 21;
   
  float tyreFrontOffset = -15;
  float tyreRearOffset = 4;
  
  PShape frontTyre = createShape();
  PShape rearTyre = createShape();
  
  /*
  private float maxLatGrip = 0.02;
  private float maxLongGrip = 0.033;
  private boolean longGripExceed;
  private boolean latGripExceed;
  */
  private PVector lastMove = new PVector();


  // DEBUG

  float lateralForce;
  float longitudinalForce;
  float skidAmount;

  PVector dgv;

  //! DEBUG



  public Car(float startX, float startY, float startRotation) {
    pos.x = startX;
    pos.y = startY;
    rotation = startRotation;
    
    frontTyre.beginShape();
    frontTyre.vertex(-tireradiusF/2,0);
    frontTyre.vertex(0,tirewidthF/2);
    frontTyre.vertex(tireradiusF/2,0);
    frontTyre.vertex(0,-tirewidthF/2);
    frontTyre.vertex(-tireradiusF/2,0);
    frontTyre.endShape();
    frontTyre.disableStyle();
    
    rearTyre.beginShape();
    rearTyre.vertex(-tireradiusR/2,0);
    rearTyre.vertex(0,tirewidthR/2);
    rearTyre.vertex(tireradiusR/2,0);
    rearTyre.vertex(0,-tirewidthR/2);
    rearTyre.vertex(-tireradiusR/2,0);
    rearTyre.endShape();
    rearTyre.disableStyle();
  }


  public float getSpeed() {
    
    //float delta = deltaTime * deltaFactor;
    
    return lastMove.mag()/delta;
  }


  public void TakeInput( float accelerationInput, float breakingInput, float steeringInput ) {

    //float delta = deltaTime * deltaFactor;

    //print("input: " + frameCount );

    steeringInput *= delta;
    //accelerationInput *= delta;
    //breakingInput *= delta;

    if ( steeringInput == 0f ) {
      steering -= ( 0.1 * steering );// 0.99 * delta;
    } else if ( abs(steering) < maxSteering ) {
      steering += (steeringInput * steeringSensibility);
    } else {
      if( steering < 0 ) steering = maxSteering*-1;
      else steering = maxSteering;
    }

    if ( accelerationInput == 0 ) {
      acceleration -= ( 0.1 * acceleration);
    } else acceleration += enginePower * delta;
    if ( acceleration > maxAcceleration ) acceleration = maxAcceleration;

    if ( breakingInput == 0 ) {
      breaking -= ( 0.1 * breaking ) ;
    } else if ( breaking < maxBreaking ) breaking += breakPower * delta;
    if ( breaking > maxBreaking ) breaking = maxBreaking;

  }



  public void updatePhysics() {

    //float delta = deltaTime * deltaFactor;

    /* if( lastMove.mag() > 0.4 ) */    rotation += steering;
    PVector thisRotation = PVector.fromAngle(rotation);

    //currentDirection = atan2(lastMove.x,lastMove.y);

    //PVector thisFriction = new PVector( -lastMove.x, -lastMove.y ).mult(carFriction).mult(delta).mult(0.0001+lastMove.mag());

    PVector thisAcceleration = new PVector(thisRotation.x, thisRotation.y);
    thisAcceleration.mult(acceleration * delta);

    PVector lastDir = new PVector(lastMove.x,lastMove.y).normalize();
    PVector thisBreaking = new PVector(-lastDir.x, -lastDir.y);
    thisBreaking.mult(breaking * delta);


    float lastMoveMag = lastMove.mag();
    PVector steeredDir = new PVector(thisRotation.x, thisRotation.y).setMag(lastMoveMag);
    PVector thisSteering = PVector.sub(steeredDir, lastMove);
    
    
    
    PVector demand = new PVector(0,0).add(thisAcceleration).add(thisBreaking).add(thisSteering);//.add(thisFriction);

    PVector force = PVector.sub( PVector.add( lastMove, demand ), lastMove ); // this seems to be bullshit - i think this equates to force = demand.
    float forceMag = force.mag();
    skidAmount = forceMag * delta;
    
    
    float slideFactor = (1*delta)-log( (forceMag*(8*delta))+(1*delta)) ;
    maxGripExceeded = true;
    
    
    //println(thisSteering.mag());
    //println( forceMag );
    
    //slideFactor = 1-((thisSteering.mag())*0.04);  // works but is not logically right
    slideFactor = thisSteering.mag() * (3.4 * delta);
    
    //slideFactor = 0.8+forceMag;
    
    
    slideFactor = constrain(slideFactor,0,0.99);
    //println(slideFactor);
    
    //skidAmount += (1-slideFactor) * 10;
    //slideFactor = 0.99f;
    demand.add( thisSteering.mult(-1).mult(slideFactor) );
    
    //println(thisBreaking.mag());
    
    //float breakSteerFactor =  1-(thisBreaking.mag()*0.01);
    //demand.add( thisSteering.mult(-1).mult(breakSteerFactor) );
    
    
    PVector newDir = PVector.add( lastMove, demand );
    //if ( newDir.mag() > maxSpeed ) newDir.setMag(maxSpeed);
    
    //println(delta);
    
    ///////// REMOVED FRICTION FOR DEBUGGING
    //PVector thisFriction = new PVector( -newDir.x, -newDir.y ).mult(carFriction/delta).mult((0.0015* delta)+newDir.mag())/*.mult(delta)*/;
    //newDir.add(thisFriction);
    ///////// REMOVED FRICTION FOR DEBUGGING
    
    lastMove = new PVector(newDir.x, newDir.y);
    //newDir = newDir.mult(delta);
    pos.add(newDir);
    
    
    // EMIT SPARKS MAYBE ??

    if( getSpeed() > sparksSpeed * deltaTime * deltaFactor) {
      
      if( random(0,1) > 0.98 ) {
        
        float d = random(TWO_PI);
        PVector sparkPos = PVector.fromAngle(d);
        sparkPos.setMag( random(0,carheight*2) );
        sparks.releaseSpark(PVector.add(pos,sparkPos),newDir);
      }
    }
  }





  public void drawCar(PGraphics skidLayer) {

    

    float xOffset = carlength/2;

    pushMatrix();

    translate(pos.x, pos.y);
    rotate(rotation);
    //rotate(-currentDirection - HALF_PI);

    strokeWeight(3);

    skidLayer.beginDraw();

    //println(skidAmount);
    boolean drawSkid;
    if( skidAmount > 10 ) {
      skidLayer.fill(0,0,0,skidAmount*0.5f);
      drawSkid = true;
    } else {
      drawSkid = false;
      skidLayer.noFill();
    }
    
    skidLayer.noStroke();
    skidLayer.translate(pos.x, pos.y);
    skidLayer.rotate(rotation);
    //skidLayer.rotate(currentDirection - HALF_PI);
    
    
    
    // left front tyre position
    float tyreXrl = carlength - xOffset + tyreRearOffset;
    float tyreYrl = -tyreOutnessR + -(carheight/2)-(tirewidthR/2);
    // right front tyre position
    float tyreXrr = carlength - xOffset + tyreRearOffset;
    float tyreYrr = tyreOutnessR + (carheight/2)+(tirewidthR/2);
    // left rear tyre position
    float tyreXfl = (carlength/2)/*-(tireradiusF)*/ - xOffset + tyreFrontOffset;
    float tyreYfl = -tyreOutnessF + -(carheight/2)-(tirewidthF/2);
    // right rear tyre position
    float tyreXfr = (carlength/2)/*-(tireradiusF)*/ - xOffset + tyreFrontOffset;
    float tyreYfr = tyreOutnessF + (carheight/2)+(tirewidthF/2);
    
    // draw suspension
    stroke(palette.mainColorPrimary);
    line( tyreXrl, tyreYrl, tyreXrr, tyreYrr );
    line( tyreXfl, tyreYfl, tyreXfr, tyreYfr );
    
    tyreFLworldPos = new PVector(screenX(tyreXfl, tyreYfl),screenY(tyreXfl, tyreYfl ));
    tyreFLworldPos = new PVector(screenX(tyreXfr, tyreYfr),screenY(tyreXfr, tyreYfr ));
    tyreFLworldPos = new PVector(screenX(tyreXrl, tyreYrl),screenY(tyreXrl, tyreYrl ));
    tyreFLworldPos = new PVector(screenX(tyreXrr, tyreYrr),screenY(tyreXrr, tyreYrr ));
    
    fill(palette.black);
    stroke(palette.mainColorPrimary);
    ellipseMode(CENTER);

    // draw front left tyre
    pushMatrix();
      translate(tyreXrl, tyreYrl);
      rotate(steering*15);
      shape(frontTyre,0,0);
      if( drawSkid ) {
        skidLayer.pushMatrix();
        skidLayer.translate(tyreXrl, tyreYrl);
        skidLayer.rotate(steering*15);
        skidLayer.shape(frontTyre,0,0);
        skidLayer.popMatrix();
      }
    popMatrix();
    
    
    // draw front right tyre
    pushMatrix();
      translate(tyreXrr, tyreYrr);
      rotate(steering*15);
      shape(frontTyre,0,0);
      if( drawSkid ) {
        skidLayer.pushMatrix();
        skidLayer.translate(tyreXrr, tyreYrr);
        skidLayer.rotate(steering*15);
        skidLayer.shape(frontTyre,0,0);
        skidLayer.popMatrix();
      }
    popMatrix();


    // draw rear tyres

    shape(rearTyre, tyreXfl, tyreYfl);
    shape(rearTyre, tyreXfr, tyreYfr);
    if( drawSkid ) {
      skidLayer.shape( rearTyre, tyreXfl, tyreYfl, tireradiusF, tirewidthF);
      skidLayer.shape( rearTyre, tyreXfr, tyreYfr, tireradiusF, tirewidthF);
    }

    // draw right rear tyre
    //ellipse( tyreXfr, tyreYfr, tireradiusF, tirewidthF);
    if( maxGripExceeded ) {
      
    }

    skidLayer.endDraw();
    
    //fill( carColor );
    noStroke();
    
    //ellipseMode(RADIUS);
    //ellipse( 0, 0, carlength, carheight);
    
    fill(palette.mainColorSecondary);
    stroke(palette.mainColorPrimary);
    beginShape();
    vertex( -carlength, 0);
    vertex( -carlength*0.3, -carheight);
    vertex( carlength,  0);
    vertex( -carlength*0.3, carheight);
    vertex( -carlength, 0);
    endShape();
    popMatrix();
  }
  
  
}
