package com.donhatchsw.util;

// 'extends Extender' - Was broken.
// 'implements Implementation' - Was also broken.
public final class ChristmasTree extends Extender implements Implementation
{
    // attribute with initializer - still broken.
    private boolean closed = true;
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
