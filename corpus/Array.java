class Array {
  int aTest[];
  int bTest[] = { 42, 43, 44, 45 };
  int cTest[] = new int[1];
  public int dTest ( ) {
    return bTest[0];
  }
  public int[] eTest ( ) {
    return bTest;
  }
  public int fTest ( ) {
    bTest[1] = 42;
    return bTest[1];
  }
  public int gTest ( ) {
    int bTest[] = { 42, 43, 44, 45 };
    return bTest[0];
  }
  public int hTest ( int[] a ) {
    return a[0];
  }
  public int iTest ( ) {
    cTest[0] = 42;
    return cTest[0];
  }
}
