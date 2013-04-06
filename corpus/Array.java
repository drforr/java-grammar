class Array {
  int aTest[];
  int bTest[] = { 42, 43, 44, 45 };
  public int cTest ( ) {
    return bTest[0];
  }
  public int[] dTest ( ) {
    return bTest;
  }
  public int eTest ( ) {
    bTest[1] = 42;
    return bTest[1];
  }
  public int fTest ( ) {
    int bTest[] = { 42, 43, 44, 45 };
    return bTest[0];
  }
  public int gTest ( int[] a ) {
    return a[0];
  }
}
