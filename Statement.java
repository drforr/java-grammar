class Statement {
  public String string;
  public boolean isBlock;
  public int id = 0;
  public Statement ( ) {
  }
  public Statement ( int id ) {
    this.id = id;
    this.string = "";
  }
  public Statement ( int id, String string ) {
    this.id = id;
    this.string = string;
  }
}
