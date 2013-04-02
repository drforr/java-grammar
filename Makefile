all:
	antlr3 Java.g
	antlr3 JavaTreeParser.g
	javac JavaLexer.java JavaParser.java JavaTreeParser.java Statement.java Converter.java

Class.java:
	java Converter < corpus/Class.java > Class.java
Attribute.java: corpus/Attribute.java
	java Converter < corpus/Attribute.java > Attribute.java
	

test:	Class.java Attribute.java Tester.java
	javac Class.java Attribute.java Tester.java
	java Tester

clean:
	rm -f *.class *.tokens JavaLexer* JavaParser* JavaTreeParser.java Class.java Attribute.java
