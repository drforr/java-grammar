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
    System.out.println( ( testMethod.aTest() == 42 ? "" : "not " ) + "ok 2" );
    System.out.println( ( testMethod.cTest() == -7 ? "" : "not " ) + "ok 3" );
    System.out.println( ( testMethod.dTest() == 42 ? "" : "not " ) + "ok 4" );

    IfThenElse testIfThenElse = new IfThenElse();
    System.out.println(
      ( testIfThenElse.aTest() == 42 ? "" : "not " ) + "ok 5"
    );
    System.out.println(
      ( testIfThenElse.bTest() == 42 ? "" : "not " ) + "ok 6"
    );
    System.out.println(
      ( testIfThenElse.cTest() == 42 ? "" : "not " ) + "ok 7"
    );
    System.out.println(
      ( testIfThenElse.dTest() == 42 ? "" : "not " ) + "ok 8"
    );
    System.out.println(
      ( testIfThenElse.eTest() == 42 ? "" : "not " ) + "ok 9"
    );
    System.out.println(
      ( testIfThenElse.fTest() == 42 ? "" : "not " ) + "ok 10"
    );
    System.out.println(
      ( testIfThenElse.gTest() == 42 ? "" : "not " ) + "ok 11"
    );

    Attribute testAttribute = new Attribute();
    System.out.println(
      ( testAttribute.a == 0 ? "" : "not " ) + "ok 12"
    );
    System.out.println(
      ( testAttribute.aTest == 42 ? "" : "not " ) + "ok 13"
    );
    System.out.println(
      ( testAttribute.cTest() == -7 ? "" : "not " ) + "ok 14"
    );
    System.out.println(
      ( testAttribute.dTest == "foo" ? "" : "not " ) + "ok 15"
    );
    System.out.println(
      ( testAttribute.eTest == "foo" ? "" : "not " ) + "ok 16"
    );

    Loop testLoop = new Loop();
    System.out.println(
      ( testLoop.aTest() == 42 ? "" : "not " ) + "ok 17"
    );
    System.out.println(
      ( testLoop.bTest() == -7 ? "" : "not " ) + "ok 18"
    );
    System.out.println(
      ( testLoop.cTest() == 7 ? "" : "not " ) + "ok 19"
    );
    System.out.println(
      ( testLoop.dTest() == 42 ? "" : "not " ) + "ok 20"
    );
    System.out.println(
      ( testLoop.eTest() == 42 ? "" : "not " ) + "ok 21"
    );
    System.out.println(
      ( testLoop.fTest() == 42 ? "" : "not " ) + "ok 22"
    );

    Array testArray = new Array();
    System.out.println(
      ( testArray.bTest[0] == 42 ? "" : "not " ) + "ok 23"
    );
    System.out.println(
      ( testArray.dTest() == 42 ? "" : "not " ) + "ok 23"
    );
    System.out.println(
      ( testArray.eTest()[0] == 42 ? "" : "not " ) + "ok 24"
    );
    System.out.println(
      ( testArray.fTest() == 42 ? "" : "not " ) + "ok 25"
    );
    System.out.println(
      ( testArray.gTest() == 42 ? "" : "not " ) + "ok 26"
    );
    System.out.println(
      ( testArray.hTest( testArray.bTest ) == 42 ? "" : "not " ) + "ok 27"
    );
    System.out.println(
      ( testArray.iTest( ) == 42 ? "" : "not " ) + "ok 28"
    );
    System.out.println(
      ( testArray.jTest( ) == 42 ? "" : "not " ) + "ok 29"
    );
    System.out.println(
      ( testArray.kTest[0] == "foo" ? "" : "not " ) + "ok 30"
    );

    Loop_Foreach testLoop_Foreach = new Loop_Foreach();
    System.out.println(
      ( testLoop_Foreach.aTest() == 4 ? "" : "not " ) + "ok 31"
    );
  }
}
