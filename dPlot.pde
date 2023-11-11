public class DPlott {
  
  
  private ArrayList<PVector> plotPositions;
  private ArrayList<PVector> plotVectors;
  private ArrayList<Integer> plotColors;
  private ArrayList<Float>   plotRotations;
  
  private float scale = 1;
  
  public DPlott() {
    
    plotPositions = new ArrayList<PVector>();
    plotVectors = new ArrayList<PVector>();
    plotColors = new ArrayList<Integer>();
    plotRotations = new ArrayList<Float>();
  }
  
  private void resetLists() {
    plotPositions.clear();
    plotVectors.clear();
    plotColors.clear();
    plotRotations.clear();
  }
  
  
  public void setPlot( PVector vec, int col ) {
    setPlot( vec, new PVector(0,0), 0, col );
  }
  
  public void setPlot( PVector vec ) {
    setPlot( vec, new PVector(0,0), 0, color(255) );
  }
  
  public void setPlot( PVector vec, PVector pos ) {
    setPlot( vec, pos, 0, color(255) );
  }
  
  public void setPlot( PVector vec, PVector pos, float rot ) {
    setPlot( vec, pos, rot, color(255) );
  }
  
  public void setPlot( PVector vec, PVector pos, float rot, int col ) {
    plotPositions.add(pos);
    plotVectors.add(vec);
    plotColors.add(col);
    plotRotations.add(rot);
  }
  
  public void draw() {
    
    pushMatrix();
    pushStyle();
    
    for( int i = 0; i < plotPositions.size(); i++ ) {
      
      //println("Position: " + plotPositions.get(i).x + ", " + plotPositions.get(i).y);
      //println("Vector: " + plotVectors.get(i).x + ", " + plotVectors.get(i).y);
      
      pushMatrix();
      translate( plotPositions.get(i).x, plotPositions.get(i).y );
      scale(scale);
      strokeWeight(1/scale);
      noFill();
      stroke( plotColors.get(i) );
      line( 0,0, plotVectors.get(i).x, plotVectors.get(i).y );
      popMatrix();
    }
    
    popStyle();
    popMatrix();
    resetLists();
  }
}
