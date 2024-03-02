
public class User {

  String username;
  String password;
  String sessionToken;
  String latestServerResponse;

  public User( String username ) {
    this.username = username;
  }

  public User( String username, String password ) {
    this.username = username;
    this.password = password;
    thread("verifyUser");
  }

  public boolean isVerified() {
    return sessionToken != null && sessionToken.length() > 0;
  }
}


public void verifyUser() {

  println("try verify user with server");
  try {
    PostRequest post = new PostRequest("http://immorally.mitgutemerfolg.org/api/login.php");
    post.addData("username", user.username);
    post.addData("password", user.password);
    post.send(); // Send the request

    // Get the response
    String response = post.getContent();
    user.latestServerResponse = response;
    //println( "user login response: " + response );

    JSONObject json = parseJSONObject(response);

    if (json != null && json.hasKey("token")) {
      println("session token received");
      user.sessionToken = json.getString("token");
      userToFile();
    } else {
      println("login failed, no token received: " + response);
      user.sessionToken = null;
    }
  }
  catch (Exception e) {
    println("exception while verifying user");
  }
}


public User userFromFile( String filePath ) {

  String[] strings = loadStrings(filePath);

  if ( strings.length == 1 ) {

    return new User(strings[0]);
  } else if ( strings.length == 2 ) {

    return new User( strings[0], strings[1] );
  } else {

    println("invalid user-file: " + filePath);
    return null;
  }
}


public void userToFile() {
  String path = dataPath("user.txt");
  String[] s = { user.username, user.password };
  saveStrings(path,s);
}


boolean isUserExistsCallPending = false;
boolean currentUserNameExists = false;

// Function to initiate the username check
void triggerUsernameCheck(String username) {

  if ( !isStringValidForUserName(username) ) return;

  //println("initiating call to user_exists");
  if (!isUserExistsCallPending) {
    isUserExistsCallPending = true;
    Thread thread = new Thread(new Runnable() {
      @Override
        public void run() {
        checkUsernameExists(username);
        isUserExistsCallPending = false;
      }
    }
    );
    thread.start();
  } else {
    //println("Request is already pending.");
  }
}


void checkUsernameExists(String username) {

  if ( !isStringValidForUserName(username) ) return;

  GetRequest get = new GetRequest("http://immorally.mitgutemerfolg.org/api/user_exists.php?username=" + username);
  get.send(); // Send the request

  // This will run in the main thread and might freeze the UI for long requests
  // Consider using a separate thread for network requests in a real application
  String response = get.getContent();
  println("Server response: " + response);
  currentUserNameExists = response.contains("Username exists.");
}


boolean isStringValidForUserName(String s) {
  if ( s == null ) return false;
  if ( s.length() <= 0 ) return false;
  if ( s.contains(" ") ) return false;
  return true;
}


boolean registerUser(String u, String p) {

  println("registering user");
  PostRequest post = new PostRequest("http://immorally.mitgutemerfolg.org/api/register_user.php");
  post.addData("username", u);
  post.addData("password", p);
  post.send();

  String response = post.getContent().trim();
  if ( user != null ) user.latestServerResponse = response;
  println("Server response: " + response);
  return response.contains("User registered successfully.");
}
