class Switch {
  public int aTest ( ) {
    int i = 2;
    int j = 42;
    switch ( i ) {
      case 0: ++j; return j;
      case 1: ++j; break;
      case 2: return j;
      default: return -2;
    }
    return -1;
  }
}
