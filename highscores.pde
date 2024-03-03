public class Highscores {

  int currentHotlapWorldRank = -1;

  int previousHotlapWorldRank = -1;
  int previousBestLapTime = -1;// (int)maxLapTime;

  int lastReachedRankTierNr = -1;
  int lastReachedTierRank = -1;
  int lastReachedTierTime = -1;

  private boolean displayLapTimeAsNew = false;
  private boolean displayRankAsNew = false;

  ArrayList<TierScore> tierScores = new ArrayList<TierScore>();
  
  public TierScore getLatestTierScore() {
    int highest = 0;
    TierScore r = null;
    for( TierScore s : tierScores) {
      if( s.tier > highest ) {
        highest = s.tier;
        r = s;
      }
    }
    return r;
  }

  public void newLap() {
    displayLapTimeAsNew = false;
    displayRankAsNew = false;
  }

  public void setNewPreviousRank( int rank ) {

    if ( rank < previousHotlapWorldRank || previousHotlapWorldRank <= 0) {
      displayRankAsNew = true;
      previousHotlapWorldRank = rank;
    }
  }

  public void setNewPreviousLapTime( int laptime ) {

    if ( laptime < previousBestLapTime || previousBestLapTime <= 0 || previousBestLapTime == maxLapTime ) {
      displayLapTimeAsNew = true;
      previousBestLapTime = laptime;
    } else {
      println("not setting time: " + laptime + " maxLapTime: " + maxLapTime + " previousBestLapTime: " + previousBestLapTime);
    }
  }

  public boolean displayLapTimeAsNew() {
    return displayLapTimeAsNew;
  }

  public boolean displayRankAsNew() {
    return displayRankAsNew;
  }


  public String getPreviousBestTime() {

    if ( previousBestLapTime == -1 ) {
      return cpm.timeAsDisplayString(-1);
    }
    if ( previousBestLapTime == (int)maxLapTime ) {
      return cpm.timeAsDisplayString(-1);
    }

    return cpm.timeAsDisplayString(previousBestLapTime);
  }
}



void sendHighscore() {

  println("submitting to highscore service ...");

  // URL of your endpoint
  String url = "http://immorally.mitgutemerfolg.org/api/submit_hotlap.php";

  // Creating a new POST request
  PostRequest post = new PostRequest(url);
  post.addData("HTTP_AUTHORIZATION", user.sessionToken);
  post.addData("HTTP_API_KEY", apiKey);
  // Adding data to the request
  //post.addData("track_id", "456"); // Replace with the actual track ID
  int lt = cpm.getCurrentBestLapTimeAsInt();
  post.addData("lap_time", ""+ lt); // Replace with the actual lap time
  post.addData("track_hash", track.getSHA256Hash() );
  // Sending the request
  post.send();

  // Checking the response
  println("Response Content  : " + post.getContent());

  //// PARSE THE RESULT

  String input = post.getContent();
  String regex = "Your rank: (\\d+)";

  Pattern pattern = Pattern.compile(regex);
  Matcher matcher = pattern.matcher(input);

  if (matcher.find()) {
    int rank = Integer.parseInt(matcher.group(1)); // Group 1 contains the first set of parentheses in the regex, which is the digits part
    println("new rank: " + rank + " currentHotlapRank: " + cpm.highscores.currentHotlapWorldRank);
    if ( rank < cpm.highscores.currentHotlapWorldRank ) {
      cpm.displaySessionBestRankAsNew = true;
      println("display as NEW");
    }
    cpm.highscores.currentHotlapWorldRank = rank;
    cpm.highscores.setNewPreviousRank(rank);

    println("string: " + matcher.group(1));
    System.out.println("Rank: " + rank);
  } else {
    System.err.println("Rank not found in the input string.");
  }
}


public class TierScore {
  
  private int tier = -1;
  private int rank = -1;
  private int bestRank = -2;
  private int medianTime = -1;
  
  public TierScore(int tierNr, int medianTime) {
    this.tier = tierNr;
    this.medianTime = medianTime;
  }
  
  public int getTier() {
    return tier;
  }
  
  public int getRank() {
    return rank;
  }
  
  public int getMedianTime() {
    return medianTime;
  }
  
  public boolean isSetFromServer() {
    return rank != -1 && bestRank != -2;
  }
  
  public boolean isNewRecord() {
    return rank == bestRank || bestRank < 0;
  }
  
  public void setData(int rank, int bestRank) {
    if(isSetFromServer()) return;
    this.rank = rank;
    this.bestRank = bestRank;
  }
}



void receiveBestScore() {

  println("getting prev highscore ...");

  // URL of your endpoint
  String url = "http://immorally.mitgutemerfolg.org/api/get_user_best_score.php";

  // Creating a new POST request
  PostRequest post = new PostRequest(url);
  post.addData("HTTP_AUTHORIZATION", user.sessionToken);
  post.addData("HTTP_API_KEY", apiKey);
  // Adding data to the request

  post.addData("track_hash", track.getSHA256Hash() );
  // Sending the request
  post.send();

  // Checking the response
  println("Response Content  : " + post.getContent());

  //// PARSE THE RESULT

  String response = post.getContent();

  int[] results = {-1, -1}; // Default values

  String[] parts = response.split(",");
  if (!"NTR,NR".equals(response)) { // Check if it's not the default failure response
    try {
      results[0] = Integer.parseInt(parts[0]); // Parse best time
      results[1] = Integer.parseInt(parts[1]); // Parse world rank

      println("best time: " + results[0] + " rank: " + results[1]);

      cpm.highscores.previousBestLapTime = results[0];
      cpm.highscores.previousHotlapWorldRank = results[1];
    }
    catch(Exception e) {
      println("error parsing previous highscores result: " + response);
    }
  } else {
    println("no previous score data");
  }
}







void submitTierHighscore() {

  println("submitting tier highscore now...");
  
  TierScore ts = cpm.highscores.getLatestTierScore();

  String url = "http://immorally.mitgutemerfolg.org/api/submit_tier_highscore.php"; 
  
  //String[] postData = {"track_hash=" + trackHash, "median_lap_time=" + medianLapTime, "score_tier=" + scoreTier};
  
  PostRequest post = new PostRequest(url);
  post.addData("HTTP_AUTHORIZATION", user.sessionToken);
  post.addData("HTTP_API_KEY", apiKey);  
  post.addData("track_hash", track.getSHA256Hash() );
  post.addData("score_tier", ""+ts.getTier());
  post.addData("median_lap_time", ""+ts.getMedianTime());
  
  post.send();

  String response = post.getContent(); 
  
  //println( "highscore service response: " + response );

  String status = "";
  String message = ""; // Used only if there's an error
  int rank = -1;
  boolean newRecord = false;
  int highestRank = -1;

  // Parse the response
  String[] responseLines = split(response, ";");
  for (String line : responseLines) {
    String[] entry = split(line, ":");
    if (entry.length == 2) {
      switch (entry[0]) {
      case "STATUS":
        status = entry[1];
        println("status: " + status);
        break;
      case "MESSAGE":
        message = entry[1];
        println("message: " + message);
        break;
      case "RANK":
        rank = parseInt(entry[1]);
        println("rank: " + rank);
        break;
      case "NEW_RECORD":
        newRecord = entry[1].equals("TRUE");
        println("new record: " + newRecord);
        break;
      case "HIGHEST_RANK":
        highestRank = parseInt(entry[1]);
        println("highest rank: " + highestRank);
        break;
      }
    }
  }
  
  if( status.equalsIgnoreCase("SUCCESS") ) {
    ts.setData(rank,highestRank);
  } else {
    println("tiered highscore result error: " + response);
  }
}







void testRegisterTrack() {

  println("testRegisterTrack");
  int serverTrackID = checkIfTrackExists(track.getSHA256Hash());
  if ( serverTrackID == -1 ) {
    println("track not registered on server, registering now");
    boolean success = registerTrack( track.trackName, track.getSHA256Hash(), 1 );
    if ( success ) println("track registered successfully");
  } else {
    println("track already registered");
  }
}



int checkIfTrackExists(String trackHash) {

  GetRequest get = new GetRequest("http://immorally.mitgutemerfolg.org/api/get_track_id.php?track_hash=" + trackHash);
  get.send();

  // Parse the response
  String response = get.getContent();
  println("Response: " + response);

  if (response.length() == 0 || response.startsWith("4") || response.startsWith("5") ) {
    return -1; // Track does not exist
  } else {
    return int(response.trim()); // Return the track ID
  }
}


// Function to register a new track
boolean registerTrack(String trackName, String trackHash, int createdBy) {

  PostRequest post = new PostRequest("http://immorally.mitgutemerfolg.org/api/register_track.php");
  post.addData("track_name", trackName);
  post.addData("track_hash", trackHash);
  post.addData("created_by", str(createdBy));
  post.send();

  // Check the response
  String response = post.getContent();
  println("Response: " + response);
  return response.equals("Track registered successfully.");
}
