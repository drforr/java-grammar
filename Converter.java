import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

public class Converter {
  public static void main(String[] args) throws Exception {
    ANTLRInputStream input = new ANTLRInputStream(System.in);
    JavaLexer lexer = new JavaLexer(input);
    CommonTokenStream tokens = new CommonTokenStream(lexer);
    JavaParser parser = new JavaParser(tokens);
    CommonTree t = (CommonTree) parser.javaSource().getTree();

    CommonTreeNodeStream nodes =
      new CommonTreeNodeStream(t);
    JavaTreeParser evaluator =
      new JavaTreeParser(nodes, parser.functionDefinitions);
    if ( args.length > 0 )
      if ( args[0] != null )
        evaluator.cover = true;
    System.out.println( evaluator.javaSource() );
  }
}
