
public class User {

  String userName;
  String password;
  String sessionToken;
  String latestServerResponse;

  public User( String userName, String password ) {
    this.userName = userName;
    this.password = password;
    sessionToken = verifyUser(userName, password);
  }

  public boolean isVerified() {
    return sessionToken != null && sessionToken.length() > 0;
  }


  String verifyUser(String username, String password) { //<>//
    println("try verify user with server");
    try {
      PostRequest post = new PostRequest("http://immorally.mitgutemerfolg.org/api/login.php");
      post.addData("username", username);
      post.addData("password", password);
      post.send(); // Send the request

      // Get the response
      String response = post.getContent();
      latestServerResponse = response;
      //println( "user login response: " + response );

      JSONObject json = parseJSONObject(response);

      if (json != null && json.hasKey("token")) {
        println("session token received");
        return json.getString("token");
      } else {
        println("login failed, no token received: " + response);
        return null;
      }
    }
    catch (Exception e) {
      println("exception while verifying user");
    }
    return null;
  }
}


public User userFromFile( String filePath ) {

  String[] strings = loadStrings(filePath);

  if ( strings.length != 2 ) {
    println("invalid user-file: " + filePath);
    return null;
  }

  //strings[0];
  //strings[1];

  return new User( strings[0], strings[1] );
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
