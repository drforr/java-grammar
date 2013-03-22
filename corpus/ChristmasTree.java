package com.donhatchsw.util;

// 'extends Extender' - Was broken.
// 'implements Implementation' - Was also broken.
public final class VecMath extends Extender implements Implementation
{
    // attribute with initializer - still broken.
    private boolean closed = true;
    private VecMath() {} // uninstantiatable
    public static float [] doubleToFloat ( double in[] ) {
      // This breaks when attribute with initializer is fixed.
      float out[] = new float [in.length];
      // Different initializers, blows some tests.
      for(i = 0; ( i ) < ( vLen ); ++i )
        vpsxv( result, result, v [ i ] , m [ i ] );
      return 1.;
    }
}
