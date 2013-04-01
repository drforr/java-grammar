class IfThenElse {
  public int aTest = 0;
  public void a ( ) { // if, statement
    if ( aTest++ == 0 )
      aTest++;
  }

  public void b ( ) { // if, block.
    if ( aTest++ == 0 ) {
      aTest++;
    }
  }

  public void c ( ) { // if, statement, else, statement
    if ( aTest++ == 0 )
      aTest++;
    else
      aTest = 99;
  }

  public void d ( ) { // if, block, else, statement
    if ( aTest++ == 0 ) {
      aTest++;
    } else
      aTest = 99;
  }

  public void e ( ) { // if, statement, else, block
    if ( aTest++ == 0 )
      aTest++;
    else {
      aTest = 99;
    }
  }

  public void f ( ) { // if, block, else, block
    if ( aTest++ == 0 ) {
      aTest++;
    } else {
      aTest = 99;
    }
  }
}
