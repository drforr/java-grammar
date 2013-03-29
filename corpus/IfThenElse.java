class IfThenElse {
  public void a ( ) {
    if ( 1 == 1 )
      stuff();
    if ( 1 == 1 ) {
      stuffInt(2);
    }
  }
  public void b ( ) {
    if ( 1 == 1 )
      stuff();
    else
      stuff();
    if ( 1 == 1 ) {
      stuff();
    }
    else
      stuff();
    if ( 1 == 1 )
      stuff();
    else {
      stuff();
    }
    if ( 1 == 1 ) {
      stuff();
    } else {
      stuff();
    }
  }
  public void c ( ) {
    if ( 1 == 1 )
      stuff();
    else if ( 2 == 2 )
      stuff();
    if ( 1 == 1 ) {
      stuff();
    } else if ( 2 == 2 )
      stuff();
    if ( 1 == 1 )
      stuff();
    else if ( 2 == 2 ) {
      stuff();
    }
    if ( 1 == 1 ) {
      stuff();
    } else if ( 2 == 2 ) {
      stuff();
    }
  }
  public void stuff ( ) {
  }
  public void stuffInt ( int i ) {
  }
}
