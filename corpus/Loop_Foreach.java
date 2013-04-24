class Loop_Foreach {
  public int aTest ( ) {
    int i = 0;
    int contents[] = { 0, 0, 0, 0 };
    for ( int content : contents )
      i++;
    return i;
  }
  public int bTest ( ) {
    int i = 0;
    int contents[] = { 0, 0, 0, 0 };
    for ( int content : contents ) {
      i++;
      i++;
    }
    return i;
  }
/*
  public int bTest ( ) {
    int contents[] = { 0, 0, 0, 0 };
    foreach ( int i in contents )
  }
static void Main(string[] args) {    
    foreach (string s in args)        
        Console.WriteLine(s);
}
*/
}
