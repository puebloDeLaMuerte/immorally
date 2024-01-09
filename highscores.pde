
void testSendHighscore() {
  
  println("testing highscore service ...");
  
  // URL of your endpoint
  String url = "http://immorally.mitgutemerfolg.org/api/submit_hotlap.php";

  // Creating a new POST request
  PostRequest post = new PostRequest(url);

  // Adding data to the request
  post.addData("user_id", "1");  // Replace with the actual user ID
  post.addData("track_id", "456"); // Replace with the actual track ID
  post.addData("lap_time", "789"); // Replace with the actual lap time

  // Sending the request
  post.send();

  // Checking the response
  println("Response Content  : " + post.getContent());
  println("Response to String: " + post.toString());
}
