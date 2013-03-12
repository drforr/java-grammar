/*
import org.antlr.runtime.*;
 
public class Test {
    public static void main(String[] args) throws Exception {
        ANTLRInputStream input = new ANTLRInputStream(System.in);
        JavaLexer lexer = new JavaLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        JavaParser parser = new JavaParser(tokens);
        parser.javaSource();
    }
}
*/

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;

public class Test {
    public static void main(String[] args) throws Exception {
        ANTLRInputStream input = new ANTLRInputStream(System.in);
        JavaLexer lexer = new JavaLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        JavaParser parser = new JavaParser(tokens);
        CommonTree t  = (CommonTree) parser.javaSource().getTree();

        CommonTreeNodeStream nodes =
		new CommonTreeNodeStream(t);
        JavaTreeParser evaluator =
		new JavaTreeParser(nodes, parser.functionDefinitions);
        evaluator.javaSource();
    }
}