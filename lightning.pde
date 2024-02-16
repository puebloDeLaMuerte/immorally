Lightning lightning;
float chanceOfLightning = 0.02f;


class Lightning {

  ArrayList<Branch> branches;

  boolean isPathfindingComplete = false;
  boolean isDischarged = false;

  float reChargeChance = 0.1;

  float branchChance = 0.12;//0.3
  int ticksPerFrame = 4;//6

  Lightning() {

    branches = new ArrayList<Branch>();
    // Start with a single branch from the top center
    ArrayList<PVector> centerPoint = new ArrayList<PVector>();
    centerPoint.add( new PVector(random(width), 0) );
    branches.add(new Branch( this ));
  }

  void draw() {

    ArrayList<Branch> newBranches = new ArrayList<Branch>();

    boolean allAreDischarged = true;

    for (Branch branch : branches) {
      branch.update();
      branch.display();

      if ( branch.isComplete ) {
        isPathfindingComplete = true;
      }

      if ( !branch.isDischarged ) {
        allAreDischarged = false;
      }

      if ( !isPathfindingComplete && branch.isGrowing && random(1) < branchChance * ticksPerFrame) {
        // Create a new branch from the current branch's path
        newBranches.add(new Branch(this, new ArrayList<PVector>(branch.points)));
      }
    }
    isDischarged = allAreDischarged;
    branches.addAll(newBranches);
  }
}



class Branch {

  ArrayList<PVector> points; // Points making up this branch
  boolean isGrowing = true; // If the branch is still growing
  boolean isComplete = false;
  boolean isDischarged = false;

  float stepLength = 29;//10;
  PVector direction; // Current direction of growth
  float randomness = 12;//5;
  float pathXrandomFactor = 0.6f;//0.2
  float pathYrandomFactor = 0.6f;//0.5

  float strokeAlpha = 160;
  float strokeWeight = 1.5f;

  Lightning lightning;

  Branch(Lightning l) {
    this.lightning = l;
    this.points = new ArrayList<PVector>();
    this.points.add(randomStartingPoint());
    this.direction = dirToCenter(points.get(0));
  }

  Branch(Lightning l, ArrayList<PVector> startingPoints) {
    
    this.lightning = l;
    this.points = startingPoints;
    this.direction = dirToCenter(points.get(0));
  }

  // Most specific constructor does the actual initialization
  Branch(Lightning l, ArrayList<PVector> startingPoints, PVector direction) {
    this.lightning = l;
    this.points = startingPoints; // Initialized directly or modified after construction
    this.direction = direction;
  }
  
  
  PVector dirToCenter(PVector startPoint) {
    PVector d = PVector.sub(new PVector(width/2,height/2), startPoint).normalize();
    return d;
  }
  
  
  PVector randomStartingPoint() {
    
    if( random(1) > 0.3f ) {
      int r = (int)random(cpm.getAllCheckpoints().size()) ;
      
      if( cpm.getAllCheckpoints().size() > 0 ) {
        
        Checkpoint cp = cpm.getAllCheckpoints().get(r);
      
        List<PVector> points = cp.tile.pointsOnSurface;
        
        r = (int)random(points.size());
        
        return points.get(r);
      }
    }
    
    int side = (int) random(4); // Randomly choose a side (0: top, 1: right, 2: bottom, 3: left)
    switch (side) {
      case 0: // top
        return new PVector(random(width), 0);
      case 1: // right
        return new PVector(width, random(height));
      case 2: // bottom
        return new PVector(random(width), height);
      case 3: // left
        return new PVector(0, random(height));
      default:
        return new PVector(0, 0); // Fallback, should not happen
    }  
  }


  void update() {

    int ticks = lightning.ticksPerFrame;

    while ( ticks > 0 && isGrowing) {

      ticks--;

      PVector lastPoint = points.get(points.size() - 1);

      // Decide the next point's direction with randomness
      // Update the direction slightly at each step
      direction.x += random(-pathXrandomFactor, pathXrandomFactor); // Slight horizontal drift
      direction.y += random(-pathYrandomFactor, pathYrandomFactor); // Slight increase in downward tendency
      direction.normalize(); // Keep the direction vector normalized

      // Scale the direction for the next point's position
      float newX = lastPoint.x + direction.x * stepLength + random(-randomness, randomness);
      float newY = lastPoint.y + direction.y * stepLength + random(-randomness, randomness);
      
      boolean hitCheckpoint = hasHitCheckpoint(newX,newY);
      if (newY < height && newY > 0 && newX < width && newX > 0 && !hitCheckpoint ) {
        points.add(new PVector(newX, newY));
      } else {
        // Stop growing once outside the screen
        isGrowing = false;

        if ( newY > height || hitCheckpoint) {
          isComplete = true;
          startDischarge();
        } else {
          isComplete = true;
        }
      }
    }
  }
  
  boolean hasHitCheckpoint(float x, float y) {
    
    for( Checkpoint cp : cpm.getAllCheckpoints() ) {
      if( PGS_ShapePredicates.containsPoint(cp.tile.shape, new PVector(x,y)) ) {
        return true;
      }
    }
    
    return false;
  }

  void startDischarge() {
    strokeAlpha = 220;
    strokeWeight = 4;
  }

  void display() {

    if ( isDischarged ) return;

    stroke(red(palette.darkGlow), green(palette.darkGlow), blue(palette.darkGlow), strokeAlpha);
    //stroke(255,255,255, strokeAlpha);
    strokeWeight(strokeWeight);
    noFill();

    for (int i = 1; i < points.size(); i++) {
      line(points.get(i - 1).x, points.get(i - 1).y, points.get(i).x, points.get(i).y);
    }

    if ( lightning.isPathfindingComplete ) {
      strokeWeight /= 1.2f;//1.5
      strokeAlpha /= 1.002;//0.01
    }

    if ( isComplete && random(1) < lightning.reChargeChance ) {
      startDischarge();
    }

    if ( strokeWeight <= 0.11 || strokeAlpha <= 0.11 ) {
      isDischarged = true;
    }
  }
}




void handleLightning() {
  if( lightning != null ) {
    
    lightning.draw();  
  
    if( lightning.isDischarged ) {
      lightning = null;
    }
  } 
  
  if( lightning == null ) {
    if( random(1) < chanceOfLightning ) {
      lightning = new Lightning();
    }
  }
}
