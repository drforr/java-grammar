package com.example.util;

public class ChristmasTree {
  private String name;
  private int tweakMe;
  private boolean closed = false;
  private boolean[] doors;
  private int door = 3;
  private int[] characters = { 0x48, 0x65, 0x6c, 0x6c, 0x6f };
  private int[][] strings = {
    { 0x48, 0x65, 0x6c, 0x6c, 0x6f }, /* "Hello" */
    { 0x57, 0x6f, 0x72, 0x6c, 0x64 } /* "World" */
  };

  private ChristmasTree ( ) {
    java.util.Random generator =
      new java.util.Random ( 3 );
    doors[door] = true;
    doors[door] = doors[1];
    tweakMe = 3;
    tweakMe = 7 + 2;
    tweakMe += 3 >> (2 * characters[0]);

    if ( closed )
      stuff();
  }
  public static void mpm(Object result, Object M0, Object M1) {
    if (result instanceof int[])
      vpv((int[])result, (int[])M0, (int[])M1);
    else if (result instanceof double[])
      vpv((double[])result, (double[])M0, (double[])M1);
    else {
      Object resultArray[] = (Object[])result;
      Object M0Array[] = (Object[])M0;
      Object M1Array[] = (Object[])M1;
      for (int i = (resultArray.length)-1; (i) >= 0; --i)
        mpm(resultArray[i], M0Array[i], M1Array[i]);
    }
  } // mpm

  public void stuff ( int foo ) throws Exception {
    try {
      stuff(1);
    }
    catch ( Exception e ) {
      stuff(2);
      return;
    }
    synchronized ( 1 == 1 ) {
      return;
    }
  }

  public int count ( int in[] ) {
    float out[] = new float[in.length];
    for ( int i = 0; i < 10; i++ )
      System.out.println( "Hello" );
    for ( int i = 0; i < 10; i++ )
      if ( i == 2 )
        stuff( 3 );
    return 3;
  }
  public void counts ( int in[] ) {
    for ( int i = 0; i < 10; i++ ) {
      stuff(i);
      stuff((int)i);
      System.out.println( "Hello" );
    }

    while ( false ) {
      stuff(0);
    }
  }
  public int[][] transpose ( int in[][] ) {
    int dim = 3;
    if (!(in.length  >= dim - 1))
      throw new Error ( "vectors.length >= dim-1" + "" );
  }

  public void dotProduct ( ) {
    int dim;
    switch( dim ) {
      case 0: System.out.println( "foo" ); break;
      case 1: System.out.println( "bar" ); return;
      default: System.out.println( "default" ); break;
    }
  }

  /* Thoroughly, if not quite exhaustively, test if-then-else branches. */

  /* On if-else-if, run the blocks in binary order. */

  public void _if_else_if_else ( ) { /* "000" */
    if ( 1 == 1 )
      name = "a";
    else if ( 2 == 2 )
      name = "b";
    else
      name = "c";
  }
  public void _if_else_if_elseB ( ) { /* "001" */
    if ( 1 == 1 )
      name = "a";
    else if ( 2 == 2 )
      name = "b";
    else {
      name = "c";
    }
  }
  public void _if_else_ifB_else ( ) { /* "010" */
    if ( 1 == 1 )
      name = "a";
    else if ( 2 == 2 ) {
      name = "b";
    }
    else
      name = "c";
  }
  public void _if_else_ifB_elseB ( ) { /* "011" */
    if ( 1 == 1 )
      name = "a";
    else if ( 2 == 2 ) {
      name = "b";
    }
    else {
      name = "c";
    }
  }
  public void _ifB_else_if_else ( ) { /* "100" */
    if ( 1 == 1 ) {
      name = "a";
    }
    else if ( 2 == 2 )
      name = "b";
    else
      name = "c";
  }
  public void _ifB_else_if_elseB ( ) { /* "101" */
    if ( 1 == 1 ) {
      name = "a";
    }
    else if ( 2 == 2 )
      name = "b";
    else {
      name = "c";
    }
  }
  public void _ifB_else_ifB_else ( ) { /* "110" */
    if ( 1 == 1 ) {
      name = "a";
    }
    else if ( 2 == 2 ) {
      name = "b";
    }
    else
      name = "c";
  }
  public void _ifB_else_ifB_elseB ( ) { /* "111" */
    if ( 1 == 1 ) {
      name = "a";
    }
    else if ( 2 == 2 ) {
      name = "b";
    }
    else {
      name = "c";
    }
  }

  public class Foo extends ChristmasTree {
    public Foo ( ) { }
    protected void foo ( ) {
      do {
        int i = 0;
      } while( false );
    }
  }

  public class Bar {
    public Bar ( ) { }
  }
//  public class Baz implements Bar {
//    public Baz ( ) { }
//  }
/*
  public interface Comparator {
    int compare ( Object a, Object b );
  }
  public class Bar implements Baz {
    public Bar ( ) { }
    protected void foo ( void ) {
      do {
        int i = 0;
      } while( false );
    }
  }
*/
}

/*

// 'extends Extender' - Was broken.
// 'implements Implementation' - Was also broken.
public final class ChristmasTree extends Extender implements Implementation
{
    // attribute with initializer - still broken.
    private ChristmasTree() {} // uninstantiatable
    public static float [] doubleToFloat ( double in[] ) {
      // This breaks when attribute with initializer is fixed.
      float out[] = new float [in.length];
      int i;
      // Different initializers, blows some tests.
      for(i = 0; ( i ) < ( vLen ); ++i )
        vpsxv( result, result, in[i], out[i] );
      return out;
    }
}
*/

