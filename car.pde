public class Car {

  //private float carWidth, carHeight;
  private int carColor = color(200, 0, 0);

  private PVector pos = new PVector();

  private float rotation;
  private float currentDirection;
  //private float speed;

  public PVector tyreFLworldPos = new PVector(0, 0);
  public PVector tyreFRworldPos = new PVector(0, 0);
  public PVector tyreRLworldPos = new PVector(0, 0);
  public PVector tyreRRworldPos = new PVector(0, 0);
  public ArrayList<PVector> tyreWorldPos;

  //private float maxSpeed = 8;

  private float steering;
  private float maxSteering = 0.03;
  private float steeringSensibility = 0.002f;

  private float acceleration;
  private float enginePower = 0.004f;//0.007f;
  private float maxAcceleration = 0.045; // ehemals 0.4

  private float breaking;
  private float breakPower = 0.018;
  private float maxBreaking = 0.035;

  private float carFriction = 0.0033f;// this has been a known classic for the friction constant: 0.0045;

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
  
  float tyreCollisionFactor = 1.8f; // add some padding to where tyre calculations are calculated. higher positive values put the collision detection points outwards from the car center.

  PShape frontTyre = createShape();
  PShape rearTyre = createShape();
  
  public Explosion explosion = null;

  float tyreSurfaceTemp = 0;
  float tyreCarcasseTemp = 0;
  float tyreOptimalTemp = 55;//55
  float tyreTempPenalty;
  
  float tyreCooldown = 0.006f;
  float tyreCarcasseFollow = 0.00025;// 0.0005 // how fast the tyre-carcasse temperature follows the tyre surface temp
  
  float tyreTempMaxDisplay = 105;
  float tyreTempBaselineDisplay = 30;

  private ArrayList<CarStatus> stati = new ArrayList<CarStatus>();

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
    frontTyre.vertex(-tireradiusF/2, 0);
    frontTyre.vertex(0, tirewidthF/2);
    frontTyre.vertex(tireradiusF/2, 0);
    frontTyre.vertex(0, -tirewidthF/2);
    frontTyre.vertex(-tireradiusF/2, 0);
    frontTyre.endShape();
    frontTyre.disableStyle();

    rearTyre.beginShape();
    rearTyre.vertex(-tireradiusR/2, 0);
    rearTyre.vertex(0, tirewidthR/2);
    rearTyre.vertex(tireradiusR/2, 0);
    rearTyre.vertex(0, -tirewidthR/2);
    rearTyre.vertex(-tireradiusR/2, 0);
    rearTyre.endShape();
    rearTyre.disableStyle();

    tyreWorldPos = new ArrayList<PVector>();
    tyreWorldPos.add(tyreFLworldPos);
    tyreWorldPos.add(tyreFRworldPos);
    tyreWorldPos.add(tyreRLworldPos);
    tyreWorldPos.add(tyreRRworldPos);
  }


  public float getEngineLevel() {
    return acceleration;
  }


  public float getSpeed() {
    if( hasStatus(StatusType.DESTRUCTION) ) return 0.01f;
    return lastMove.mag();
  }


  public void triggerStatus( CarStatus status ) {
    stati.add( status );
  }


  public void updateStatus() {
    CarStatus removal = null;
    for ( CarStatus status : stati ) {
      if ( status.isFinished(millis()) ) {
        removal = status;
        break;
      }
    }
    if ( removal != null ) {
      if( removal.type == StatusType.DESTRUCTION ) {
        explosion = null;
        //pos = new PVector(width/2,height/2);
        acceleration = 0;
        breaking = 0;
        lastMove = new PVector(0,0);
      }
      stati.remove( removal );
    }
  }


  public boolean hasStatus( StatusType type ) {
    for ( CarStatus status : stati ) {
      if ( status.getType() == type ) {
        return true;
      }
    }
    return false;
  }



  public void TakeInput( float accelerationInput, float breakingInput, float steeringInput ) {

    //float delta = deltaTime * deltaFactor;

    //print("input: " + frameCount );

    steeringInput *= delta;
    accelerationInput *= delta;
    breakingInput *= delta;

    if ( hasStatus( StatusType.POWER_DOWN ) ) {
      accelerationInput = 0;
    }

    if ( steeringInput == 0f ) {
      steering -= ( 0.1 * steering ) * delta;// 0.99 * delta;
    } else if ( abs(steering) < maxSteering ) {
      steering += (steeringInput * steeringSensibility );
    } else {
      if ( steering < 0 ) steering = maxSteering*-1;
      else steering = maxSteering;
    }

    if ( accelerationInput == 0 ) {
      acceleration -= ( 0.1 * acceleration) * delta;
    } else acceleration += enginePower * accelerationInput;
    if ( acceleration > maxAcceleration ) acceleration = maxAcceleration;

    if ( breakingInput == 0 ) {
      breaking -= ( 0.1 * breaking ) * delta;
    } else if ( breaking < maxBreaking ) breaking += breakPower * breakingInput;
    if ( breaking > maxBreaking ) breaking = maxBreaking;
  }





  public void updatePhysics() {

    if( hasStatus(StatusType.DESTRUCTION) ) {
      if( explosion != null ) explosion.tick();
      return;
    }
    
    PVector newDir = new PVector();
    newDir.add(lastMove);

    // ROTATE

    rotation += ( steering * delta );
    PVector thisRotation = PVector.fromAngle(rotation);

    // ACCELERATE

    PVector thisAcceleration = new PVector(thisRotation.x, thisRotation.y);
    thisAcceleration.mult( acceleration * delta );

    newDir.add(thisAcceleration);


    // BREAKING

    PVector lastDir = new PVector(lastMove.x, lastMove.y).normalize();
    PVector thisBreaking = new PVector(-lastDir.x, -lastDir.y);
    thisBreaking.mult( breaking * delta );

    newDir.add(thisBreaking);

    // STEERING

    //float lastMoveMag = new PVector(lastMove.x * delta, lastMove.y * delta).mag(); // with delta
    //float lastMoveMag = lastMove.mag();
    PVector steeredDir = new PVector(thisRotation.x, thisRotation.y).setMag( newDir.mag() );
    PVector thisSteering = PVector.sub(steeredDir, newDir);

    newDir.add(thisSteering);

    // SLIDE
    /*
     PVector demand = new PVector(0,0).add(new PVector(thisAcceleration.x,thisAcceleration.y).div(delta));
     demand.add(new PVector(thisBreaking.x,thisBreaking.y).div(delta));
     demand.add(new PVector(thisSteering.x,thisSteering.y).div(delta));//.add(thisFriction);
     */
    PVector demand = new PVector().add(thisAcceleration).add(thisBreaking).add(thisSteering);

    float slideFactor = 0;
    //float slideFactor = 1-log( (forceMag*(8))+(1)) ;
    maxGripExceeded = true;


    //slideFactor = 1-((thisSteering.mag())*0.04);  // works but is not logically right
    slideFactor += (thisSteering.mag() * 50f) ;
    slideFactor += (demand.mag() * 5f) ;
    
    slideFactor +=  slideFactor * abs(tyreTempPenalty);

    slideFactor /= delta; // don't know why, but thi seems to make sliding behave correctly over different frameRates

    slideFactor = slideFactor / (slideFactor+2f);



    //println(slideFactor);

    skidAmount = slideFactor;

    //demand.add( thisSteering.mult(-1).mult(slideFactor) ); // this is where sliding is added
    PVector thisSlide = new PVector( thisSteering.x * -1, thisSteering.y * -1 ).mult(slideFactor);

    newDir.add(thisSlide);

    // old pip style friction calculation
    //PVector thisFriction = new PVector( -newDir.x, -newDir.y ).mult(carFriction).mult((0.0015)+newDir.mag())/*.mult(delta)*/;
    //newDir.add(thisFriction);
    // new GPT style friction calculation:
    PVector frictionForce = new PVector(-newDir.x, -newDir.y);
    frictionForce.normalize(); // Normalize it to get the direction of friction
    frictionForce.mult(carFriction * ( (0.0015) + newDir.mag())); // Apply the friction coefficient and speed-dependent factor
    frictionForce.mult(delta);
    newDir.add(frictionForce);


    // TODO: apply more friction if the cars rotation is not aligned with it's actual direction of travel

    lastMove = new PVector(newDir.x, newDir.y);

    PVector scaledNewDir = new PVector( newDir.x * delta, newDir.y * delta );
    //lastMove = new PVector(scaledNewDir.x, scaledNewDir.y);

    pos.add(scaledNewDir);
    //pos.add(newDir);

    // TYRE WEAR
    
    //tyreTemp += demand.add(thisSlide).magSq();
    tyreSurfaceTemp += thisAcceleration.magSq() / delta * 50;
    tyreSurfaceTemp += thisBreaking.magSq() / delta * 100 * getSpeed();
    tyreSurfaceTemp += thisSteering.magSq() / 30 * delta;
    tyreSurfaceTemp += thisSlide.magSq() / 30 * delta;
    tyreSurfaceTemp -= tyreCooldown * 10 * delta;
    tyreSurfaceTemp -= tyreSurfaceTemp * tyreCooldown * delta ;
    if( tyreSurfaceTemp < 0 ) tyreSurfaceTemp = 0;
    tyreCarcasseTemp = tyreCarcasseTemp + ((tyreSurfaceTemp-tyreCarcasseTemp) * tyreCarcasseFollow * delta);

    // EMIT SPARKS MAYBE ??
    float s = getSpeed();
    if ( /*s > sparksSpeed * deltaTime * deltaFactor || */ slideFactor > 0.1) {
      //println(getSpeed());
      if ( s * random(0, 1) > 3.98 ) {

        float d = random(TWO_PI);
        PVector sparkPos = PVector.fromAngle(d);
        sparkPos.setMag( random(0, carheight*2) );
        sparks.releaseSpark(PVector.add(pos, sparkPos), newDir);
      }
    }
  }
  
  
  public void calculatePenalty() {
    
    float maxPenalty = 2.4;//1.2; // Maximum penalty value
    float penaltyRange = tyreOptimalTemp; // Range within which the penalty increases
  
    // Calculate the absolute difference from the optimal temperature
    float tempDifference = (tyreCarcasseTemp) - tyreOptimalTemp;
  
    // Calculate the penalty as a ratio of the difference to the penalty range
    tyreTempPenalty = min(tempDifference / penaltyRange, maxPenalty);  
  }



  public ArrayList<PVector> getTyreWorldPos() {

    tyreWorldPos.clear();
    tyreWorldPos.add(tyreFLworldPos);
    tyreWorldPos.add(tyreFRworldPos);
    tyreWorldPos.add(tyreRLworldPos);
    tyreWorldPos.add(tyreRRworldPos);
    return tyreWorldPos;
  }



  public void drawCar(PGraphics skidLayer) {

    if( hasStatus(StatusType.DESTRUCTION) ) {
      if( explosion != null ) {
        explosion.drawExplosion(g,255);
        explosion.drawExplosion(skidLayer,20);
      }
      return;
    }


    float xOffset = carlength/2;

    pushMatrix();

    translate(pos.x, pos.y);
    rotate(rotation);
    //rotate(-currentDirection - HALF_PI);

    strokeWeight(3);

    skidLayer.beginDraw();

    //println(skidAmount);
    boolean drawSkid;
    float skidThreshold = 0.04f;
    if ( skidAmount > skidThreshold * delta ) {
      skidLayer.fill(0, 0, 0, (skidAmount-skidThreshold) * 10.5f);// * delta);
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

    

    tyreFLworldPos = new PVector(screenX(tyreXfl*tyreCollisionFactor, tyreYfl*tyreCollisionFactor), screenY(tyreXfl*tyreCollisionFactor, tyreYfl*tyreCollisionFactor ));
    tyreFRworldPos = new PVector(screenX(tyreXfr*tyreCollisionFactor, tyreYfr*tyreCollisionFactor), screenY(tyreXfr*tyreCollisionFactor, tyreYfr*tyreCollisionFactor ));
    tyreRLworldPos = new PVector(screenX(tyreXrl*tyreCollisionFactor, tyreYrl*tyreCollisionFactor), screenY(tyreXrl*tyreCollisionFactor, tyreYrl*tyreCollisionFactor ));
    tyreRRworldPos = new PVector(screenX(tyreXrr*tyreCollisionFactor, tyreYrr*tyreCollisionFactor), screenY(tyreXrr*tyreCollisionFactor, tyreYrr*tyreCollisionFactor ));

    //fill(palette.black);
    
    float tyreSurfaceTempOpa = max(tyreSurfaceTemp,tyreCarcasseTemp);
    
    tyreSurfaceTempOpa -= tyreTempBaselineDisplay;
    if( tyreSurfaceTempOpa < 0 ) tyreSurfaceTempOpa = 0;
    tyreSurfaceTempOpa = tyreSurfaceTempOpa / tyreTempMaxDisplay;
    tyreSurfaceTempOpa *= 255;
    
    /*
    float tyreCarcasseTempOpa = tyreCarcasseTemp - tyreTempBaselineDisplay;
    if( tyreCarcasseTempOpa < 0 ) tyreCarcasseTempOpa = 0;
    tyreCarcasseTempOpa = tyreCarcasseTemp / (tyreTempMaxDisplay-tyreTempBaselineDisplay);
    tyreCarcasseTempOpa = (tyreCarcasseTempOpa * tyreCarcasseTempOpa * tyreCarcasseTempOpa);
    tyreCarcasseTempOpa *= 255;
    */
    fill(tyreSurfaceTempOpa);
    
    stroke(palette.mainColorPrimary);
    //ellipseMode(CENTER);

    // draw front left tyre
    pushMatrix();
    translate(tyreXrl, tyreYrl);
    rotate(steering*15);
    shape(frontTyre, 0, 0);
    
    if ( drawSkid ) {
      skidLayer.pushMatrix();
      skidLayer.translate(tyreXrl, tyreYrl);
      skidLayer.rotate(steering*15);
      skidLayer.shape(frontTyre, 0, 0);
      skidLayer.popMatrix();
    }
    popMatrix();


    // draw front right tyre
    pushMatrix();
    translate(tyreXrr, tyreYrr);
    rotate(steering*15);
    shape(frontTyre, 0, 0);
    
    if ( drawSkid ) {
      skidLayer.pushMatrix();
      skidLayer.translate(tyreXrr, tyreYrr);
      skidLayer.rotate(steering*15);
      skidLayer.shape(frontTyre, 0, 0);
      skidLayer.popMatrix();
    }
    popMatrix();


    // draw rear tyres

    shape(rearTyre, tyreXfl, tyreYfl);
    shape(rearTyre, tyreXfr, tyreYfr);
    
    if ( drawSkid ) {
      skidLayer.shape( rearTyre, tyreXfl, tyreYfl, tireradiusF, tirewidthF);
      skidLayer.shape( rearTyre, tyreXfr, tyreYfr, tireradiusF, tirewidthF);
    }

    // draw right rear tyre
    //ellipse( tyreXfr, tyreYfr, tireradiusF, tirewidthF);
    if ( maxGripExceeded ) {
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
    vertex( carlength, 0);
    vertex( -carlength*0.3, carheight);
    vertex( -carlength, 0);
    endShape();
    popMatrix();
  }
  
  
  
  
  
  public ArrayList<PShapeInfo> getCarComponents() {
    
    
    ArrayList<PShapeInfo> components = new ArrayList<PShapeInfo>();

    // Add the car body as a component
    PShape carBody = createShape();
    carBody.beginShape();
    carBody.vertex(-carlength, 0);
    carBody.vertex(-carlength * 0.3, -carheight);
    carBody.vertex(carlength, 0);
    carBody.vertex(-carlength * 0.3, carheight);
    carBody.vertex(-carlength, 0);
    carBody.endShape(CLOSE); // Ensure the shape is closed
    carBody.disableStyle();
    components.add(new PShapeInfo(carBody, new PVector(pos.x, pos.y), rotation));

    

    // Calculate tire positions
    float xOffset = carlength/2;
    float tyreXrl = carlength - xOffset + tyreRearOffset;
    float tyreYrl = -tyreOutnessR + -(carheight/2)-(tirewidthR/2);
    float tyreXrr = carlength - xOffset + tyreRearOffset;
    float tyreYrr = tyreOutnessR + (carheight/2)+(tirewidthR/2);
    float tyreXfl = (carlength/2) - xOffset + tyreFrontOffset;
    float tyreYfl = -tyreOutnessF + -(carheight/2)-(tirewidthF/2);
    float tyreXfr = (carlength/2) - xOffset + tyreFrontOffset;
    float tyreYfr = tyreOutnessF + (carheight/2)+(tirewidthF/2);

    // Add each tire as a component
    // Front Left Tire
    components.add(new PShapeInfo(createTireShape(tireradiusF, tirewidthF), new PVector(pos.x + tyreXfl, pos.y + tyreYfl), rotation + steering * 15));
    // Front Right Tire
    components.add(new PShapeInfo(createTireShape(tireradiusF, tirewidthF), new PVector(pos.x + tyreXfr, pos.y + tyreYfr), rotation + steering * 15));
    // Rear Left Tire
    components.add(new PShapeInfo(createTireShape(tireradiusR, tirewidthR), new PVector(pos.x + tyreXrl, pos.y + tyreYrl), rotation));
    // Rear Right Tire
    components.add(new PShapeInfo(createTireShape(tireradiusR, tirewidthR), new PVector(pos.x + tyreXrr, pos.y + tyreYrr), rotation));

    return components;
  }
  
  // Function to create a tire shape
    PShape createTireShape(float radius, float width) {
        PShape tire = createShape();
        tire.beginShape();
        tire.vertex(-radius/2, 0);
        tire.vertex(0, width/2);
        tire.vertex(radius/2, 0);
        tire.vertex(0, -width/2);
        tire.vertex(-radius/2, 0);
        tire.endShape();
        tire.disableStyle();
        return tire;
    }

}

public enum StatusType {
  POWER_DOWN,
  DESTRUCTION
}

public class CarStatus {
  private int triggeredMillis;
  private int durationMillis;
  private int finishedMillis;
  private StatusType type;

  public CarStatus( int triggeredMillis, int durationMillis, StatusType type ) {
    this.triggeredMillis = triggeredMillis;
    this.durationMillis = durationMillis;
    this.finishedMillis = triggeredMillis + durationMillis;
    this.type = type;
  }

  public boolean isFinished( int millis ) {
    return millis > finishedMillis;
  }


  public StatusType getType() {
    return type;
  }
}
