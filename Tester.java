class Tester {
  public static void main(String[] args) throws Exception {
    try {
      Class testClass = new Class();
      System.out.println( "ok 1" );
    }
    catch( Exception e ) {
      System.out.println( "not ok 1" );
    }

    Attribute testAttribute = new Attribute();
    System.out.println( testAttribute.aTest == 42 ? "ok 2" : "not ok 2" );
    System.out.println( testAttribute.bTest == -7 ? "ok 3" : "not ok 3" );
  }
}
