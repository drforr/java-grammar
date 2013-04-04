//
// Test creation of methods.
//
// Public methods can of course be called by our test class, but private
// methods are another matter. We do need to make sure they're created, so
// we create them and a public method to call them.
//
class Method {
  public int aTest ( ) {
    return 42;
  }
  private int bTest ( ) {
    return -7;
  }
  public int cTest ( ) {
    return bTest();
  }
  public int dTest ( ) {
    int i = 41;
    return ++i;
  }
}
