class Loop_Foreach {
  public int aTest ( ) {
    int i = 0;
    int contents[] = { 0, 0, 0, 0 };
    for ( int content : contents )
      i++;
    return i;
  }
}
