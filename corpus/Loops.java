class Loops {
  public void a ( ) {
    int i;
    for ( i = 0; i < 10; i++ )
      stuff();
    for ( i = 0; i < 10; i++ ) {
      stuff();
    }
  }
  public void b ( ) {
    for ( int i = 0; i < 10; i++ )
      stuff();
    for ( int i = 0; i < 10; i++ ) {
      stuffInt(i);
    }
  }
  public void c ( ) {
    int i = 10, j = 10;
    while ( i-- > 0 )
      stuff();
    while ( j-- > 0 ) {
      stuff();
    }
  }
  public void d ( ) {
    int i = 10;
    do stuff();
    while ( i-- > 0 );
  }
  public void stuff ( ) {
  }
  public void stuffInt ( int i ) {
  }
}
