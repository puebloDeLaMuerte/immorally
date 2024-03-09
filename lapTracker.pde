public class LapTracker {
  
  TreeMap<Integer, PositionRecord> records;
 
  public LapTracker() {
    records = new TreeMap<>();
  }
  
  void addRecord(int timestamp, PVector position, float rotation) {
    
    PositionRecord newRecord = new PositionRecord(timestamp, position, rotation);
    records.put(timestamp, newRecord);
  }
  
  public PositionRecord getRecord(int querystamp) {
    Map.Entry<Integer, PositionRecord> entry = records.floorEntry(querystamp);
    return (entry != null) ? entry.getValue() : null;
  }
}


public class PositionRecord {
    
  Integer timeStamp;
  PVector position;
  float rotation;
  
  public PositionRecord(Integer timeStamp, PVector position, float rotation) {
    this.timeStamp = timeStamp;
    this.position = position;
    this.rotation = rotation;
  }
}
