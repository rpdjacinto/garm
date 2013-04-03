class ControlThread extends Thread {
  String id;
  int wait;
  boolean running;
  boolean armControlMode;
  boolean controllerMode = false;
  
  ControlThread( String id, int wait ) {
    this.id = id;
    this.wait = wait;
  }
  
  void start() {
    if( !config.DEBUG_MODE ) xbox.plug( xbox.rightBumper, "switchMode", "ON_PRESS" );
    addMouseWheelListener(new MouseWheelListener() { 
      public void mouseWheelMoved(MouseWheelEvent mwe) { 
        mouseWheel(mwe.getWheelRotation());
    }});
    this.running = true;
    super.start();
  }
  
  void run() {
    while( running ) {
      if( this.armControlMode ) {
        if( this.controllerMode || !config.DEBUG_MODE ) {
          driveDisplay.drive.update( 0, 0 );
          armDisplay.targetX += 2*xbox.leftStick.getX();
          armDisplay.targetY += 2*xbox.leftStick.getY();
          armDisplay.grip = (int) map( xbox.rightTrigger.getValue(), -1, 0, 205, 512 );
          if( xbox.leftBumper.getValue() ) armDisplay.rotatorAngle = (int) constrain( armDisplay.rotatorAngle - 2*xbox.rightStick.getX(), 0, 1023 );
          else armDisplay.wristAngle = constrain( armDisplay.wristAngle += PI/120 * xbox.rightStick.getY(), -radians(150), radians(150) );
        } else {
          armDisplay.targetX = mouseX - armDisplay.x;
          armDisplay.targetY = mouseY - armDisplay.y;
          if( keyPressed && ( key == 'a' || key == 'A' ) ) armDisplay.rotatorAngle = (int) constrain( armDisplay.rotatorAngle + 3, 0, 1023 );
          if( keyPressed && ( key == 'd' || key == 'D' ) ) armDisplay.rotatorAngle = (int) constrain( armDisplay.rotatorAngle - 3, 0, 1023 );
        }
      } else if( !config.DEBUG_MODE ) driveDisplay.drive.update( xbox.leftStick.getX(), xbox.leftStick.getY() );
      
      println( armDisplay.targetX + "\t" + armDisplay.targetY );
      
      armDisplay.arm.update( armDisplay.rotatorAngle, armDisplay.targetX, armDisplay.targetY, armDisplay.wristAngle, armDisplay.grip );
      
      try {
        sleep((long)(wait));
      } catch (Exception e) {
      }
    }
  }
  
  void quit() {
    running = false;
    interrupt();
  }
  
  void mouseWheel( int delta ) {
    if( armControlMode && !this.controllerMode ) {
      if( mousePressed ) armDisplay.grip = constrain( armDisplay.grip += 20 * delta, 205, 512 );
      else armDisplay.wristAngle = constrain( armDisplay.wristAngle += PI/45 * delta, -radians(150), radians(150) );
      }
    } 
}


