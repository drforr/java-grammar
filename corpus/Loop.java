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
  public int dTest ( ) {
    int i = 0;
    int j = 0;
    do
      i++;
    while ( j++ < 41 );
    return i;
  }
  public int eTest ( ) {
    int i = 0;
    int j = 0;
    do {
      i++;
    } while ( j++ < 41 );
    return i;
  }
}
