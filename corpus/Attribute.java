class Attribute {
  public int a;
  public int aTest = 42;
  private int bTest = -7;
  public int cTest ( ) {
    return bTest;
  }
  static final String dTest = "foo";
  public static final String eTest = "foo";
  public Attribute ( ) {
  }
  public Attribute ( int i ) {
    this.a = i;
  }
}
