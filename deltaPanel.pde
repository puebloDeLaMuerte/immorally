public interface Panel {
  public void showPanel();
}

class DeltaPanel {

  color fillColor;
  float opacity;
  String delta = "";
  float size = 250;
  //boolean isPositiveValue;
  boolean isAbsoluteBest;
  
  
  public DeltaPanel(color c) {
    fillColor = c;
  }
  
  
  
  public void showPanel(String deltaToBest, String deltaToMedian, boolean isPositiveValue, boolean isAbsoluteBest, boolean showMedian) {
    
    //this.isPositiveValue = isPositiveValue;
    this.isAbsoluteBest = isAbsoluteBest;
    delta = "";
    if( isAbsoluteBest ) {
      fillColor = color(#8f19c1);
      delta = "-"+deltaToBest;
    }
    else if( isPositiveValue ) {
      if( showMedian ) {
        delta = "+" + deltaToMedian;  
      } else {
        delta = "+" + deltaToBest;
      }
      fillColor = color(175,0,0);
    }
    else {
      if( showMedian ) {
        delta = "-" + deltaToMedian;  
      } else {
        delta = "-" + deltaToBest;
      }
      fillColor = color(0,175,0);
    }
    //delta += deltaToMedian;
    opacity = 200;
  }
  
  
  
  public void drawPanel() {
    
    pushStyle();
    stroke(palette.mainColorPrimary);
    strokeWeight(3);
    fill(fillColor,opacity);
    textFont(font);
    
    textSize(size/4);
    String head;
    if( isAbsoluteBest ) {
      head = "personal best";
    } else {
      head = "slower";
    }
    float xPos = width/2-textWidth(head)/2;
    float yPos = height/2-size/2 - size/4;
    text(head, xPos, yPos);
    
    textSize(size);
    xPos = width/2-textWidth(delta)/2;
    yPos = height/2+size/2;
    text(delta,xPos,yPos);
    popStyle();
    
    if( opacity > 0 ) opacity--;
  }
  
}
