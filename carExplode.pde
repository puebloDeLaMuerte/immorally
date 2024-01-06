class PShapeInfo {
    PShape shape;
    PVector position;
    float rotation;
    float rotationPerFrame;
    PVector positionPerFrame;

    PShapeInfo(PShape shape, PVector position, float rotation) {
        this.shape = shape;
        this.position = position;
        this.rotation = rotation;
        this.rotationPerFrame = random(-2,2);
        this.positionPerFrame = new PVector( random(-2,2), random(-2,2));
    }
}




class Explosion {
  
  ArrayList<PShapeInfo> components;
  PVector explosionSpeed;
  
  float frictionFactor = 0.95f;
  
  public Explosion( ArrayList<PShapeInfo> comps, PVector carSpeed ) {
    
    explosionSpeed = new PVector(carSpeed.x,carSpeed.y);
    this.components = comps;
  }
  
  public void tick() {
    for( PShapeInfo comp : components ) {
      comp.position.add(explosionSpeed);
      comp.position.add(comp.positionPerFrame);
      comp.rotation += comp.rotationPerFrame;
      comp.rotationPerFrame *= frictionFactor;
      comp.positionPerFrame.mult(frictionFactor);
    }
    explosionSpeed.mult(frictionFactor);
    
  }
  
  
  public void drawExplosion(PGraphics gr, float opacity) {
    
    if( gr != g ) {
      gr.beginDraw();  
    }
    
    for (PShapeInfo component : components) {
      
      gr.pushMatrix();
      gr.pushStyle();
      gr.stroke(palette.mainColorPrimary, opacity);
      
      PVector explodedPosition = component.position.copy();
      gr.translate(explodedPosition.x, explodedPosition.y);
      gr.rotate(component.rotation);
  
      gr.shape(component.shape);
  
      gr.popStyle();
      gr.popMatrix();
      
    }
    
    if( gr != g ) {
      gr.endDraw();  
    }
  }
    
}
