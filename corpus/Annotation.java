class Annotation {
  @myAnnotation
  public int aTest ( ) {
    return 42;
  }
  public @interface myAnnotation {
  }
  @light(true)
  public @interface light {
    boolean value() default false;
  }
}
