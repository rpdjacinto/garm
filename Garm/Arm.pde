class Arm {
  ArmRotator rotator;
  ArmLink[] links;
  ArmGripper gripper;
  
  
  Arm( int[] lengths ) {
    this.rotator = new ArmRotator();
    this.links = new ArmLink[3];
    this.gripper = new ArmGripper();
    for( int i = 0; i < this.links.length; i++ ) this.links[i] = new ArmLink( lengths[i] );
  }
  
  void update( int rotatorAngle, int x, int y, float wristAngle, int grip ) {
    
    int a = this.links[1].length;
    int b = this.links[0].length;
    float c = min( sqrt(x*x+y*y), a + b );
     
    float B = acos( ( b*b - a*a - c*c ) / ( -2*a*c) );
    float C = constrain( acos( (c*c - a*a - b*b ) / (-2*a*b) ), radians(30), radians(330) );
     
    float D = atan2(y,x);
    float E = D + B + C - PI;
    
    this.rotator.update( rotatorAngle );
    this.links[0].update( E );
    this.links[1].update( D + B );
    this.links[2].update( links[1].angle + wristAngle );
    this.gripper.update( grip );
    
    float angle0 = constrain( (-( E - HALF_PI ) > 0 ? -( E - HALF_PI ) : -( E - HALF_PI ) + TWO_PI), radians(30), radians(330) );
    
    this.links[0].servoValue = (int) map( degrees( angle0 ) - 30, 0, 300, 0, 1023 );
    this.links[1].servoValue = (int) map( degrees(C) - 30, 0, 300, 0, 1023 );
    this.links[2].servoValue = (int) map( degrees( wristAngle ), 150, -150, 0, 1023 );
    
  }
  
  int getTotalLength() {
    int sum = 0;
    for( int i = 0; i < this.links.length - 1; i++ ) sum += links[i].length;
    return sum;
  }
  
}
