boolean boomPlayed = false;
float opa = 255;
float opa2 = 0;

int enterCooldownFrame = -1;

boolean anyKeyPressed = false;


public void userLoginLoop() {

  pushStyle();
  textSize(25);

  fill(palette.mainColorSecondary);
  String t = "login or register";
  text(t, width/2-textWidth(t)/2, height/2 + 60);

  if ( user == null ) {
    user = userFromFile( dataPath("user.txt") );
    userInputString = user.username;
  } else if ( !user.isVerified() ) {
    t = "login error: " + user.latestServerResponse;
    //text(t, width/2-textWidth(t)/2, height/2+40);
  }

  boolean blink = frameCount%60 < 30;

  // username title
  textSize(20);
  if ( userPassSwitch && blink ) {
    fill( palette.white );
  } else fill( palette.mainColorSecondary);
  t = "username:";
  text(t, width/2-textWidth(t)/2, height/2+140);


  // the user input string for username

  //println(currentUserNameExists);

  if ( currentUserNameExists ) { // && (passInputString == null || passInputString == "") ) {
    if( blink && userPassSwitch) {
      fill( palette.destruction );
    } else {
      fill( red(palette.destruction), green(palette.destruction), blue(palette.destruction), 200);
    }
  } else {
    if( blink ) {
      fill( palette.white );  
    }
    else {
      fill( palette.mainColorPrimary );
    }
    
  }
  textSize(25);
  t = ""+userInputString;
  text(t, width/2-textWidth(t)/2, height/2+180);

  triggerUsernameCheck(userInputString);


  // password title

  if ( !userPassSwitch && blink ) {
    fill( palette.white );
  } else fill( palette.mainColorPrimary );
  textSize(20);
  t = "password:";
  text(t, width/2-textWidth(t)/2, height/2+220);



  // the user input string for password

  textSize(25);
  if( blink && !userPassSwitch ) {
    fill( palette.white );
  } else {
    fill( palette.mainColorPrimary );
  }
  
  t = ""+passInputString;
  text(t, width/2-textWidth(t)/2, height/2+260);


  if ( user != null && user.isVerified() ) {
    
    fill(palette.geilOrange);
    t = "registered and logged in";
    text(t, width/2-textWidth(t)/2, height/2+370);
    t = "hit [enter] to go racing";
    if ( key == ENTER && keyPressed && frameCount > enterCooldownFrame) {
      skidLayer = createGraphics(width, height);
      //gameState = State.RACE;
      gameState = State.LOADING;
    }
  }
    
  if( user == null || !user.isVerified() ) {
    if ( currentUserNameExists ) {
      if ( passInputString!= null && !passInputString.isEmpty() ) {
        t = "hit [enter] to login";
        if ( key == ENTER && keyPressed ) {
          user = new User(userInputString, passInputString);
          enterCooldownFrame = frameCount + 100;
        }
      } else {
        t = "username taken";
      }
    } else if ( !currentUserNameExists && passInputString!= null && !passInputString.isEmpty() ) {
      t = "hit [enter] to register user";

      if ( key == ENTER && keyPressed ) {
        
        enterCooldownFrame = frameCount + 100;
        if ( registerUser( userInputString, passInputString) ) {
          user = new User(userInputString, passInputString);
        }
      }
    }
  }

  fill( 200 );
  text(t, width/2-textWidth(t)/2, height/2+340);



  popStyle();
}






public void introLoop() {


  if ( !boomPlayed ) {
    playBoom();
    boomPlayed = true;
    playStatic(true);
  }

  float titleSize = 150;
  String title = "ImmoRally";

  skidLayer.beginDraw();
  skidLayer.pushStyle();
  skidLayer.fill(palette.black);
  skidLayer.textFont(font);
  skidLayer.fill(palette.mainColorPrimary);
  skidLayer.textSize(titleSize);
  skidLayer.text( title, width/2 - skidLayer.textWidth(title)/2, height/2 );
  skidLayer.endDraw();
  skidLayer.popStyle();


  updateSkidLayer();
  image(skidLayer, 0, 0);

  pushStyle();

  textFont(font);
  fill(palette.mainColorPrimary, opa);
  if ( opa > 1 ) {
    opa-=0.11;
  }
  textSize(titleSize);
  text( title, 3+width/2 - textWidth(title)/2, height/2 );

  if( gameState == State.INTRO ) {
    if ( frameCount > 900 ) {
      if ( opa2 < 1 ) opa2 = 1;
      String pressPlay = "press key to play";
      textSize(30);
      fill(palette.darkGlow, opa2 );
      text(pressPlay, width/2 - textWidth(pressPlay)/2, height/2 + 100 );
      //text(pressPlay, mouseX,mouseY );
      opa2 += 0.08;
    }  
  } else {
    userLoginLoop();
  }
  
  popStyle();

  int k = 0+key;
  //println(k);
  if ( k != 0 ) {
    anyKeyPressed = true;
    gameState = State.USER_LOGIN;
  }
}


public void loadingLoop() {
  
  String gens = "loading..."; //<>//
  textSize(40);
  fill(palette.mainColorSecondary);
  text(gens, width/2 -textWidth(gens)/2, height/2);
  
  if( isAudioInitialized ) {
    gameState = State.RACE;
  }
}
