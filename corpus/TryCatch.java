class TryCatch {
  public int aTest ( ) {
    int i = 41;
    try {
      i++;
    }
    catch ( Exception e ) {
      i--;
    };
    return i;
  }
}
