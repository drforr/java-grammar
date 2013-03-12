all:
	antlr3 Java.g
	antlr3 JavaTreeParser.g
	javac JavaLexer.java JavaParser.java JavaTreeParser.java Test.java

clean:
	rm -f *.class JavaLexer* JavaParser* Java.tokens JavaTreeParser.tokens