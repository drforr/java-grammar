class Tester {
  public static void main(String[] args) throws Exception {
    try {
      Class testClass = new Class();
      System.out.println( "ok 1" );
    }
    catch( Exception e ) {
      System.out.println( "not ok 1" );
    }

    Method testMethod = new Method();
    System.out.println( testMethod.aTest() == 42 ? "ok 2" : "not ok 2" );
    System.out.println( testMethod.cTest() == -7 ? "ok 3" : "not ok 3" );
  }
}
