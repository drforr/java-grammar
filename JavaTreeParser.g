/**
 * For more information see the head comment within the 'java.g' grammar file
 * that defines the input for this tree grammar.
 *
 * BSD licence
 * 
 * Copyright (c) 2007-2008 by HABELITZ Software Developments
 *
 * All rights reserved.
 * 
 * http://www.habelitz.com
 *
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY HABELITZ SOFTWARE DEVELOPMENTS ('HSD') ``AS IS'' 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL 'HSD' BE LIABLE FOR ANY DIRECT, INDIRECT, 
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
tree grammar JavaTreeParser;

options {
    backtrack = true; 
    memoize = true;
    tokenVocab = Java;
    ASTLabelType = CommonTree;
}

@header {
    import java.util.Map;
    import java.util.HashMap;
    import java.math.BigInteger;
}

// {{{ @treeparser::members

@treeparser::members {
    /** Points to functions tracked by tree builder. */
    private List<CommonTree> functionDefinitions;
    
    boolean mMessageCollectionEnabled = false;
    private boolean mHasErrors = false;
    List<String> mMessages;

    /** Set up an evaluator with a node stream; and a set of
     *  function definition ASTs.
     */
    public JavaTreeParser(CommonTreeNodeStream nodes,
                          List<CommonTree> functionDefinitions) {
        this(nodes);
        this.functionDefinitions = functionDefinitions;
    }

    /**
     *  Switches error message collection on or off.
     *
     * The standard destination for parser error messages is
     * <code>System.err</code>.
     * However, if <code>true</code> gets passed to this method this default
     * behaviour will be switched off and all error messages will be collected
     * instead of written to anywhere.
     *
     * The default value is <code>false</code>.
     *
     * @param pNewState <code>true</code> if error messages should be collected.
     */
    public void enableErrorMessageCollection(boolean pNewState) {
        mMessageCollectionEnabled = pNewState;
        if (mMessages == null && mMessageCollectionEnabled) {
            mMessages = new ArrayList<String>();
        }
    }
    
    /**
     *  Collects an error message or passes the error message to <code>
     *  super.emitErrorMessage(...)</code>.
     *
     *  The actual behaviour depends on whether collecting error messages
     *  has been enabled or not.
     *
     *  @param pMessage  The error message.
     */
     @Override
    public void emitErrorMessage(String pMessage) {
        if (mMessageCollectionEnabled) {
            mMessages.add(pMessage);
        } else {
            super.emitErrorMessage(pMessage);
        }
    }
    
    /**
     *  Returns collected error messages.
     *
     *  @return  A list holding collected error messages or <code>null</code> if
     *           collecting error messages hasn't been enabled. Of course, this
     *           list may be empty if no error message has been emited.
     */
    public List<String> getMessages() {
        return mMessages;
    }
    
    /**
     *  Tells if parsing a Java source has caused any error messages.
     *
     *  @return  <code>true</code> if parsing a Java source has caused at
     *           least one error message.
     */
    public boolean hasErrors() {
        return mHasErrors;
    }
}

// }}}

// Starting point for parsing a Java file.
javaSource returns [String value]
    : { $value = ""; }
    	^( JAVA_SOURCE
	   annotationList { $value += " " + $annotationList.value; }
	   ( packageDeclaration
	     { $value += " " + $packageDeclaration.value; } )?
	   ( importDeclaration
	     { $value += " " + $importDeclaration.value; } )*
	   ( typeDeclaration
	     { $value += " " + $typeDeclaration.value; } )* )
    ;

// {{{ packageDeclaration

packageDeclaration returns [String value]
    :   ^(PACKAGE qualifiedIdentifier)  
	{
		$value = $PACKAGE.text + " " +
			 $qualifiedIdentifier.value + ";";
	}
    ;

// }}}
    
importDeclaration returns [String value]
    :   ^(IMPORT STATIC? qualifiedIdentifier DOTSTAR?)
{
	$value = $IMPORT.text + " " +
		 ( $STATIC.text != null ?
		   $STATIC.text : "" ) + " " +
		 $qualifiedIdentifier.value + " " +
		 ( $DOTSTAR.text != null ?
		   $DOTSTAR.text : "" );
}
    ;
    
typeDeclaration returns [String value]
    :   ^(CLASS modifierList
	  IDENT genericTypeParameterList?
		extendsClause?
		implementsClause?
		classTopLevelScope)
{
	$value = $modifierList.value + " " +
		 $CLASS.text + " " +
		 $IDENT.text + " { " +
		 ( $genericTypeParameterList.value != null ?
		   $genericTypeParameterList.value : "" ) + " " +
		 ( $extendsClause.value != null ?
		   $extendsClause.value : "" ) + " " +
		 ( $implementsClause.value != null ?
		   $implementsClause.value : "" ) + " " +
		 $classTopLevelScope.value + " }";
$value += "\n";
}
    |   ^(INTERFACE modifierList
	      IDENT genericTypeParameterList?
	  	    extendsClause?
		    interfaceTopLevelScope)
{
	$value = "{{typeDeclaration[2] " +
		 $INTERFACE.text + " " +
		 $modifierList.value + " " +
	         $IDENT.text + " " +
		 ( $genericTypeParameterList.value != null ?
		   $genericTypeParameterList.value : "" ) + " " +
		 ( $extendsClause.value != null ?
		   $extendsClause.value : "" ) + " " +
		 $interfaceTopLevelScope.value + "}}";
}
    |   ^(ENUM modifierList
	 IDENT implementsClause?
	       enumTopLevelScope)
{
	$value = "{{typeDeclaration[3] " +
		 $ENUM.text + " " +
		 $modifierList.value + " " +
	 	 $IDENT.text + " " +
		 ( $implementsClause.value != null ?
		   $implementsClause.value : "" ) + " " +
		 $enumTopLevelScope.value + "}}";
}
    |    ^(AT modifierList
	IDENT annotationTopLevelScope)
{
	$value = "{{typeDeclaration[3] " +
		 $AT.text + " " +
		 $modifierList.value + " " +
		 $IDENT.text + " " +
		 $annotationTopLevelScope.value + "}}";
}
    ;

extendsClause returns [String value] // actually 'type' for classes and 'type+' for interfaces, but this has 
              // been resolved by the parser grammar.
    :	{ $value = "{{extendsClause"; }
   	^( EXTENDS_CLAUSE
	   ( type
	     { $value += " " + $type.value; } )+ )
	{ $value += "}}"; }
    ;
    
implementsClause returns [String value]
    :	{ $value = "{{implementsClause"; }
   	^( IMPLEMENTS_CLAUSE ( type { $value += " " + $type.value; } )+ )
	{ $value += "}}"; }
    ;
        
genericTypeParameterList returns [String value]
    :	{ $value = "{{genericTypeParameterList"; }
   	^( GENERIC_TYPE_PARAM_LIST
	   ( genericTypeParameter
	     { $value += " " + $genericTypeParameter.value; } )+ )
	{ $value += "}}"; }
    ;

genericTypeParameter returns [String value]
    :   ^(IDENT bound?)
{
	$value = "{{genericTypeParameter " +
		  $IDENT.text + " " +
		  ( $bound.value != null ?
		    $bound.value : "" ) + "}}";
}
    ;
        
bound returns [String value]
    :	{ $value = "{{bound"; }
   	^( EXTENDS_BOUND_LIST
	   ( type { $value += " " + $type.value; } )+ )
	{ $value += "}}"; }
    ;

enumTopLevelScope returns [String value]
    : { $value = "{{enumTopLevelScope"; }
      ^( ENUM_TOP_LEVEL_SCOPE { $value += " " + $ENUM_TOP_LEVEL_SCOPE.text; }
	 ( enumConstant { $value += " " + $enumConstant.value; } )+
	 ( classTopLevelScope { $value += " " + $classTopLevelScope.value; } )? )
    ;
    
enumConstant returns [String value]
    :   ^(IDENT annotationList arguments? classTopLevelScope?)
{
	$value = "{{enumConstant " +
		 $IDENT.text + " " +
		 $annotationList.value + " " +
		 ( $arguments.value != null ?
		   $arguments.value : "" ) + " " +
		 ( $classTopLevelScope.value != null ?
		   $classTopLevelScope.value : "" ) + "}}";
}
    ;
    
    
classTopLevelScope returns [String value]
    :	{ $value = "{{classTopLevelScope"; }
   	^( CLASS_TOP_LEVEL_SCOPE
	   ( classScopeDeclarations
	     { $value += " " + $classScopeDeclarations.value; } )+ )
	{ $value += "}}"; }
    ;
    
classScopeDeclarations returns [String value]
    :   ^(CLASS_INSTANCE_INITIALIZER block)
	{
		$value = $block.value;
	}
    |   ^(CLASS_STATIC_INITIALIZER block)
	{
		$value = $block.value;
	}
    |   ^(FUNCTION_METHOD_DECL modifierList
			       genericTypeParameterList?
			       type
			 IDENT formalParameterList
			       arrayDeclaratorList?
			       throwsClause?
			       block?)
{
	$value = $modifierList.value + " " +
		 ( $genericTypeParameterList.value != null ?
		   $genericTypeParameterList.value : "" ) + " " +
		 $type.value + " " +
		 $IDENT.text + " " +
		 $formalParameterList.value + " " +
		 ( $arrayDeclaratorList.value != null ?
		   $arrayDeclaratorList.value : "" ) + " " +
		 ( $throwsClause.value != null ?
		   $throwsClause.value : "" ) + " " +
		 ( $block.value != null ? $block.value : "" );
}
    |   ^(VOID_METHOD_DECL modifierList
			   genericTypeParameterList?
		     IDENT formalParameterList
			   throwsClause?
			   block?)
{
	$value = "{{classScopeDeclarations[4] " +
		 $modifierList.value + " " +
		 ( $genericTypeParameterList.value != null ?
		   $genericTypeParameterList.value : "" ) + " " +
		 $IDENT.text + " " +
		 $formalParameterList.value + " " +
		 ( $throwsClause.value != null ?
		   $throwsClause.value : "" ) + " " +
		 ( $block.value != null ? $block.value : "" ) + "}}";
}
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
{
	$value = "{{classScopeDeclarations[5] " +
		 $modifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorList.value + "}}";
}
    |   ^(CONSTRUCTOR_DECL modifierList
			   genericTypeParameterList?
			   formalParameterList
			   throwsClause?
			   block)
{
	$value = "{{classScopeDeclarations[6] " +
		 ( $genericTypeParameterList.value != null ?
		   $genericTypeParameterList.value : "" ) + " " +
		 $formalParameterList.value + " " +
		 ( $throwsClause.value != null ?
		   $throwsClause.value : "" ) + " " +
		 $block.value + "}}";
}
    |   typeDeclaration
	{
		$value = $typeDeclaration.value;
	}
    ;
    
interfaceTopLevelScope returns [String value]
    :	{ $value = "{{interfaceTopLevelScope"; }
   	^( INTERFACE_TOP_LEVEL_SCOPE
	   ( interfaceScopeDeclarations
	     { $value += " " + $interfaceScopeDeclarations.value; } )* )
	{ $value += "}}"; }
    ;
    
interfaceScopeDeclarations returns [String value]
    :   ^(FUNCTION_METHOD_DECL modifierList
			       genericTypeParameterList?
			       type
			 IDENT formalParameterList
			       arrayDeclaratorList?
			       throwsClause?)
{
	$value = "{{interfaceTopLevelDeclarations[1] " +
		 $modifierList.value + " " +
		 ( $genericTypeParameterList.value != null ?
		   $genericTypeParameterList.value : "" ) + " " +
		 $type.value + " " +
		 $IDENT.text + " " +
		 $formalParameterList.value + " " +
		 ( $arrayDeclaratorList.value != null ?
		   $arrayDeclaratorList.value : "" ) + " " +
		 ( $throwsClause.value != null ?
		   $throwsClause.value : "" ) + "}}";
}
    |   ^(VOID_METHOD_DECL modifierList
			   genericTypeParameterList?
		     IDENT formalParameterList
			   throwsClause?)
        // Interface constant declarations have been switched to variable
        // declarations by 'java.g'; the parser has already checked that
        // there's an obligatory initializer.
{
	$value = "{{interfaceTopLevelDeclarations[2] " +
		 $modifierList.value + " " +
		 ( $genericTypeParameterList.value != null ?
		   $genericTypeParameterList.value : "" ) + " " +
		 $IDENT.text + " " +
		 $formalParameterList.value + " " +
		 ( $throwsClause.value != null ?
		   $throwsClause.value : "" ) + "}}";
}
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
{
	$value = "{{interfaceTopLevelDeclarations[3] " +
		 $modifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorList.value + "}}";
}
    |   typeDeclaration
	{
		$value = $typeDeclaration.value;
	}
    ;

variableDeclaratorList returns [String value]
    :	{ $value = ""; }
   	^( VAR_DECLARATOR_LIST
	   ( variableDeclarator
	     { $value +=
	       ( $value == "" ? $variableDeclarator.value
			      : "." + $variableDeclarator.value ); } )+ )
    ;

variableDeclarator returns [String value]
    :   ^(VAR_DECLARATOR variableDeclaratorId
	  		 variableInitializer?)
{
	$value =
		 $variableDeclaratorId.value + " = " +
		 ( $variableInitializer.value != null ?
		   $variableInitializer.value : "" );
}
    ;
    
variableDeclaratorId returns [String value]
    :   ^(IDENT arrayDeclaratorList?)
{
	$value = $IDENT.text + " " +
		 ( $arrayDeclaratorList.value != null ?
		   $arrayDeclaratorList.value : "" );
}
    ;

variableInitializer returns [String value]
    :   arrayInitializer
	{
		$value = $arrayInitializer.value;
	}
    |   expression
	{
		$value = $expression.value;
	}
    ;

arrayDeclarator returns [String value]
    :   LBRACK RBRACK
	{
		$value = $LBRACK.text + $RBRACK.text;
	}
    ;

arrayDeclaratorList returns [String value]
    :	{ $value = ""; }
   	^( ARRAY_DECLARATOR_LIST
	   ( ARRAY_DECLARATOR // This is [] from the grammar
	     { $value += " " + "[]"; } )* )
    ;
    
arrayInitializer returns [String value]
    :  ^( ARRAY_INITIALIZER
	   ( variableInitializer
	     { $value += " " + $variableInitializer.value; } )* )
    ;

throwsClause returns [String value]
    :	^( THROWS_CLAUSE
	   ( qualifiedIdentifier
	     { $value += " " + $qualifiedIdentifier.value; } )+ )
	{ $value += "}}"; }
    ;

modifierList returns [String value]
    :   { $value = ""; }
	^( MODIFIER_LIST
	   ( modifier { $value += " " + $modifier.value; } )* )
    ;

// {{{ modifier

modifier returns [String value]
	:	PUBLIC
		{
			$value = $PUBLIC.text;
		}
	|	PROTECTED
		{
			$value = $PROTECTED.text;
		}
	|	PRIVATE
		{
			$value = $PRIVATE.text;
		}
	|	STATIC
		{
			$value = $STATIC.text;
		}
	|	ABSTRACT
		{
			$value = $ABSTRACT.text;
		}
	|	NATIVE
		{
			$value = $NATIVE.text;
		}
	|	SYNCHRONIZED
		{
			$value = $SYNCHRONIZED.text;
		}
	|	TRANSIENT
		{
			$value = $TRANSIENT.text;
		}
	|	VOLATILE
		{	
			$value = $VOLATILE.text;
		}
	|	STRICTFP
		{
			$value = $STRICTFP.text;
		}
	|	localModifier
		{
			$value = $localModifier.value;
		}
	;

// }}}

localModifierList returns [String value]
    :   ^( LOCAL_MODIFIER_LIST
	   ( localModifier
	     { $value += " " + $localModifier.value; } )* )
    ;

localModifier returns [String value]
    :   FINAL
	{
		$value = $FINAL.text;
	}
    |   annotation
	{
		$value = $annotation.value;
	}
    ;

type returns [String value]
    :   ^(TYPE (primitiveType | qualifiedTypeIdent) arrayDeclaratorList?)
{
		 // XXX Yes, I know, no need to do ?: on the last branch,
		 // XXX but this keeps the code very much the same.
	$value = ( $primitiveType.value != null ?
		   $primitiveType.value :
		   $qualifiedTypeIdent.value != null ?
		   $qualifiedTypeIdent.value : "" ) + " " +
		 ( $arrayDeclaratorList.value != null ?
		   $arrayDeclaratorList.value : "" );
}
    ;

qualifiedTypeIdent returns [String value]
    :	{ $value = ""; }
   	^( QUALIFIED_TYPE_IDENT
	   ( typeIdent
	     { $value += ( $value == "" ? $typeIdent.value
					: "." + $typeIdent.value ); } )+ )
    ;

typeIdent returns [String value]
    :   ^(IDENT genericTypeArgumentList?)
{
	$value = $IDENT.text + " " +
	 	 ( $genericTypeArgumentList.value != null ?
		   $genericTypeArgumentList.value : "" );
}
    ;

// {{{ primitiveType

primitiveType returns [String value]
	:	BOOLEAN
		{
			$value = $BOOLEAN.text; 
		}
	|	CHAR
		{
			$value = $CHAR.text; 
		}
	|	BYTE
		{
			$value = $BYTE.text; 
		}
	|	SHORT
		{
			$value = $SHORT.text; 
		}
	|	INT
		{
			$value = $INT.text; 
		}
	|	LONG
		{
			$value = $LONG.text; 
		}
	|	FLOAT
		{
			$value = $FLOAT.text; 
		}
	|	DOUBLE
		{
			$value = $DOUBLE.text; 
		}
	;

// }}}

genericTypeArgumentList returns [String value]
    :	{ $value = "{{genericTypeArgumentList"; }
   	^( GENERIC_TYPE_ARG_LIST
	   ( genericTypeArgument
	     { $value += " " + $genericTypeArgument.value; } )+ )
	{ $value += "}}"; }
    ;
    
genericTypeArgument returns [String value]
    :   type
	{
		$value = $type.value;
	}
    |   ^(QUESTION genericWildcardBoundType?)
{
	$value = "{{genericTypeArgument[2] " +
		 $QUESTION.text + " " +
	 	 ( $genericWildcardBoundType.value != null ?
		   $genericWildcardBoundType.value : "" ) + "}}";
}
    ;

genericWildcardBoundType returns [String value]
    :   ^(EXTENDS type)
	{
		$value = $EXTENDS.text + " " + $type.value;
	}
    |   ^(SUPER type)
	{
		$value = $SUPER.text + " " + $type.value;
	}
    ;

formalParameterList returns [String value]
    :	{ $value = " ( "; }
   	^( FORMAL_PARAM_LIST
	   ( formalParameterStandardDecl
	     { $value += " " + $formalParameterStandardDecl.value; } )*
	   ( formalParameterVarargDecl
	     { $value += " " + $formalParameterVarargDecl.value; } )? )
	{ $value += " ) "; }
    ;
    
formalParameterStandardDecl returns [String value]
    :   ^(FORMAL_PARAM_STD_DECL localModifierList
				type
				variableDeclaratorId)
{
	$value = $localModifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorId.value;
}
    ;
    
formalParameterVarargDecl returns [String value]
    :   ^(FORMAL_PARAM_VARARG_DECL localModifierList
				   type
				   variableDeclaratorId)
{
	$value = "{{formalParameterVarargDecl " +
		 $FORMAL_PARAM_VARARG_DECL.text + " " +
		 $localModifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorId.value + "}}";
}
    ;
    
// {{{ qualifiedIdentifier

qualifiedIdentifier returns [String value]
	:	IDENT
		{
			$value = $IDENT.text;
		}
	|	^(DOT a=qualifiedIdentifier IDENT)
		{
			$value = $a.value + $DOT.text + $IDENT.text;
		}
	;

// }}}
    
// ANNOTATIONS

annotationList returns [String value]
    :	^( ANNOTATION_LIST
	   ( annotation
	     { $value += " " + $annotation.value; } )* )
    ;

annotation returns [String value]
    :   ^(AT qualifiedIdentifier annotationInit?)
{
	$value = "{{annotation " +
		 $AT.text + " " +
		 $qualifiedIdentifier.value + " " +
		 ( $annotationInit.value != null ?
		   $annotationInit.value : "" ) + "}}";
}
    ;
    
annotationInit returns [String value]
    :   ^(ANNOTATION_INIT_BLOCK annotationInitializers)
{
	$value = $annotationInitializers.value;
}
    ;

annotationInitializers returns [String value]
    :   { $value = "{{annotationInitializers[1]"; }
        ^( ANNOTATION_INIT_KEY_LIST
	   ( annotationInitializer
	     { $value += " " + $annotationInitializer.value; } )+ )
	{ $value += "}}"; }
    |   ^(ANNOTATION_INIT_DEFAULT_KEY annotationElementValue)
	{
		$value = $annotationElementValue.value;
	}
    ;
    
annotationInitializer returns [String value]
    :   ^(IDENT annotationElementValue)
{
	$value = "{{annotationInitializer " +
		 $IDENT.text + " " +
		 $annotationElementValue.value + "}}";
}
    ;
    
annotationElementValue returns [String value]
    :   { $value = "{{annotationElementValue"; }
	^( ANNOTATION_INIT_ARRAY_ELEMENT
	   { $value += " " + $ANNOTATION_INIT_ARRAY_ELEMENT.text; }
	   ( a=annotationElementValue { $value += " " + $a.value; } )*)
	{ $value += "}}"; }
    |   annotation
	{
		$value = $annotation.value;
	}
    |   expression
	{
		$value = $expression.value;
	}
    ;
    
annotationTopLevelScope returns [String value]
    :	{ $value = "{{annotationTopLevelScope"; }
   	^( ANNOTATION_TOP_LEVEL_SCOPE
	   ( annotationScopeDeclarations
	     { $value += " " + $annotationScopeDeclarations.value; } )* )
	{ $value += "}}"; }
    ;
    
annotationScopeDeclarations returns [String value]
    :   ^( ANNOTATION_METHOD_DECL modifierList
				  type
			    IDENT annotationDefaultValue? )
{
	$value = "{{annotationScopeDeclarations[1] " +
		 $ANNOTATION_METHOD_DECL.text + " " +
		 $modifierList.value + " " +
		 $type.value + " " +
		 $IDENT.text + " " +
		 ( $annotationDefaultValue.value != null ?
		   $annotationDefaultValue.value : "" ) + "}}";
}
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
{
	$value = "{{annotationScopeDeclarations[2] " +
		 $modifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorList.value + "}}";
}
    |   typeDeclaration
	{
		$value = $typeDeclaration.value;
	}
    ;
    
annotationDefaultValue returns [String value]
    :   ^(DEFAULT annotationElementValue)
{
	$value = "{{annotationDefaultValue " +
		 $DEFAULT.text + " " +
		 $annotationElementValue.value + "}}";
}
    ;

// STATEMENTS / BLOCKS

block returns [String value]
    :   { $value = " { "; }
	^( BLOCK_SCOPE
	   ( blockStatement
	     { $value += " " + $blockStatement.value; } )* )
	{ $value += " }\n"; }
    ;
    
blockStatement returns [String value]
    :   localVariableDeclaration
	{
		$value = $localVariableDeclaration.value;
	}
    |   typeDeclaration
	{
		$value = $typeDeclaration.value;
	}
    |   statement
	{
		$value = $statement.value;
	}
    ;
    
localVariableDeclaration returns [String value]
    :   ^(VAR_DECLARATION localModifierList type variableDeclaratorList)
{
	$value = $localModifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorList.value;
}
    ;
    
        
statement returns [String value]
    :   block
	{
		$value = $block.value;
	}
    |   ^(ASSERT a=expression b=expression?) // assert x < 0 : "x negative";
{
	$value = $ASSERT.text + " " +
		 $a.value +
		 ( $b.value != null ?
		   " : " + $b.value : "" ) + ";\n";
}
    |   ^(IF parenthesizedExpression a=statement b=statement?)
{
	$value = $IF.text + " " +
		 $parenthesizedExpression.value + " " +
		 $a.value + " " +
		 ( $b.value != null ?
		   $b.value : "" ) + "\n";
}
    |   ^(FOR forInit forCondition forUpdater a=statement)
{
	$value = $FOR.text + " ( " +
		 $forInit.value + "; " +
		 $forCondition.value + "; " +
		 $forUpdater.value + " ) " +
		 $a.value;
$value += ";\n";
}
    |   ^(FOR_EACH localModifierList type IDENT expression a=statement) 
{
	$value = "{{statement[5] " +
		 $FOR_EACH.text + " " +
		 $localModifierList.value + " " +
		 $type.value + " " +
		 $IDENT.text + " " +
		 $expression.value + " " +
		 $a.value + "}}";
}
    |   ^(WHILE parenthesizedExpression a=statement)
{
	$value = $WHILE.text + " " +
		 $parenthesizedExpression.value + " " +
		 $a.value;
}
    |   ^(DO a=statement parenthesizedExpression)
{
	$value = $DO.text + " { " +
		 $a.value + " } " +
		 "while" + " " + // JMG XXX Why doesn't the grammar have this?
		 $parenthesizedExpression.value;
$value += ";\n";
}
    |   ^(TRY a=block catches? b=block?)
	// The second optional block is the optional finally block.
{
	$value = "{{statement[8] " +
		 $TRY.text + " " +
		 $a.value + " " +
		 ( $catches.value != null ?
		   $catches.value : "" ) + " " +
		 ( $b.value != null ?
		   $b.value : "" ) + "}}";
}
    |   ^(SWITCH parenthesizedExpression switchBlockLabels)
{
	$value = $SWITCH.text + " " +
		 $parenthesizedExpression.value + " { " +
		 $switchBlockLabels.value + " } ";
}
    |   ^(SYNCHRONIZED parenthesizedExpression block)
{
	$value = "{{statement[10] " +
		 $SYNCHRONIZED.text + " " +
		 $parenthesizedExpression.value + " " +
		 $block.value + "}}";
}
    |   ^(RETURN expression?)
{
	$value = $RETURN.text + " " +
		 ( $expression.value != null ?
		   $expression.value : "" );
$value += ";\n";
}
    |   ^(THROW expression)
{
	$value = $THROW.text + " " + $expression.value;
}
    |   ^(BREAK IDENT?)
{
	$value = $BREAK.text + " " +
		 ( $IDENT.text != null ?
		   $IDENT.text : "" );
}
    |   ^(CONTINUE IDENT?)
{
	$value = $CONTINUE.text + " " +
		 ( $IDENT.text != null ?
		   $IDENT.text : "" );
}
    |   ^(LABELED_STATEMENT IDENT a=statement)
{
	$value = "{{statement[15] " +
		 $LABELED_STATEMENT.text + " " +
		 $IDENT.text + " " +
		 $a.value + "}}";
}
    |   expression
	{
		$value = $expression.value;
	}
    |   SEMI // Empty statement.
	{
		$value = $SEMI.text;
	}
    ;
        
catches returns [String value]
    :	{ $value = "{{catches"; }
   	^( CATCH_CLAUSE_LIST
	   ( catchClause
	     { $value += " " + $catchClause.value; } )+ )
	{ $value += "}}"; }
    ;
    
catchClause returns [String value]
    :   ^(CATCH formalParameterStandardDecl block)
{
	$value = "{{catchClause " +
		 $CATCH.text + " " +
		 $formalParameterStandardDecl.value + " " +
		 $block.value + "}}";
}
    ;

switchBlockLabels returns [String value]
    :   { $value = "{{switchBlockLabels"; }
	^( SWITCH_BLOCK_LABEL_LIST
	   ( a=switchCaseLabel { $value += " " + $a.value; } )*
	   ( switchDefaultLabel
	     { $value += " " + $switchDefaultLabel.value; } )?
	   ( b=switchCaseLabel { $value += " " + $b.value; } )* )
{ $value += "}}"; }
    ;
        
switchCaseLabel returns [String value]
    :	^( CASE { $value = " " + $CASE.text; }
	   expression { $value += " " + $expression.value + ": "; }
	   ( blockStatement
	     { $value += " " + $blockStatement.value; } )* )
    ;
    
switchDefaultLabel returns [String value]
    :	{ $value = "{{switchDefaultLabel"; }
   	^( DEFAULT
	   ( blockStatement
	     { $value += " " + $blockStatement.value; } )* )
	{ $value += "}}"; }
    ;
    
forInit returns [String value]
    :   { $value = ""; }
	^( FOR_INIT
	   ( localVariableDeclaration
	     { $value += " " + $localVariableDeclaration.value; }
	   | ( expression { $value += ( $value == "" ? $expression.value
						     : ", " + $expression.value ); } )*
	   )?
	 )
    ;
    
forCondition returns [String value]
    :   ^(FOR_CONDITION expression?)
	{
		$value = ( $expression.value != null ?
			   $expression.value : "" );
	}
    ;
    
forUpdater returns [String value]
    :	{ $value = ""; }
	^( FOR_UPDATE
	   ( expression
	     { $value += " " + $expression.value; } )* )
    ;
    
// EXPRESSIONS

// {{{ parenthesizedExpression

parenthesizedExpression returns [String value]
	:	^(PARENTESIZED_EXPR expression)
		{
			$value = "( " + $expression.value + " )";
		}
	;

// }}}
    
// {{{ expression
    
expression returns [String value]
	:	^(EXPR expr)
		{
			$value = $expr.value;
		}
	;

// }}}

expr returns [String value]
	:	^(ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "=" + " " + $rhs.value;
		}
	|	^(PLUS_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "+=" + " " + $rhs.value;
		}
	|	^(MINUS_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "-=" + " " + $rhs.value;
		}
	|	^(STAR_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "*=" + " " + $rhs.value;
		}
	|	^(DIV_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "/=" + " " + $rhs.value;
		}
	|	^(AND_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "&=" + " " + $rhs.value;
		}
	|	^(OR_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "|=" + " " + $rhs.value;
		}
	|	^(XOR_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "^=" + " " + $rhs.value;
		}
	|	^(MOD_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "\%=" + " " + $rhs.value;
		}
	|	^(BIT_SHIFT_RIGHT_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + ">>>=" + " " + $rhs.value;
		}
	|	^(SHIFT_RIGHT_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + ">>=" + " " + $rhs.value;
		}
	|	^(SHIFT_LEFT_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "<<=" + " " + $rhs.value;
		}
	|	^(QUESTION a=expr b=expr c=expr)
		{
			$value = $a.value + " ? " + $b.value + " : " + $c.value;
		}
	|	^(LOGICAL_OR lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "||" + " " + $rhs.value;
		}
	|	^(LOGICAL_AND lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "&&" + " " + $rhs.value;
		}
	|	^(OR lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "|" + " " + $rhs.value;
		}
	|	^(XOR lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "^" + " " + $rhs.value;
		}
	|	^(AND lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "&" + " " + $rhs.value;
		}
	|	^(EQUAL lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "==" + " " + $rhs.value;
		}
	|	^(NOT_EQUAL lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "!=" + " " + $rhs.value;
		}
	|	^(INSTANCEOF a=expr type)
		{
			$value = $a.value + " instanceof " + $type.value;
		}
	|	^(LESS_OR_EQUAL lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "<=" + " " + $rhs.value;
		}
	|	^(GREATER_OR_EQUAL lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + ">=" + " " + $rhs.value;
		}
	|	^(BIT_SHIFT_RIGHT lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + ">>>" + " " + $rhs.value;
		}
	|	^(SHIFT_RIGHT lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + ">>" + " " + $rhs.value;
		}
	|	^(GREATER_THAN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + ">" + " " + $rhs.value;
		}
	|	^(SHIFT_LEFT lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "<<" + " " + $rhs.value;
		}
	|	^(LESS_THAN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "<" + " " + $rhs.value;
		}
	|	^(PLUS lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "+" + " " + $rhs.value;
		}
	|	^(MINUS lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "-" + " " + $rhs.value;
		}
	|	^(STAR lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "*" + " " + $rhs.value;
		}
	|	^(DIV lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "/" + " " + $rhs.value;
		}
	|	^(MOD lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " + "\%" + " " + $rhs.value;
		}
	|	^(UNARY_PLUS a=expr)
		{
			$value = "+" + $a.value;
		}
	|	^(UNARY_MINUS a=expr)
		{
			$value = "-" + $a.value;
		}
	|	^(PRE_INC a=expr)
		{
			$value = "++" + $a.value;
		}
	|	^(PRE_DEC a=expr)
		{
			$value = "--" + $a.value;
		}
	|	^(POST_INC a=expr)
		{
			$value = $a.value + "++";
		}
	|	^(POST_DEC a=expr)
		{
			$value = $a.value + "--";
		}
	|	^(NOT a=expr)
		{
			$value = "~" + $a.value;
		}
	|	^(LOGICAL_NOT a=expr)
		{
			$value = "!" + $a.value;
		}
	|	^(CAST_EXPR type a=expr)
		{
			$value = " ( " + $type.value + ") " + $a.value;
		}
	|	primaryExpression
	 	{
			$value = $primaryExpression.value;
		}
	;
    
primaryExpression returns [String value]
    :   ^(DOT  (   a=primaryExpression { $value += $a.value + " "; }
                { $value += "." + " "; }
                (   IDENT { $value += $IDENT.text + " "; }
                |   THIS { $value += $THIS.text + " "; }
                |   SUPER { $value += $SUPER.text + " "; }
                |   innerNewExpression { $value += $innerNewExpression.value + " "; }
                |   A=CLASS { $value += $A.text + " "; }
                )
            |   primitiveType { $value += $primitiveType.value + " "; }
		B=CLASS { $value += $B.text + " "; }
            |   VOID { $value += $VOID.text + " "; }
		C=CLASS { $value += $C.text + " "; }
            )
        )
    |   parenthesizedExpression
	{
		$value = $parenthesizedExpression.value;
	}
    |   IDENT
	{
		$value = $IDENT.text;
	}
    |   ^(METHOD_CALL a=primaryExpression genericTypeArgumentList? arguments)
{
	$value = $a.value + " ( " +
		 ( $genericTypeArgumentList.value != null ?
		   $genericTypeArgumentList.value : "" ) + " " +
		 $arguments.value + " ) ";
}
    |   explicitConstructorCall
	{
		$value = $explicitConstructorCall.value;
	}
    |   ^(ARRAY_ELEMENT_ACCESS a=primaryExpression expression)
{
	$value = $a.value + " [ " +
		 $expression.value + " ] ";
}
    |   literal
	{
		$value = $literal.value;
	}
    |   newExpression
	{
		$value = $newExpression.value;
	}
    |   THIS
	{
		$value = $THIS.text;
	}
    |   arrayTypeDeclarator
	{
		$value = $arrayTypeDeclarator.value;
	}
    |   SUPER
	{
		$value = $SUPER.text;
	}
    ;
    
explicitConstructorCall returns [String value]
    :   ^(THIS_CONSTRUCTOR_CALL genericTypeArgumentList? arguments)
{
	$value = "{{explicitConstructorCall[1] " +
		 $THIS_CONSTRUCTOR_CALL.text + " " +
	 	 ( $genericTypeArgumentList.value != null ?
		   $genericTypeArgumentList.value : "" ) + "}}" +
		 $arguments.value + "}}";
}
    |   ^(SUPER_CONSTRUCTOR_CALL primaryExpression?
				 genericTypeArgumentList?
				 arguments)
{
	$value = "{{explicitConstructorCall[2] " +
		 $SUPER_CONSTRUCTOR_CALL.text + " " +
	 	 ( $primaryExpression.value != null ?
		   $primaryExpression.value : "" ) + " " +
	 	 ( $genericTypeArgumentList.value != null ?
		   $genericTypeArgumentList.value : "" ) + " " +
		 $arguments.value + "}}";
}
    ;

arrayTypeDeclarator returns [String value]
    :   ^( ARRAY_DECLARATOR
	   ( a=arrayTypeDeclarator | qualifiedIdentifier | primitiveType ) )
{
	$value = "{{arrayTypeDeclarator " +
		 $ARRAY_DECLARATOR.text + " " +
		 $a.value + " " +
		 $qualifiedIdentifier.value + " " +
		 $primitiveType.value + " " + "}}";
}
    ;

newExpression returns [String value]
    :   ^(  STATIC_ARRAY_CREATOR
            (   primitiveType a=newArrayConstruction
            |   genericTypeArgumentList?
		qualifiedTypeIdent
		b=newArrayConstruction
            )
        )
{
	$value = "new " +
		 ( $primitiveType.value != null ?
		   $primitiveType.value + " " + $a.value :
		   $qualifiedTypeIdent.value != null ?
		   ( $genericTypeArgumentList.value != null ?
		     $genericTypeArgumentList.value : "" ) + " " +
		   $qualifiedTypeIdent.value + " " +
		   $b.value : "" );
}
    |   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList?
				 qualifiedTypeIdent
				 arguments
				 classTopLevelScope?)
{
	$value = "{{newExpression[2] " + "new" +
	 	 ( $genericTypeArgumentList.value != null ?
		   $genericTypeArgumentList.value : "" ) + " " +
		 $qualifiedTypeIdent.value + " ( " +
		 $arguments.value + " ) " +
	 	 ( $classTopLevelScope.value != null ?
		   $classTopLevelScope.value : "" ) + "}}";
}
    ;

innerNewExpression returns [String value] // something like 'InnerType innerType = outer.new InnerType();'
    :   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList?
			   IDENT arguments
				 classTopLevelScope?)
{
	$value = "{{innerNewExpression " +
		 $CLASS_CONSTRUCTOR_CALL.text + " " +
	 	 ( $genericTypeArgumentList.value != null ?
		   $genericTypeArgumentList.value : "" ) + " " +
		 $IDENT.text + " " +
		 $arguments.value + " " +
	 	 ( $classTopLevelScope.value != null ?
		   $classTopLevelScope.value : "" ) + "}}";
}
    ;
    
newArrayConstruction returns [String value]
    :   arrayDeclaratorList arrayInitializer
{
	$value = "{{newArrayConstruction[1] " +
		 $arrayDeclaratorList.value + " " +
		 $arrayInitializer.value + "}}";
}
    |   { $value = ""; }
	( expression { $value += " [ " + $expression.value + " ] "; } )+
	( arrayDeclaratorList
	  { $value += " " + $arrayDeclaratorList.value; } )?
    ;

arguments returns [String value]
    : { $value = ""; }
      ^( ARGUMENT_LIST
	 ( expression
	   { $value += ( $value == "" ? $expression.value
				      : ", " + $expression.value ); } )* )
    ;

// {{{ literal

literal returns [String value]
	:	HEX_LITERAL
	 	{
			$value = $HEX_LITERAL.text;
		}
	|	OCTAL_LITERAL
	 	{
			$value = $OCTAL_LITERAL.text;
		}
	|	DECIMAL_LITERAL
	 	{
			$value = $DECIMAL_LITERAL.text;
		}
	|	FLOATING_POINT_LITERAL
	 	{
			$value = $FLOATING_POINT_LITERAL.text;
		}
	|	CHARACTER_LITERAL
	 	{
			$value = $CHARACTER_LITERAL.text;
		}
	|	STRING_LITERAL
	 	{
			$value = $STRING_LITERAL.text;
		}
	|	TRUE
	 	{
			$value = $TRUE.text;
		}
	|	FALSE
	 	{
			$value = $FALSE.text;
		}
	|	NULL
	 	{
			$value = $NULL.text;
		}
	;

// }}}
