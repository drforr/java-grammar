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
    System.out.println( testMethod.dTest() == 42 ? "ok 4" : "not ok 4" );

    IfThenElse testIfThenElse = new IfThenElse();
    System.out.println(
      testIfThenElse.aTest() == 42 ? "ok 5" : "not ok 5"
    );
    System.out.println(
      testIfThenElse.bTest() == 42 ? "ok 6" : "not ok 6"
    );
    System.out.println(
      testIfThenElse.cTest() == 42 ? "ok 7" : "not ok 7"
    );
    System.out.println(
      testIfThenElse.dTest() == 42 ? "ok 8" : "not ok 8"
    );
    System.out.println(
      testIfThenElse.eTest() == 42 ? "ok 9" : "not ok 9"
    );
    System.out.println(
      testIfThenElse.fTest() == 42 ? "ok 10" : "not ok 10"
    );

    Attribute testAttribute = new Attribute();
    System.out.println(
      testAttribute.aTest == 42 ? "ok 11" : "not ok 11"
    );
    System.out.println(
      testAttribute.cTest() == -7 ? "ok 12" : "not ok 12"
    );
  }
}
