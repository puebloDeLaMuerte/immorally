boolean boomPlayed = false;
float opa = 255;
float opa2 = 0;

int enterCooldownFrame = -1;

public void userLoginLoop() {

  pushStyle();
  textSize(20);

  String t = "user login";
  text(t, width/2-textWidth(t)/2, height/2);

  if ( user == null ) {
    user = userFromFile( dataPath("user.txt") );
    userInputString = user.userName;
  } else if ( !user.isVerified() ) {
    t = "login error: " + user.latestServerResponse;
    //text(t, width/2-textWidth(t)/2, height/2+40);
  }

  // username title

  if ( userPassSwitch && frameCount%60 < 30 ) {
    fill( palette.mainColorPrimary );
  } else fill( palette.mainColorSecondary);
  t = "username:";
  text(t, width/2-textWidth(t)/2, height/2+80);


  // the user input string for username

  //println(currentUserNameExists);

  if ( currentUserNameExists ) { // && (passInputString == null || passInputString == "") ) {
    fill( palette.destruction );
  } else {
    fill( palette.mainColorPrimary );
  }
  textSize(25);
  t = ""+userInputString;
  text(t, width/2-textWidth(t)/2, height/2+120);

  triggerUsernameCheck(userInputString);


  // password title

  if ( !userPassSwitch && frameCount%60 < 30 ) {
    fill( palette.mainColorPrimary );
  } else fill( palette.mainColorSecondary );
  textSize(20);
  t = "password:";
  text(t, width/2-textWidth(t)/2, height/2+160);



  // the user input string for password

  textSize(25);
  fill( palette.mainColorPrimary );
  t = ""+passInputString;
  text(t, width/2-textWidth(t)/2, height/2+200);


  if ( user != null && user.isVerified() ) {
    
    fill(palette.geilOrange);
    t = "registered and logged in";
    text(t, width/2-textWidth(t)/2, height/2+250);
    t = "hit [enter] to go racing";
    if ( key == ENTER && keyPressed && frameCount > enterCooldownFrame) {
      gameState = State.RACE;
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
  text(t, width/2-textWidth(t)/2, height/2+280);



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


  if ( frameCount > 900 ) {
    if ( opa2 < 1 ) opa2 = 1;
    String pressPlay = "press key to play";
    textSize(30);
    fill(palette.darkGlow, opa2 );
    text(pressPlay, width/2 - textWidth(pressPlay)/2, height/2 + 100 );
    //text(pressPlay, mouseX,mouseY );
    opa2 += 0.08;
  }
  popStyle();

  int k = 0+key;
  //println(k);
  if ( k != 0 ) {
    skidLayer = createGraphics(width, height);
    gameState = State.USER_LOGIN;
  }
}
