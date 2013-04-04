all:
	antlr3 Java.g
	antlr3 JavaTreeParser.g
	javac JavaLexer.java JavaParser.java JavaTreeParser.java Statement.java Converter.java

conversion:
	java Converter < corpus/Class.java > Class.java
	java Converter < corpus/Method.java > Method.java
	java Converter < corpus/IfThenElse.java > IfThenElse.java
	

test:	Class.java Method.java IfThenElse.java Tester.java
	javac Class.java Tester.java
	java Tester

clean:
	rm -f *.class *.tokens JavaLexer* JavaParser* JavaTreeParser.java Class.java Attribute.java
