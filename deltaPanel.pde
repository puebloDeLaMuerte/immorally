public interface Panel {
  public void showPanel();
}

class DeltaPanel {

  color fillColor;
  float opacity;
  String delta = "";
  float size = 250;
  //boolean isPositiveValue;
  boolean isPersonalBest;
  boolean isPositiveValue;
  
  public DeltaPanel(color c) {
    fillColor = c;
  }
  
  
  
  public void showPanel(String deltaToBest, String deltaToMedian, boolean isPositiveValue, boolean isPersonalBest, boolean showMedian) {
    
    this.isPositiveValue = isPositiveValue;
    this.isPersonalBest = isPersonalBest;
    delta = "";
    if( isPersonalBest ) {
      fillColor = palette.personalBest;
      delta = "-"+deltaToBest;
    }
    else if( isPositiveValue ) {
      if( showMedian ) {
        delta = "+" + "MEDIAN";//deltaToMedian;  
      } else {
        delta = "+" + deltaToBest;
      }
      fillColor = palette.worst;
    }
    else {
      if( showMedian ) {
        delta = "-" + "MEDIAN";//deltaToMedian;  
      } else {
        delta = "-" + deltaToBest;
      }
      fillColor = palette.best;
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
    if( isPersonalBest ) {
      head = "personal best";
    } else {
      if( isPositiveValue ) {
        head = "slow";  
      }
      else {
        head = "session best";
      }
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
