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

// {{{ javaSource

javaSource returns [String value]
@init{ int _i = 0, _j = 0; }
    :   ^( JAVA_SOURCE
	   annotationList { $value = $annotationList.value; }
	   ( packageDeclaration
	     { $value += " " + $packageDeclaration.value; } )?
	   ( importDeclaration
	     { $value += ( _i++ == 0 ? $importDeclaration.value
				     : " " + $importDeclaration.value ); } )*
	   ( typeDeclaration
	     { $value += ( _j++ == 0 ? $typeDeclaration.value
				     : " " + $typeDeclaration.value ); } )* )
    ;

// }}}

// {{{ packageDeclaration

packageDeclaration returns [String value]
	:	^( PACKAGE { $value = $PACKAGE.text + " "; }
		   qualifiedIdentifier
		   { $value += $qualifiedIdentifier.value + ";" + "\n"; }
		 )
	;

// }}}
    
// {{{ importDeclaration

importDeclaration returns [String value]
    :   ^( IMPORT { $value = $IMPORT.text; }
	   ( STATIC { $value += " " + $STATIC.text; } )?
	   qualifiedIdentifier { $value += " " + $qualifiedIdentifier.value; }
	   ( DOTSTAR { $value += " " + $DOTSTAR.text; } )?
	 )
    ;

// }}}
    
// {{{ typeDeclaration

typeDeclaration returns [String value]
    :   ^( CLASS modifierList
	   IDENT genericTypeParameterList?
		 extendsClause?
		 implementsClause?
		 classTopLevelScope )
	{
		$value = $modifierList.value +
			 " " + $CLASS.text +
			 " " + $IDENT.text +
			 ( $genericTypeParameterList.value != null ?
			   " " + $genericTypeParameterList.value : "" ) + " " +
			 ( $extendsClause.value != null ?
			   " " + $extendsClause.value : "" ) +
			 ( $implementsClause.value != null ?
			   " " + $implementsClause.value : "" ) +
			 " " + "{" + "\n" +
			 $classTopLevelScope.value + " " + "}" + "\n";
	}
    |   ^(INTERFACE modifierList
	      IDENT genericTypeParameterList?
	  	    extendsClause?
		    interfaceTopLevelScope)
	{
		$value = $INTERFACE.text +
			 " " + $modifierList.value +
			 " " + $IDENT.text +
			 ( $genericTypeParameterList.value != null ?
			   " " + $genericTypeParameterList.value : "" ) +
			 ( $extendsClause.value != null ?
			   " " + $extendsClause.value : "" ) +
			 " " + $interfaceTopLevelScope.value;
	}
    |   ^(ENUM modifierList
	 IDENT implementsClause?
	       enumTopLevelScope)
	{
		$value = $ENUM.text +
			 " " + $modifierList.value +
			 " " + $IDENT.text +
			 ( $implementsClause.value != null ?
			   " " + $implementsClause.value : "" ) +
			 " " + $enumTopLevelScope.value;
	}
    |    ^(AT modifierList
	IDENT annotationTopLevelScope)
	{
		$value = $AT.text +
			 " " + $modifierList.value +
			 " " + $IDENT.text +
			 " " + $annotationTopLevelScope.value;
	}
    ;

// }}}

// {{{ extendsClause

// actually 'type' for classes and 'type+' for interfaces, but this has 
// been resolved by the parser grammar.
extendsClause returns [String value]
@init{ int _i = 0; }
	:	^( EXTENDS_CLAUSE { $value = "extends" + " "; }
		   ( type
		     { $value += ( _i++ == 0 ? $type.value
					     : " " + $type.value ); } )+ )
	;

// }}}

// {{{ implementsClause

implementsClause returns [String value]
@init{ int _i = 0; }
	:	^( IMPLEMENTS_CLAUSE { $value = "implements" + " "; }
		   ( type
		     { $value += ( _i++ == 0 ? $type.value
		                             : " " + $type.value ); } )+ )
	;

// }}}
        
// {{{ genericTypeParameterList

genericTypeParameterList returns [String value]
@init{ int _i = 0; }
    :	^( GENERIC_TYPE_PARAM_LIST { $value = ""; }
	   ( genericTypeParameter
	     { $value += ( _i++ == 0 ? $genericTypeParameter.value
				     : " " + $genericTypeParameter.value ); } )+ )
    ;

// }}}

// {{{ genericTypeParameter

genericTypeParameter returns [String value]
	:	^( IDENT { $value = $IDENT.text; }
		   ( bound { $value += " " + $bound.value; } )?
		 )
	;

// }}}
        
// {{{ bound

bound returns [String value]
@init{ int _i = 0; }
	:	^( EXTENDS_BOUND_LIST { $value = ""; }
		   ( type 
		     { $value += ( _i++ == 0 ? $type.value
					     : " " + $type.value ); } )+
		 )
	;

// }}}

// {{{ enumTopLevelScope

enumTopLevelScope returns [String value]
@init{ int _i = 0; }
    :   ^( ENUM_TOP_LEVEL_SCOPE { $value = ""; }
	   ( enumConstant
	     { $value += ( _i++ == 0 ? $enumConstant.value
				     : " " + $enumConstant.value ); } )+
	   ( classTopLevelScope
	     { $value += " " + $classTopLevelScope.value; } )? )
    ;

// }}}
    
// {{{ enumConstant

enumConstant returns [String value]
    :   ^( IDENT { $value = $IDENT.text; }
	   annotationList { $value += " " + $annotationList.value; }
	   ( arguments { $value += " " + $arguments.value; } )?
	   ( classTopLevelScope
	     { $value += " " + $classTopLevelScope.value; } )?
	 )
    ;

// }}}
    
// {{{ classTopLevelScope

classTopLevelScope returns [String value]
@init{ int _i = 0; }
    :	^( CLASS_TOP_LEVEL_SCOPE { $value = ""; }
	   ( classScopeDeclarations
	     { $value += ( _i++ == 0 ? $classScopeDeclarations.value
				     : " " + $classScopeDeclarations.value ); } )+ )
    ;

// }}}

// {{{ classScopeDeclarations
    
classScopeDeclarations returns [String value]
    :   ^( CLASS_INSTANCE_INITIALIZER block )
	{ $value = $block.value; }
    |   ^( CLASS_STATIC_INITIALIZER block )
	{ $value = $block.value; }
    |   ^( FUNCTION_METHOD_DECL modifierList
			        genericTypeParameterList?
			        type
			  IDENT formalParameterList
			        arrayDeclaratorList?
			        throwsClause?
			        block? )
	{
		$value = $modifierList.value +
			 ( $genericTypeParameterList.value != null ?
			   " " + $genericTypeParameterList.value : "" ) + 
			 " " + $type.value +
			 " " + $IDENT.text +
			 " " + $formalParameterList.value +
			 ( $arrayDeclaratorList.value != null ?
			   " " + $arrayDeclaratorList.value : "" ) +
			 ( $throwsClause.value != null ?
			   " " + $throwsClause.value : "" ) +
			 ( $block.value != null ? " " + $block.value
						: "" );
	}
    |   ^( VOID_METHOD_DECL modifierList
			    genericTypeParameterList?
		      IDENT formalParameterList
			    throwsClause?
			    block? )
	{
		$value = $modifierList.value +
			 ( $genericTypeParameterList.value != null ?
			   " " + $genericTypeParameterList.value : "" ) +
			 " " + "void" +
			 " " + $IDENT.text +
			 " " + $formalParameterList.value +
			 ( $throwsClause.value != null ?
			   " " + $throwsClause.value : "" ) +
			 ( $block.value != null ? " " + $block.value : "" );
	}
    |   ^( VAR_DECLARATION modifierList
			   type
			   variableDeclaratorList )
	{
		$value = $modifierList.value +
			 " " + $type.value +
			 " " + $variableDeclaratorList.value + ";";
	}
    |   ^( CONSTRUCTOR_DECL
		      IDENT modifierList
			    genericTypeParameterList?
			    formalParameterList
			    throwsClause?
			    block )
	{
		$value = $modifierList.value +
			 " " + $IDENT.text +
			 ( $genericTypeParameterList.value != null ?
			   " " + $genericTypeParameterList.value : "" ) +
			 " " + $formalParameterList.value +
			 ( $throwsClause.value != null ?
			   " " + $throwsClause.value : "" ) +
			 " " + $block.value;
	}
    |   typeDeclaration
	{ $value = $typeDeclaration.value; }
    ;

// }}}
    
// {{{ interfaceTopLevelScope

interfaceTopLevelScope returns [String value]
@init{ int _i = 0; }
    :	^( INTERFACE_TOP_LEVEL_SCOPE { $value = ""; }
	   ( interfaceScopeDeclarations
	     { $value += ( _i++ == 0 ? $interfaceScopeDeclarations.value
				     : " " + $interfaceScopeDeclarations.value ); } )* )
    ;

// }}}
    
// {{{ interfaceScopeDeclarations

interfaceScopeDeclarations returns [String value]
    :   ^( FUNCTION_METHOD_DECL modifierList
			        genericTypeParameterList?
			        type
			  IDENT formalParameterList
			        arrayDeclaratorList?
			        throwsClause?)
	{
		$value = $modifierList.value +
			 ( $genericTypeParameterList.value != null ?
			   " " + $genericTypeParameterList.value : "" ) +
			 " " + $type.value +
			 " " + $IDENT.text +
			 " " + $formalParameterList.value +
			 ( $arrayDeclaratorList.value != null ?
			   " " + $arrayDeclaratorList.value : "" ) +
			 ( $throwsClause.value != null ?
			   " " + $throwsClause.value : "" );
	}
    |   ^( VOID_METHOD_DECL modifierList
			    genericTypeParameterList?
		      IDENT formalParameterList
			    throwsClause? )
        // Interface constant declarations have been switched to variable
        // declarations by 'java.g'; the parser has already checked that
        // there's an obligatory initializer.
	{
		$value = $modifierList.value +
			 ( $genericTypeParameterList.value != null ?
			   " " + $genericTypeParameterList.value : "" ) +
			 " " + $IDENT.text +
			 " " + $formalParameterList.value +
			 ( $throwsClause.value != null ?
			   " " + $throwsClause.value : "" );
	}
    |   ^( VAR_DECLARATION modifierList
			   type
			   variableDeclaratorList )
	{
		$value = $modifierList.value +
			 " " + $type.value +
			 " " + $variableDeclaratorList.value + ";";
	}
    |   typeDeclaration
	{ $value = $typeDeclaration.value; }
    ;

// }}}

// {{{ variableDeclaratorList

variableDeclaratorList returns [String value]
@init{ int _i = 0; }
    :	^( VAR_DECLARATOR_LIST { $value = ""; }
	   ( variableDeclarator
	     { $value +=
	       ( _i++ == 0 ? $variableDeclarator.value
			   : "," + " " + $variableDeclarator.value ); } )+ )
    ;

// }}}

// {{{ variableDeclarator

variableDeclarator returns [String value]
    :   ^( VAR_DECLARATOR
	   variableDeclaratorId { $value = $variableDeclaratorId.value; }
	   ( variableInitializer
	     { $value += " " + "=" + " " + $variableInitializer.value; } )?
	 )
    ;

// }}}
    
// {{{ variableDeclaratorId

variableDeclaratorId returns [String value]
	:	^( IDENT { $value = $IDENT.text; }
		   ( arrayDeclaratorList
		     { $value += " " + $arrayDeclaratorList.value; } )? )
	;

// }}}

// {{{ variableInitializer

variableInitializer returns [String value]
	:	arrayInitializer	{ $value = $arrayInitializer.value; }
	|	expression		{ $value = $expression.value; }
	;

// }}}

// {{{ arrayDeclarator

arrayDeclarator returns [String value]
	:	LBRACK RBRACK	{ $value = $LBRACK.text + $RBRACK.text; }
	;

// }}}

// {{{ arrayDeclaratorList

arrayDeclaratorList returns [String value]
	:	^( ARRAY_DECLARATOR_LIST { $value = ""; }
		   ( ARRAY_DECLARATOR // This is [] from the grammar
		     { $value += "[" + "]"; } )* )
	;

// }}}
    
// {{{ arrayInitializer

arrayInitializer returns [String value]
@init{ int _i = 0; }
    :   { $value = " " + "{" + " "; }
	^( ARRAY_INITIALIZER
	   ( variableInitializer
	     { $value += ( _i++ == 0 ? $variableInitializer.value
				     : "," + " " + $variableInitializer.value ); } )* )
	{ $value += " " + "}" + " "; }
    ;

// }}}

// {{{ throwsClause

throwsClause returns [String value]
@init{ int _i = 0; }
    :	^( THROWS_CLAUSE
	   THROWS { $value = $THROWS.text + " "; }
	   ( qualifiedIdentifier
	     { $value += ( _i++ == 0 ? $qualifiedIdentifier.value
				     : " " + $qualifiedIdentifier.value ); } )+ )
    ;

// }}}

// {{{ modifierList

modifierList returns [String value]
@init{ int _i = 0; }
	:	^( MODIFIER_LIST { $value = ""; }
		   ( modifier
		     { $value += ( _i++ == 0 ? $modifier.value
					     : " " + $modifier.value ); } )* )
	;

// }}}

// {{{ modifier

modifier returns [String value]
	:	PUBLIC		{ $value = $PUBLIC.text; }
	|	PROTECTED	{ $value = $PROTECTED.text; }
	|	PRIVATE		{ $value = $PRIVATE.text; }
	|	STATIC		{ $value = $STATIC.text; }
	|	ABSTRACT	{ $value = $ABSTRACT.text; }
	|	NATIVE		{ $value = $NATIVE.text; }
	|	SYNCHRONIZED	{ $value = $SYNCHRONIZED.text; }
	|	TRANSIENT	{ $value = $TRANSIENT.text; }
	|	VOLATILE	{ $value = $VOLATILE.text; }
	|	STRICTFP	{ $value = $STRICTFP.text; }
	|	localModifier	{ $value = $localModifier.value; }
	;

// }}}

// {{{ localModifierList

localModifierList returns [String value]
@init{ int _i = 0; }
    :   ^( LOCAL_MODIFIER_LIST { $value = ""; }
	   ( localModifier
	     { $value += ( _i++ == 0 ? $localModifier.value
				     : "," + " " + $localModifier.value ); } )* )
    ;

// }}}

// {{{ localModifier

localModifier returns [String value]
	:	FINAL		{ $value = $FINAL.text; }
	|	annotation	{ $value = $annotation.value; }
	;

// }}}

// {{{ type

type returns [String value]
	:	^( TYPE
		   ( primitiveType { $value = $primitiveType.value; }
		   | qualifiedTypeIdent { $value = $qualifiedTypeIdent.value; }
		   )
		   ( arrayDeclaratorList
		     { $value += " " + $arrayDeclaratorList.value; } )?
		 )
	;

// }}}

// {{{ qualifiedTypeIdent

qualifiedTypeIdent returns [String value]
@init{ int _i = 0; }
	:	^( QUALIFIED_TYPE_IDENT { $value = ""; }
		   ( typeIdent
		     { $value += ( _i++ == 0 ? $typeIdent.value
					     : "." + $typeIdent.value ); } )+ )
	;

// }}}

// {{{ typeIdent

typeIdent returns [String value]
	:	^( IDENT { $value = $IDENT.text; }
		   ( genericTypeArgumentList
		     { $value += " " + $genericTypeArgumentList.value; } )? )
	;

// }}}

// {{{ primitiveType

primitiveType returns [String value]
	:	BOOLEAN	{ $value = $BOOLEAN.text; }
	|	CHAR	{ $value = $CHAR.text; }
	|	BYTE	{ $value = $BYTE.text; }
	|	SHORT	{ $value = $SHORT.text; }
	|	INT	{ $value = $INT.text; }
	|	LONG	{ $value = $LONG.text; }
	|	FLOAT	{ $value = $FLOAT.text; }
	|	DOUBLE	{ $value = $DOUBLE.text; }
	;

// }}}

// {{{ genericTypeArgumentList

genericTypeArgumentList returns [String value]
@init{ int _i = 0; }
    :	^( GENERIC_TYPE_ARG_LIST { $value = ""; }
	   ( genericTypeArgument
	     { $value += ( _i++ == 0 ? $genericTypeArgument.value
				     : "." + $genericTypeArgument.value ); } )+ )
    ;

// }}}
    
// {{{ genericTypeArgument

genericTypeArgument returns [String value]
    :   type
	{ $value = $type.value; }
    |   ^( QUESTION { $value = $QUESTION.text; }
	   ( genericWildcardBoundType
	     { $value += " " + $genericWildcardBoundType.value; } )? )
    ;

// }}}

// {{{ genericWildcardBoundType

genericWildcardBoundType returns [String value]
    :	^( EXTENDS type )	{ $value = $EXTENDS.text + " " + $type.value; }
    |   ^( SUPER type )		{ $value = $SUPER.text + " " + $type.value; }
    ;

// }}}

// {{{ formalParameterList

formalParameterList returns [String value]
@init{ int _i = 0; }
    :	{ $value = " " + "(" + " "; }
   	^( FORMAL_PARAM_LIST
	   ( formalParameterStandardDecl
	     { $value += ( _i++ == 0 ? $formalParameterStandardDecl.value
				     : "," + " " + $formalParameterStandardDecl.value ); } )*
	   ( formalParameterVarargDecl
	     { $value += " " + $formalParameterVarargDecl.value; } )? )
	{ $value += " " + ")" + " "; }
    ;

// }}}
    
// {{{ formalParameterStandardDecl

formalParameterStandardDecl returns [String value]
    :   ^( FORMAL_PARAM_STD_DECL
	   localModifierList { $value = $localModifierList.value; }
	   type { $value += " " + $type.value; }
	   variableDeclaratorId { $value += " " + $variableDeclaratorId.value; }
	 )
    ;

// }}}
    
// {{{ formalParameterVarargDecl

formalParameterVarargDecl returns [String value]
    :   ^( FORMAL_PARAM_VARARG_DECL
	   localModifierList { $value = $localModifierList.value; }
	   type { $value += " " + $type.value; }
	   variableDeclaratorId { $value += " " + $variableDeclaratorId.value; }
	 )
    ;

// }}}
    
// {{{ qualifiedIdentifier

qualifiedIdentifier returns [String value]
	:	IDENT
		{ $value = $IDENT.text; }
	|	^( DOT a=qualifiedIdentifier IDENT )
		{ $value = $a.value + $DOT.text + $IDENT.text; }
	;

// }}}
    
// ANNOTATIONS

// {{{ annotationList

annotationList returns [String value]
@init{ int _i = 0; }
    :	^( ANNOTATION_LIST { $value = ""; }
	   ( annotation
	     { $value += ( _i++ == 0 ? $annotation.value
				     : "\n" + $annotation.value ); } )* )
    ;

// }}}

// {{{ annotation

annotation returns [String value]
    :   ^( AT { $value = $AT.text; }
	   qualifiedIdentifier { $value += " " + $qualifiedIdentifier.value; }
	   ( annotationInit { $value += " " + $annotationInit.value; } )? )
    ;

// }}}
    
// {{{ annotationInit

annotationInit returns [String value]
	:	^( ANNOTATION_INIT_BLOCK annotationInitializers )
		 { $value = $annotationInitializers.value; }
	;

// }}}

// {{{ annotationInitializers

annotationInitializers returns [String value]
@init{ int _i = 0; }
    :   ^( ANNOTATION_INIT_KEY_LIST { $value = ""; }
	   ( annotationInitializer
	     { $value += ( _i++ == 0 ? $annotationInitializer.value
				     : "." + $annotationInitializer.value ); } )+ )
    |   ^( ANNOTATION_INIT_DEFAULT_KEY annotationElementValue )
	   { $value = $annotationElementValue.value; }
    ;

// }}}
    
// {{{ annotationInitializer

annotationInitializer returns [String value]
	:	^( IDENT { $value = $IDENT.text; }
	           annotationElementValue 
		   { $value += " " + $annotationElementValue.value; } )
	;

// }}}
    
// {{{ annotationElementValue

annotationElementValue returns [String value]
@init{ int _i = 0; }
    :   ^( ANNOTATION_INIT_ARRAY_ELEMENT
	   { $value = $ANNOTATION_INIT_ARRAY_ELEMENT.text; }
	   ( a=annotationElementValue
	     { $value += ( _i++ == 0 ? $a.value
				     : " " + $a.value ); } )* )
    |   annotation
	{ $value = $annotation.value; }
    |   expression
	{ $value = $expression.value; }
    ;

// }}}
    
// {{{ annotationTopLevelScope

annotationTopLevelScope returns [String value]
@init{ int _i = 0; }
    :	^( ANNOTATION_TOP_LEVEL_SCOPE { $value = ""; }
	   ( annotationScopeDeclarations
	     { $value += ( _i++ == 0 ? $annotationScopeDeclarations.value
				     : " " + $annotationScopeDeclarations.value ); } )* )
    ;

// }}}
    
// {{{ annotationScopeDeclarations

annotationScopeDeclarations returns [String value]
    :   ^( ANNOTATION_METHOD_DECL modifierList
				  type
			    IDENT annotationDefaultValue? )
	{
		$value = $ANNOTATION_METHOD_DECL.text + " " +
			 $modifierList.value + " " +
			 $type.value + " " +
			 $IDENT.text +
			 ( $annotationDefaultValue.value != null ?
			   " " + $annotationDefaultValue.value : "" );
	}
    |   ^( VAR_DECLARATION
	   modifierList { $value = $modifierList.value; }
	   type { $value += " " + $type.value; }
	   variableDeclaratorList
	   { $value += " " + $variableDeclaratorList.value; } )
    |   typeDeclaration
	{ $value = $typeDeclaration.value; }
    ;

// }}}
    
// {{{ annotationDefaultValue

annotationDefaultValue returns [String value]
	:	^( DEFAULT { $value = $DEFAULT.text; }
		   annotationElementValue
		   { $value += " " + $annotationElementValue.value; } )
	;

// }}}

// STATEMENTS / BLOCKS

// {{{ block

block returns [String value]
@init{ int _i = 0; }
    :   ^( BLOCK_SCOPE { $value = " " + "{" + "\n"; }
	   ( blockStatement
	     { $value += ( _i++ == 0 ? $blockStatement.value
				     : ";" + "\n" + $blockStatement.value ); } )* )
	{ $value += " " + "}" + "\n"; } // Almost redundant, 'throw new exception(..)' requires it.
    ;

// }}}

// {{{ blockStatement
    
blockStatement returns [String value]
	:	localVariableDeclaration
		{ $value = $localVariableDeclaration.value; }
	|	typeDeclaration
		{ $value = $typeDeclaration.value; }
	|	statement
		{ $value = $statement.value; }
	;

// }}}
    
// {{{ localVariableDeclaration

localVariableDeclaration returns [String value]
    :   ^( VAR_DECLARATION
	   localModifierList
	   { $value = $localModifierList.value; }
	   type
	   { $value += " " + $type.value; }
	   variableDeclaratorList
	   { $value += " " + $variableDeclaratorList.value; }
	 )
    ;

// }}}

// {{{ statement

statement returns [String value]
    :   block
	{ $value = $block.value; }
    // assert x < 0 : "x negative";
    |   ^( ASSERT		{ $value = $ASSERT.text; }
	   a=expression		{ $value += " " + $a.value; }
	   ( b=expression	{ $value += " " + $b.value; } )? )
    |   ^( IF { $value = $IF.text; }
	   parenthesizedExpression
	   { $value += " " + $parenthesizedExpression.value; }
	   a=statement { $value += " " + $a.value; }
	   ( b=statement { $value += " " + $b.value; } )?)
    |   ^( FOR		{ $value = $FOR.text + " " + "("; }
	   forInit	{ $value += " " + $forInit.value + ";" ; }
	   forCondition	{ $value += " " + $forCondition.value + ";"; }
	   forUpdater	{ $value += " " + $forUpdater.value + " " + ")"; }
	   a=statement	{ $value += " " + $a.value + "\n"; } )
    |   ^( FOR_EACH		{ $value = $FOR_EACH.text; }
	   localModifierList	{ $value += " " + $localModifierList.value; }
	   type			{ $value += " " + $type.value; }
	   IDENT		{ $value += " " + $IDENT.text; }
	   expression		{ $value += " " + $expression.value; }
	   a=statement		{ $value += " " + $a.value; }
	 ) 
    |   ^( WHILE		{ $value = $WHILE.text; }
	   parenthesizedExpression
	   { $value += " " + $parenthesizedExpression.value; }
	   a=statement 		{ $value += " " + $a.value; } )
    |   ^( DO			{ $value = $DO.text + " " + "{" + "\n"; }
	   a=statement		{ $value += $a.value + " " + "}" + " "; }
	   parenthesizedExpression
	   { $value += " " + "while" + " " +
		       $parenthesizedExpression.value + ";" + "\n"; }
	 )
	// The second optional block is the optional finally block.
    |   ^( TRY			{ $value = $TRY.text; }
	   a=block		{ $value += " " + $a.value; }
	   ( catches		{ $value += " " + $catches.value; } )?
	   ( b=block		{ $value += " " + $b.value; } )? )
    |   ^( SWITCH		{ $value = $SWITCH.text; }
	   parenthesizedExpression
	   { $value += " " + $parenthesizedExpression.value; }
	   switchBlockLabels
	   { $value += " " + "{" + " " + $switchBlockLabels.value +
		       " " + "}" + "\n"; }
	 )
    |   ^( SYNCHRONIZED { $value = $SYNCHRONIZED.text; }
	   parenthesizedExpression
	   { $value += " " + $parenthesizedExpression.value; }
	   block	{ $value += $block.value; } )
    |   ^( RETURN	{ $value = $RETURN.text; }
	   ( expression { $value += " " + $expression.value; } )?
	 )
	 { $value += ";" + "\n"; }
    |   ^( THROW { $value = $THROW.text; }
	   expression { $value += " " + $expression.value + ";"; } )
    |   ^( BREAK	{ $value = $BREAK.text; }
	   ( IDENT	{ $value += " " + $IDENT.text; } )?
	 )
    |   ^( CONTINUE	{ $value = $CONTINUE.text; }
	   ( IDENT	{ $value += " " + $IDENT.text; } )?
	 )
    |   ^( LABELED_STATEMENT	{ $value = $LABELED_STATEMENT.text; }
	   IDENT		{ $value += " " + $IDENT.text; }
	   a=statement		{ $value += " " + $a.value; }
	 )
    |   expression
	{ $value = $expression.value + ";"; }
    |   SEMI // Empty statement.
	{ $value = $SEMI.text; }
    ;

// }}}
        
// {{{ catches

catches returns [String value]
@init{ int _i = 0; }
    :	^( CATCH_CLAUSE_LIST { $value = ""; }
	   ( catchClause
	     { $value += ( _i++ == 0 ? $catchClause.value
				     : " " + $catchClause.value ); } )+ )
    ;

// }}}
    
// {{{ catchClause

catchClause returns [String value]
	:	^( CATCH { $value = $CATCH.text + " " + "("; }
		   formalParameterStandardDecl
		   { $value += " " + $formalParameterStandardDecl.value +
			       ")" + " " + "{" + "\n"; }
		   block { $value += " " + $block.value + " " + "}" + "\n"; } )
	;

// }}}

// {{{ switchBlockLabels

switchBlockLabels returns [String value]
    :   { $value = ""; }
	^( SWITCH_BLOCK_LABEL_LIST
	   ( a=switchCaseLabel
	     { $value += ( $value == "" ? $a.value
					: " " + $a.value ); } )*
	   ( switchDefaultLabel
	     { $value += " " + $switchDefaultLabel.value; } )?
//	   ( b=switchCaseLabel
//	     { $value += ( $value == "" ? $b.value
//					: " " + $b.value ); } )*
	 )
    ;

// }}}
        
// {{{ switchCaseLabel

switchCaseLabel returns [String value]
@init{ int _i = 0; }
    :	^( CASE { $value = $CASE.text; }
	   expression { $value += " " + $expression.value + ":" + " "; }
	   ( blockStatement
	     { $value += ( _i++ == 0 ? $blockStatement.value
				     : " " + $blockStatement.value ); } )* )
    ;

// }}}
    
// {{{ switchDefaultLabel

switchDefaultLabel returns [String value]
@init{ int _i = 0; }
    :	^( DEFAULT
	   ( blockStatement
	     { $value += ( _i++ == 0 ? $blockStatement.value
				     : " " + $blockStatement.value ); } )* )
    ;

// }}}
    
// {{{ forInit

forInit returns [String value]
    :   ^( FOR_INIT { $value = ""; }
	   ( localVariableDeclaration
	     { $value += " " + $localVariableDeclaration.value; }
	   | ( expression
	       { $value += ( $value == "" ? $expression.value
					  : "," + " " + $expression.value ); } )* )?
	 )
    ;

// }}}
    
// {{{ forCondition

forCondition returns [String value]
	:	^( FOR_CONDITION { $value = ""; }
		   ( expression
		     { $value = $expression.value; } )? )
	;

// }}}
    
// {{{ forUpdater

forUpdater returns [String value]
@init{ int _i = 0; }
    :	^( FOR_UPDATE { $value = ""; }
	   ( expression
	     { $value += ( _i++ == 0 ? $expression.value
				     : " " + $expression.value ); } )* )
    ;

// }}}
    
// EXPRESSIONS

// {{{ parenthesizedExpression

parenthesizedExpression returns [String value]
	:	^( PARENTESIZED_EXPR expression )
		 { $value = "(" + $expression.value + ")"; }
	;

// }}}
    
// {{{ expression
    
expression returns [String value]
	:	^( EXPR expr { $value = $expr.value; } )
	;

// }}}

// {{{ expr

expr returns [String value]
	:	^(ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "=" + " " + $rhs.value; }
	|	^(PLUS_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "+=" + " " + $rhs.value; }
	|	^(MINUS_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "-=" + " " + $rhs.value; }
	|	^(STAR_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "*=" + " " + $rhs.value; }
	|	^(DIV_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "/=" + " " + $rhs.value; }
	|	^(AND_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "&=" + " " + $rhs.value; }
	|	^(OR_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "|=" + " " + $rhs.value; }
	|	^(XOR_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "^=" + " " + $rhs.value; }
	|	^(MOD_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "\%=" + " " + $rhs.value; }
	|	^(BIT_SHIFT_RIGHT_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + ">>>=" + " " + $rhs.value; }
	|	^(SHIFT_RIGHT_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + ">>=" + " " + $rhs.value; }
	|	^(SHIFT_LEFT_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "<<=" + " " + $rhs.value; }
	|	^(QUESTION a=expr b=expr c=expr)
		{ $value = $a.value + " ? " + $b.value + " : " + $c.value; }
	|	^(LOGICAL_OR lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "||" + " " + $rhs.value; }
	|	^(LOGICAL_AND lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "&&" + " " + $rhs.value; }
	|	^(OR lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "|" + " " + $rhs.value; }
	|	^(XOR lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "^" + " " + $rhs.value; }
	|	^(AND lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "&" + " " + $rhs.value; }
	|	^(EQUAL lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "==" + " " + $rhs.value; }
	|	^(NOT_EQUAL lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "!=" + " " + $rhs.value; }
	|	^(INSTANCEOF a=expr type)
		{ $value = $a.value + " instanceof " + $type.value; }
	|	^(LESS_OR_EQUAL lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "<=" + " " + $rhs.value; }
	|	^(GREATER_OR_EQUAL lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + ">=" + " " + $rhs.value; }
	|	^(BIT_SHIFT_RIGHT lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + ">>>" + " " + $rhs.value; }
	|	^(SHIFT_RIGHT lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + ">>" + " " + $rhs.value; }
	|	^(GREATER_THAN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + ">" + " " + $rhs.value; }
	|	^(SHIFT_LEFT lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "<<" + " " + $rhs.value; }
	|	^(LESS_THAN lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "<" + " " + $rhs.value; }
	|	^(PLUS lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "+" + " " + $rhs.value; }
	|	^(MINUS lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "-" + " " + $rhs.value; }
	|	^(STAR lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "*" + " " + $rhs.value; }
	|	^(DIV lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "/" + " " + $rhs.value; }
	|	^(MOD lhs=expr rhs=expr)
		{ $value = $lhs.value + " " + "\%" + " " + $rhs.value; }
	|	^(UNARY_PLUS a=expr)
		{ $value = "+" + $a.value; }
	|	^(UNARY_MINUS a=expr)
		{ $value = "-" + $a.value; }
	|	^(PRE_INC a=expr)
		{ $value = "++" + $a.value; }
	|	^(PRE_DEC a=expr)
		{ $value = "--" + $a.value; }
	|	^(POST_INC a=expr)
		{ $value = $a.value + "++"; }
	|	^(POST_DEC a=expr)
		{ $value = $a.value + "--"; }
	|	^(NOT a=expr)
		{ $value = "~" + $a.value; }
	|	^(LOGICAL_NOT a=expr)
		{ $value = "!" + $a.value; }
	|	^(CAST_EXPR type a=expr)
		{
			$value = " " + "(" + " " +
			         $type.value +
				 " " + ")" + " " + $a.value;
		}
	|	primaryExpression
	 	{ $value = $primaryExpression.value; }
	;

// }}}
    
// {{{ primaryExpression

primaryExpression returns [String value]
    :   { $value=""; }
	^(DOT ( a=primaryExpression { $value += $a.value; }
                { $value += "."; }
                (   IDENT { $value += $IDENT.text + " "; }
                |   THIS { $value += $THIS.text + " "; }
                |   SUPER { $value += $SUPER.text + " "; }
                |   innerNewExpression
		    { $value += $innerNewExpression.value + " "; }
                |   A=CLASS { $value += $A.text + " "; }
                )
              |   primitiveType { $value += $primitiveType.value + " "; }
		  B=CLASS { $value += $B.text + " "; }
              |   VOID { $value += $VOID.text + " "; }
		  C=CLASS { $value += $C.text + " "; }
              )
        )
    |   parenthesizedExpression
	{ $value = $parenthesizedExpression.value; }
    |   IDENT
	{ $value = $IDENT.text; }
    |   ^(METHOD_CALL a=primaryExpression genericTypeArgumentList? arguments)
	{
		$value = $a.value + "(" +
			 ( $genericTypeArgumentList.value != null ?
			   " " + $genericTypeArgumentList.value : "" ) + " " +
			 $arguments.value + " " + ")" + " ";
	}
    |   explicitConstructorCall
	{ $value = $explicitConstructorCall.value; }
    |   ^(ARRAY_ELEMENT_ACCESS a=primaryExpression expression)
	{ $value = $a.value + "[" + $expression.value + "]" + " "; }
    |   literal
	{ $value = $literal.value; }
    |   newExpression
	{ $value = $newExpression.value; }
    |   THIS
	{ $value = $THIS.text; }
    |   arrayTypeDeclarator
	{ $value = $arrayTypeDeclarator.value; }
    |   SUPER
	{ $value = $SUPER.text; }
    ;

// }}}
    
// {{{ explicitConstructorCall

explicitConstructorCall returns [String value]
    :   ^( THIS_CONSTRUCTOR_CALL { $value = $THIS_CONSTRUCTOR_CALL.text; }
	   ( genericTypeArgumentList
	     { $value += " " + $genericTypeArgumentList.value; } )?
	     arguments { $value += " " + $arguments.value; } )
    |   ^( SUPER_CONSTRUCTOR_CALL primaryExpression?
				  genericTypeArgumentList?
				  arguments)
	{
		$value = $SUPER_CONSTRUCTOR_CALL.text +
			 ( $primaryExpression.value != null ?
			   " " + $primaryExpression.value : "" ) +
			 ( $genericTypeArgumentList.value != null ?
			   " " + $genericTypeArgumentList.value : "" ) + " " +
			 $arguments.value;
	}
    ;

// }}}

// {{{ arrayTypeDeclarator

arrayTypeDeclarator returns [String value]
    :   ^( ARRAY_DECLARATOR { $value = $ARRAY_DECLARATOR.text + " "; }
	   ( a=arrayTypeDeclarator { $value += $a.value; }
	   | qualifiedIdentifier { $value += $qualifiedIdentifier.value; }
	   | primitiveType { $value += $primitiveType.value; }
	   )
	 )
    ;

// }}}

// {{{ newExpression

newExpression returns [String value]
    :   ^(  STATIC_ARRAY_CREATOR
            (   primitiveType
		a=newArrayConstruction
            |   genericTypeArgumentList?
		qualifiedTypeIdent
		b=newArrayConstruction
            )
        )
	{
		$value = "new" +
			 ( $primitiveType.value != null ?
			   " " + $primitiveType.value + " " + $a.value :
			   $qualifiedTypeIdent.value != null ?
			   ( $genericTypeArgumentList.value != null ?
			     " " + $genericTypeArgumentList.value : "" ) + " " +
			   $qualifiedTypeIdent.value + " " +
			   $b.value : "" );
	}
    |   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList?
				 qualifiedTypeIdent
				 arguments
				 classTopLevelScope?)
	{
		$value = "new" +
			 ( $genericTypeArgumentList.value != null ?
			   " " + $genericTypeArgumentList.value : "" ) + " " +
			 $qualifiedTypeIdent.value + " " + "(" + " " +
			 $arguments.value + " " + ")" +
			 ( $classTopLevelScope.value != null ?
			   " " + $classTopLevelScope.value : "" );
	}
    ;

// }}}

// {{{ innerNewExpression returns

// something like 'InnerType innerType = outer.new InnerType();'
innerNewExpression returns [String value]
    :   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList?
			   IDENT arguments
				 classTopLevelScope?)
	{
		$value = $CLASS_CONSTRUCTOR_CALL.text +
			 ( $genericTypeArgumentList.value != null ?
			   " " + $genericTypeArgumentList.value : "" ) + " " +
			 $IDENT.text + " " +
			 $arguments.value +
			 ( $classTopLevelScope.value != null ?
			   " " + $classTopLevelScope.value : "" );
	}
    ;

// }}}
    
// {{{ newArrayConstruction

newArrayConstruction returns [String value]
@init{ int _i = 0; }
    :   arrayDeclaratorList { $value = $arrayDeclaratorList.value + " "; }
	arrayInitializer { $value += $arrayInitializer.value; }
    |   { $value = ""; }
	( expression
	   { $value += ( _i++ == 0 ? "["+$expression.value+"]"
				   : "" + "["+$expression.value+"]" ); } )+
	( arrayDeclaratorList
	  { $value += " " + $arrayDeclaratorList.value; } )?
    ;

// }}}

// {{{ arguments

arguments returns [String value]
@init{ int _i = 0; }
    : ^( ARGUMENT_LIST { $value = ""; }
	 ( expression
	   { $value += ( _i++ == 0 ? $expression.value
				   : "," + " " + $expression.value ); } )* )
    ;

// }}}

// {{{ literal

literal returns [String value]
	:	HEX_LITERAL
	 	{ $value = $HEX_LITERAL.text; }
	|	OCTAL_LITERAL
	 	{ $value = $OCTAL_LITERAL.text; }
	|	DECIMAL_LITERAL
	 	{ $value = $DECIMAL_LITERAL.text; }
	|	FLOATING_POINT_LITERAL
	 	{ $value = $FLOATING_POINT_LITERAL.text; }
	|	CHARACTER_LITERAL
	 	{ $value = $CHARACTER_LITERAL.text; }
	|	STRING_LITERAL
	 	{ $value = $STRING_LITERAL.text; }
	|	TRUE
	 	{ $value = $TRUE.text; }
	|	FALSE
	 	{ $value = $FALSE.text; }
	|	NULL
	 	{ $value = $NULL.text; }
	;

// }}}
