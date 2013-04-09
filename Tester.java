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
    System.out.println(
      testIfThenElse.gTest() == 42 ? "ok 11" : "not ok 11"
    );

    Attribute testAttribute = new Attribute();
    System.out.println(
      testAttribute.a == 0 ? "ok 12" : "not ok 12"
    );
    System.out.println(
      testAttribute.aTest == 42 ? "ok 13" : "not ok 13"
    );
    System.out.println(
      testAttribute.cTest() == -7 ? "ok 14" : "not ok 14"
    );

    Loop testLoop = new Loop();
    System.out.println(
      testLoop.aTest() == 42 ? "ok 15" : "not ok 15"
    );
    System.out.println(
      testLoop.bTest() == -7 ? "ok 16" : "not ok 16"
    );
    System.out.println(
      testLoop.cTest() == 7 ? "ok 17" : "not ok 17"
    );
    System.out.println(
      testLoop.dTest() == 42 ? "ok 18" : "not ok 18"
    );
    System.out.println(
      testLoop.eTest() == 42 ? "ok 19" : "not ok 19"
    );
    System.out.println(
      testLoop.fTest() == 42 ? "ok 20" : "not ok 20"
    );
    Array testArray = new Array();
    System.out.println(
      testArray.bTest[0] == 42 ? "ok 21" : "not ok 21"
    );
    System.out.println(
      testArray.dTest() == 42 ? "ok 22" : "not ok 22"
    );
    System.out.println(
      testArray.eTest()[0] == 42 ? "ok 23" : "not ok 23"
    );
    System.out.println(
      testArray.fTest() == 42 ? "ok 24" : "not ok 24"
    );
    System.out.println(
      testArray.gTest() == 42 ? "ok 25" : "not ok 25"
    );
    System.out.println(
      testArray.hTest( testArray.bTest ) == 42 ? "ok 26" : "not ok 26"
    );

    Loop_Foreach testLoop_Foreach = new Loop_Foreach();
    System.out.println(
      testLoop_Foreach.aTest() == 4 ? "ok 27" : "not ok 27"
    );
  }
}
