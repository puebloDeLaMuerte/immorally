
void testSendHighscore(int lapTime) {
  
  println("testing highscore service ...");
  
  // URL of your endpoint
  String url = "http://immorally.mitgutemerfolg.org/api/submit_hotlap.php";

  // Creating a new POST request
  PostRequest post = new PostRequest(url); //<>//
  post.addData("HTTP_AUTHORIZATION", user.sessionToken);
  post.addData("HTTP_API_KEY", apiKey);
  // Adding data to the request
  //post.addData("track_id", "456"); // Replace with the actual track ID
  post.addData("lap_time", ""+lapTime); // Replace with the actual lap time
  post.addData("track_hash", track.getSHA256Hash() );
  // Sending the request
  post.send();

  // Checking the response
  println("Response Content  : " + post.getContent());
  println("Response to String: " + post.toString());
}





void testRegisterTrack() {
  
  println("testRegisterTrack");
  int serverTrackID = checkIfTrackExists(track.getSHA256Hash());
  if( serverTrackID == -1 ) {
    println("track not registered on server, registering now");
    boolean success = registerTrack( track.trackName, track.getSHA256Hash(), 1 );
    if( success ) println("track registered successfully");
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
