import micycle.pgs.*;
import java.util.*;

float ofst;


public class Track {

  public ArrayList<Tile> tiles = new ArrayList<Tile>();
  boolean isGenerated = false;
  boolean splitException = false;
  String loadTrack = null;
  float tileMaxArea = 10000;

  boolean hasTopographyUpdate = false;

  int l = -1;
  String trackName;



  public Track( String trackFile ) {

    tiles = new ArrayList<Tile>();

    trackName = "blankTrack";

    if ( trackFile != null && trackFile != "" ) { // load Track

      this.loadTrack(trackFile);

      println( "track loaded: " );
      println( tiles.size() + " tiles" );
      println( cpm.checkpoints.size() + " checkpoint" );
    } else { // create new Tack

      ofst = 20;
      float[] floats = {ofst, ofst, width-ofst, ofst, width-ofst, height-ofst, ofst, height-ofst, ofst, ofst};
      tiles.add( new Tile(floats, this) );
    }
  }


  public boolean loadTrack(String trackFile) {

    String[] lines = loadStrings(trackFile);
    if ( lines == null || lines.length == 0 ) {
      println("error loading file: " + trackFile);
      return false;
    } else {
      cpm.checkpoints = new ArrayList<Checkpoint>();
      l++;
      trackName = lines[0];

      while ( !lines[l].equals("/track") ) {
        l++;
        if ( lines[l].equals("tile") ) {

          int typeNr = 0;
          l++;

          if ( lines[l].equals("type") ) {
            l++;
            typeNr = parseInt(lines[l]);
            l++;
          }


          int typeData = 0;
          if ( lines[l].equals("typeData") ) {
            l++;
            typeData = parseInt(lines[l]);
            l++;
          }

          PShape s = null;
          if ( lines[l].equals("shape") ) { //<>//
            ArrayList<PVector> vecs = new ArrayList<PVector>();
            s = createShape();
            s.beginShape();
            while ( ! lines[l].equals("/shape") ) {
              l++;
              if ( lines[l].equals("vert") ) {
                l++;
                while ( ! lines[l].equals("/vert") ) {
                  float x = parseFloat(lines[l]);
                  l++;
                  float y = parseFloat(lines[l]);
                  vecs.add(new PVector(x, y));
                  s.vertex(x, y);
                  l++;
                }
              }
            }
            s.endShape(CLOSE);
            s = PGS_Hull.concaveHullBFS(vecs, 1d); /////////////////// Hack for a problem i couldnt find a fix for. Remove this line and see what i mean!
            s.disableStyle();
          }
          if ( lines[l].equals( "/shape") ) {
            Tile t = new Tile(s, this);
            if ( typeNr == 1 ) { // typeNr 1 means Checkpoint
              t.checkpoint = new Checkpoint(t, typeData);
              cpm.checkpoints.add(t.checkpoint);
            }
            if ( typeNr == 2 ) {
              t.checkpoint = new PowerDownCheckpoint(t);
              cpm.specialCheckpoints.add(t.checkpoint);
            }
            tiles.add(t);
          }
        }
      }
    }
    cpm.sortCheckpoints();
    cpm.checkpoints.get(0).contact(car);

    return true;
  }



  public void saveTrack(String trackName) {

    println("saving Track: " + trackName);
    ArrayList<String> s = new ArrayList<String>();
    s.add(trackName);

    s.add("track");
    for (Tile t : tiles) {
      s.add("tile");
      s.add("type");
      if ( t.checkpoint != null ) {
        s.add(""+t.checkpoint.getTypeNr());
        s.add("typeData");
        s.add(""+t.checkpoint.getCheckpointData());
      } else {
        s.add("0");
      }



      s.add("shape");

      for (int i = 0; i < t.shape.getVertexCount(); i++) {

        s.add("vert");
        s.add( ""+t.shape.getVertex(i).x );
        s.add( ""+t.shape.getVertex(i).y );
        s.add("/vert");
      }

      s.add("/shape");
      s.add("/tile");
    }

    s.add("/track");

    String[] sarr = new String[s.size()];
    for (int i = 0; i < sarr.length; i++) {
      sarr[i] = s.get(i);
    }
    saveStrings( "data/tracks/" + trackName+".track", sarr );
  }



  public void updateTrack() {
    if ( !isGenerated ) {
      playStatic(true);
      car = new Car(width/2, height/2, 0);
      String gens = "generating...";
      textSize(40);
      fill(palette.mainColorSecondary);
      text(gens, width/2 -textWidth(gens)/2, height/2);
      boolean didSplit = false;
      Tile split = null;
      for (Tile t : tiles) {
        if (t.area > tileMaxArea) {
          split = t;
          didSplit = true;
        }
      }
      if ( split != null ) {
        doSplit(split);
      }
      if ( !didSplit ) {
        isGenerated = true;
        playDing();
        playStatic(false);
      }
      return;
    }

    if ( loadTrack != null ) {
      if ( loadTrack(loadTrack) ) loadTrack = null;
    }

    for ( Tile t : tiles ) {
      if ( t.checkpoint != null ) {
        if ( t.checkpoint.checked && !t.checkpoint.left ) {
          t.checkpoint.checkForLeft(t.shape);
        }
      }
    }
  }



  public PGraphics drawTrack(PGraphics gr) {
    println("drawTrack");
    if ( !hasTopographyUpdate ) return gr; //<>//
    gr.beginDraw();
    gr.background(0);
    for (Tile t : tiles ) t.drawTile(gr);
    gr.endDraw();
    hasTopographyUpdate = false;
    return gr;
  }



  public void checkCarPos(Car car) {


    for (Tile t : tiles) {

      if ( PVector.sub( t.center, car.pos ).magSq() < t.detectRadiusSquared ) { /// only check tiles that are close to the car

        //if ( PGS_ShapePredicates.containsPoint(t.shape, car.pos) ) {
        
        List twpcontains = PGS_ShapePredicates.containsPoints(t.shape, car.getTyreWorldPos());
        if ( twpcontains.contains(true) ) {
          t.drawHighlight(1f);
          //for(Tile n : t.neighbours) n.drawHighlight();
          if ( t.checkpoint != null ) {
            
            if( t.checkpoint instanceof PowerDownCheckpoint ) {
              println("power down");
            }
            t.checkpoint.contact(car);
          }
        } else if ( t.hasHighlight() ) {
          t.drawHighlight();
        }
      }
    }
    
    
  }


  void doSplit( int i ) {
    doSplit( tiles.get( i ) );
  }



  void doSplit(Tile tosplit) {

    Tile[] es = null;
    try {
      es = tosplit.randomSplit();
    }
    catch( Exception e ) {
      println("split exception: " + e);
      splitException = true;
      return;
    }

    if ( es == null ) return;
    tiles.remove( tosplit );
    tosplit.remove = true;
    tiles.add( es[0] );
    tiles.add( es[1] );
    hasTopographyUpdate = true;
  }
}











public class Tile {

  public Track track;
  public Checkpoint checkpoint = null;

  public int id;

  public PShape shape;
  public List<PVector> pointsOnSurface;
  public boolean isBorder;

  public double area;
  public float circumRadius;
  public float detectRadiusSquared;
  
  public color myColor;

  public ArrayList<Tile> neighbours = new ArrayList<Tile>();

  public boolean remove = false;
  public boolean isMouseOver;



  public boolean drawIsNeighbour = false;
  public boolean setDrawSpecialHighlight = false;
  public float highlightIntensity = 0f;
  public float lowlightIntensity = 0f;
  private float highlightGlowBack = 0.006f;

  public boolean neighbourUpdate = false;

  public boolean isSelected = false;

  public PVector center;



  public Tile(float[] points, Track track) {

    this.track = track;

    PShape s = createShape();
    s.beginShape();
    for ( int i = 0; i < points.length; i+=2)
    {
      s.vertex(points[i], points[i+1]);
    }
    s.endShape(CLOSE);
    s.disableStyle();
    //shape(s);
    setup(s);
  }


  public Tile( PShape s, Track track ) {
    this.track = track;
    setup(s);
  }



  private void setup( PShape s ) {

    if ( s == null ) {
      println("s is null"); //<>//
    }

    myColor = color( random(40, 200) );


    id = (int)random(Integer.MAX_VALUE);
    shape = s;
    //shape.beginShape();
    //shape.colorMode(HSB);
    //shape.stroke(palette.brightBlack);
    //shape.strokeWeight(2);
    //shape.fill( palette.black );
    //shape.disableStyle();
    //shape.endShape(CLOSE);


    area =  PGS_ShapePredicates.area(shape);

    pointsOnSurface = PGS_Processing.pointsOnExterior( shape, 2d, 0);

    for ( PVector p : pointsOnSurface ) {

      if ( p.x < ofst * 1.5 ) {
        isBorder = true;
      }
    }

    //PShape circle = PGS_Optimisation.maximumInscribedCircle( shape, 1d );
    PShape circle = PGS_Optimisation.minimumBoundingCircle( shape );
    float minX = Float.MAX_VALUE;
    float minY = Float.MAX_VALUE;
    float maxX = 0;
    float maxY = 0;

    for ( int i = 0; i < circle.getVertexCount(); i++ ) {
      PVector p = circle.getVertex(i);
      if ( p.x > maxX ) maxX = p.x;
      if ( p.y > maxY ) maxY = p.y;
      if ( p.x < minX ) minX = p.x;
      if ( p.y < minY ) minY = p.y;
    }

    center = new PVector( minX + ((maxX - minX)/2f), minY + ((maxY - minY)/2f) );
    
    circumRadius = ( maxX - minX ) / 2;

    detectRadiusSquared = (circumRadius * 1.5) * (circumRadius * 1.5);

    neighbourUpdate = true;
  }




  public boolean hasHighlight() {
    return lowlightIntensity > 0f;
  }



  public void drawHighlight(float hl) {

    highlightIntensity = hl;
    lowlightIntensity = hl;
    drawHighlight();
  }



  public void drawHighlight() {

    shape.disableStyle();
    //fill(palette.brightBlack);
    noFill();

    stroke(palette.darkGlow, lowlightIntensity * 30);
    lowlightIntensity -= highlightGlowBack / 2;
    //noStroke();
    //shape.stroke(palette.brightBlack);
    shape(shape);

    fill(palette.mainColorPrimary, highlightIntensity * 15);
    stroke(palette.brightBlack, highlightIntensity * 255);
    highlightIntensity -= highlightGlowBack*2.6;

    shape(shape);
    //shape.enableStyle();
    
    // draw circumCircle for debug
    //stroke(255);
    //ellipse( center.x, center.y, circumRadius*2, circumRadius*2 );
  }



  public void drawTile(PGraphics gr) {

    //shape.setFill(myColor);
    shape.enableStyle();
    shape.fill(palette.black);
    shape.stroke(palette.brightBlack);
    gr.shape(shape);
    shape.disableStyle();
    
  }


  public void drawMouseOver() {
    if ( !isMouseOver ) return;
    pushStyle();
    stroke( palette.mainColorPrimary );
    shape(shape);
    popStyle();
  }


  public void beginFrame() {

    drawIsNeighbour = false;
    setDrawSpecialHighlight = false;
    if ( neighbourUpdate ) neighbourUpdate();
  }



  public void SetDrawIsNeighbour(boolean isNeighbour) {
    drawIsNeighbour = isNeighbour;
  }



  public Tile[] randomSplit() {

    //println("randomSplit");

    notifyNeighbours();

    if ( shape == null ) {
      println("shape is null");
      return null;
    }
    if ( !shape.isClosed() ) {
      println("shape is not closed");
      return null;
    }
    if ( shape.getVertexCount() < 3 ) {
      println("vertex count " + shape.getVertexCount() );
      return null;
    }

    List<PVector> pts = PGS_Processing.pointsOnExterior( shape, 6, 0);

    PVector t1, t2;
    int splitOffset = 0;
    float minDist = sqrt( (width*width)+(height*height) );
    for ( int i = 0; i < pts.size()/2; i++ ) {

      int offset = i;
      t1 = pts.get(offset);
      t2 = pts.get(offset+pts.size()/2);

      float dist = PVector.sub(t1, t2).mag();
      if ( dist < minDist ) {
        splitOffset = i;
        minDist = dist;
      }
    }
    PVector p1 = pts.get(splitOffset);
    PVector p2 = pts.get(splitOffset+pts.size()/2);

    PVector p1dir = PVector.sub( p1, p2 );
    PVector p2dir = PVector.sub( p2, p1 );
    float mag = p1dir.mag();
    p1dir.setMag(mag+10);
    p2dir.setMag(mag+10);
    PVector sp1 = PVector.add(p2, p1dir);
    PVector sp2 = PVector.add(p1, p2dir);

    strokeWeight(3);
    stroke(palette.mainColorPrimary);
    line( sp1.x, sp1.y, sp2.x, sp2.y);

    PShape children = PGS_Processing.slice( shape, sp1, sp2 );

    //println( "split child count: " + children.getChildCount() );

    Tile[] ret = new Tile[2];

    ret[0] = new Tile( children.getChild(0), track);
    ret[1] = new Tile( children.getChild(1), track);

    if ( ret[0].shape.getVertexCount() > 2 && ret[1].shape.getVertexCount() > 2 ) {
      remove = true;
      return ret;
    } else return null;
  }



  public Tile mergeWith( Tile merger ) {

    println("MERGE: " + this.id + " width " + merger.id);

    float tolerance = 0.001f;

    PShape adjustedShape;

    PShape resultShape = PGS_ShapeBoolean.union( merger.shape, shape);

    int rotations = 0;
    double sumArea = PGS_ShapePredicates.area(resultShape);

    while ( rotations < merger.shape.getVertexCount() &&  (resultShape.getVertexCount() < 3 || sumArea == area || sumArea == merger.area ) ) {

      adjustedShape = rotatedVerticeIndices( merger.shape );

      resultShape = PGS_ShapeBoolean.union( adjustedShape, shape);
      sumArea = PGS_ShapePredicates.area(resultShape);
      rotations++;
      //println("r: " + rotations);
    }

    if ( sumArea == area ) {
      println("MERGE ERROR: sumArea == area");
      return null;
    }

    //println( resultShape.getVertexCount() + " vertices afer " + rotations + " rotations" );


    if ( resultShape.getVertexCount()  < 3 ) {
      println("MERGE ERROR: vertex count is " + resultShape.getVertexCount() );
      background(255, 5, 5);
      return null;
    }

    //PShape uShape = new PShape();
    //uShape.addChild( merger.shape );
    //uShape.addChild( this.shape );

    //PShape resultShape = PGS_ShapeBoolean.unionMesh( uShape );


    float[] nPoints = new float[ resultShape.getVertexCount()*2 ];

    for ( int i = 0; i < resultShape.getVertexCount(); i++ ) {
      PVector v = resultShape.getVertex(i);
      nPoints[i*2] = v.x;
      nPoints[(i*2)+1] = v.y;
    }

    Tile re = new Tile(nPoints, track);
    re.shape.setFill( color(0, 255, 0) );

    if ( re != null && re.area > 0 ) {

      area = PGS_ShapePredicates.area( shape );
      merger.area = PGS_ShapePredicates.area( merger.shape );
      println("new Tile area: " + re.area );
      println("old area this: " + area );
      println("old area mrgr: " + merger.area );

      double combinedArea = area + merger.area;

      if ( re.area > combinedArea * 1.1 || re.area < combinedArea * 0.9 ) {
        println( "MERGE ERROR: area check failed: " + re.area + " to " + merger.area + " and " + area);
        return null;
      }

      notifyNeighbours();
      merger.notifyNeighbours();

      this.remove = true;
      merger.remove = true;
      //track.tiles.remove(this);
      //track.tiles.remove(merger);

      return re;
    } else return null;
  }




  public void findNeighboursPointContained() {

    neighbours = new ArrayList<Tile>();
    int o = 30;

    for ( Tile e : track.tiles ) {
      if ( e.id != id ) {
        for ( PVector p : pointsOnSurface ) {

          if ( PGS_ShapePredicates.containsPoint( e.shape, p) ||
            PGS_ShapePredicates.containsPoint( e.shape, new PVector(p.x+o, p.y+o) ) ||
            PGS_ShapePredicates.containsPoint( e.shape, new PVector(p.x+o, p.y-o) ) ||
            PGS_ShapePredicates.containsPoint( e.shape, new PVector(p.x-o, p.y+o) ) ||
            PGS_ShapePredicates.containsPoint( e.shape, new PVector(p.x-o, p.y-o) )
            ) {
            neighbours.add(e);
            break;
          }
        }
      }
    }
  }




  public void findNeighboursPointBased() {

    neighbours = new ArrayList<Tile>();

    float pointMatchTolerance = 10f;
    int matchesNeeded = 1;

    for ( Tile e : track.tiles ) {
      if ( e.id != id ) {
        int pointsUnderThreshold = 0;
        for ( PVector pe : e.pointsOnSurface ) {
          for ( PVector p : pointsOnSurface ) {

            float dist = PVector.sub(p, pe).mag();
            if ( dist < pointMatchTolerance ) {
              //println(dist);
              pointsUnderThreshold++;
            }
          }
        }
        if ( pointsUnderThreshold > matchesNeeded ) {
          neighbours.add(e);
        }
      }
    }
  }






  public boolean mouseOver(int x, int y) {

    if ( PGS_ShapePredicates.containsPoint(shape, new PVector(x, y)) ) {

      isMouseOver = true;

      return true;
    } else {
      isMouseOver = false;
      return false;
    }
  }




  public void neighbourUpdate() {

    neighbourUpdate = false;
    findNeighboursPointBased();
  }


  public void notifyNeighbours() {

    for ( Tile n : neighbours ) {
      n.neighbourUpdate = true;
    }
  }

  public PShape rotatedVerticeIndices( PShape input ) {

    PShape returnShape = new PShape();
    returnShape.beginShape();
    for ( int i = 1; i < input.getVertexCount(); i++ ) {

      returnShape.vertex( input.getVertex(i).x, input.getVertex(i).y );
    }
    returnShape.vertex( input.getVertex(0).x, input.getVertex(0).y );
    returnShape.endShape(CLOSE);

    return returnShape;
  }
}
