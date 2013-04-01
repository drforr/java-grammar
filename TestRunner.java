class TestRunner {
  public static void main(String[] args) throws Exception {
    IfThenElse testA = new IfThenElse( );
    testA.aTest = 0;
    System.out.println( ( testA.aTest == 0 ? "" : "not " ) + "ok 1" );

    testA.aTest = 0;
    testA.a();
    System.out.println( ( testA.aTest == 2 ? "" : "not " ) + "ok 2" );

    testA.aTest = 0;
    testA.b();
    System.out.println( ( testA.aTest == 2 ? "" : "not " ) + "ok 3" );

    testA.aTest = 0;
    testA.c();
    System.out.println( ( testA.aTest == 2 ? "" : "not " ) + "ok 4" );

    testA.aTest = 0;
    testA.d();
    System.out.println( ( testA.aTest == 2 ? "" : "not " ) + "ok 5" );

    testA.aTest = 0;
    testA.e();
    System.out.println( ( testA.aTest == 2 ? "" : "not " ) + "ok 6" );

    testA.aTest = 0;
    testA.f();
    System.out.println( ( testA.aTest == 2 ? "" : "not " ) + "ok 7" );
  }
}
