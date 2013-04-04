class IfThenElse {
  public int aTest ( ) {
    int i = 40;
    if ( ++i == 41 )
      return ++i;
    return 0;
  }
  public int bTest ( ) {
    int i = 40;
    if ( ++i == 41 ) {
      return ++i;
    }
    return 0;
  }
  public int cTest ( ) {
    int i = 40;
    if ( ++i == 40 )
      return --i;
    else
      return ++i;
  }
  public int dTest ( ) {
    int i = 40;
    if ( ++i == 40 ) {
      return --i;
    } else
      return ++i;
  }
  public int eTest ( ) {
    int i = 40;
    if ( ++i == 40 )
      return --i;
    else {
      return ++i;
    }
  }
  public int fTest ( ) {
    int i = 40;
    if ( ++i == 40 ) {
      return --i;
    } else {
      return ++i;
    }
  }
}
