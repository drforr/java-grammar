class Loop {
  public int aTest ( ) {
    int i = 0;
    int j = 0;
    for ( j = 0 ; j < 42 ; j++ )
      i++;
    return i;
  }
  public int bTest ( ) {
    int i = 0;
    int j = 0;
    for ( j = 0 ; j < 7 ; j++ ) {
      i--;
    }
    return i;
  }
  public int cTest ( ) {
    int i = 0;
    for ( int j = 0 ; j < 7 ; j++ )
      i++;
    return i;
  }
/*
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
*/
}
