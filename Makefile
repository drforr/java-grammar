all:
	antlr3 Java.g
	antlr3 JavaTreeParser.g
	javac JavaLexer.java JavaParser.java JavaTreeParser.java Test.java

test:	Test.class
	java Test < corpus/IfThenElse.java > IfThenElse.java
	javac IfThenElse.java
	java Test < corpus/Loops.java > Loops.java
	javac Loops.java

clean:
	rm -f *.class *.tokens JavaLexer* JavaParser* JavaTreeParser.java
