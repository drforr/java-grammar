/** {{{ License
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
// }}}

tree grammar JavaTreeParser;

// {{{ options

options {
    backtrack = true; 
    memoize = true;
    tokenVocab = Java;
    ASTLabelType = CommonTree;
}

// }}}

// {{{ @header

@header {
    import java.util.Map;
    import java.util.HashMap;
    import java.math.BigInteger;
}

// }}}

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

/* Just get IfThenElse to display itself cleanly. */

// {{{ javaSource

javaSource returns [String v]
@init{ int _i = 0, _j = 0; }
	:
	^( JAVA_SOURCE
	   ( annotationList {
	     $v = $annotationList.v;
	   } )
	   ( packageDeclaration {
	     $v += " " + $packageDeclaration.v;
	   } )?
	   ( importDeclaration {
	     $v += ( _i++ == 0 ? "" : "/* javaSource 1 */" )
		 + $importDeclaration.v;
	   } )*
	   ( typeDeclaration {
	     $v += ( _j++ == 0 ? "" : "/* javaSource 2 */" )
		 + $typeDeclaration.v;
	   } )*
	 )
	;

// }}}

// {{{ packageDeclaration

packageDeclaration returns [String v]
	:
	^( ( PACKAGE {
	     $v = $PACKAGE.text;
	   } )
	   ( qualifiedIdentifier {
	     $v += $qualifiedIdentifier.v;
	   } )
	 )
	;

// }}}
    
// {{{ importDeclaration

importDeclaration returns [String v]
	:
	^( ( IMPORT {
	     $v = $IMPORT.text;
	   } )
	   ( STATIC {
	     $v += $STATIC.text;
	   } )?
	   ( qualifiedIdentifier {
	     $v += $qualifiedIdentifier.v;
	   } )
	   ( DOTSTAR {
	     $v += $DOTSTAR.text;
	   } )?
	 )
	;

// }}}
    
// {{{ typeDeclaration

typeDeclaration returns [String v]
	:
	^( ( CLASS {
	     $v = $CLASS.text;
	   } )
	   ( modifierList {
	     $v += " " + $modifierList.v;
	   } )
	   ( IDENT {
	     $v += " " + $IDENT.text;
	   } )
	   ( genericTypeParameterList {
	     $v += " " + $genericTypeParameterList.v;
	   } )?
	   ( extendsClause {
	     $v += " " + $extendsClause.v;
	   } )?
	   ( implementsClause {
	     $v += " " + $implementsClause.v;
	   } )?
	   ( classTopLevelScope {
	     $v += " " + $classTopLevelScope.v;
	   } )
	 )
	|
	^( ( INTERFACE {
	     $v = $INTERFACE.text;
	   } )
	   ( modifierList {
	     $v += $modifierList.v;
	   } )
	   ( IDENT {
	     $v += $IDENT.text;
	   } )
	   ( genericTypeParameterList {
	     $v += $genericTypeParameterList.v;
	   } )?
	   ( extendsClause {
	     $v += $extendsClause.v;
	   } )?
	   ( interfaceTopLevelScope {
	     $v += $interfaceTopLevelScope.v;
	   } )
	 )
	|
	^( ( ENUM {
	     $v = $ENUM.text;
	   } )
	   ( modifierList {
	     $v += " " + $modifierList.v;
	   } )
	   ( IDENT {
	     $v += " " + $IDENT.text;
	   } )
	   ( implementsClause {
	     $v += " " + $implementsClause.v;
	   } )?
	   ( enumTopLevelScope {
	     $v += " " + $enumTopLevelScope.v;
	   } )
	 )
	|
	^( ( AT {
	     $v = $AT.text;
	   } )
	   ( modifierList {
	     $v += " " + $modifierList.v;
	   } )
	   ( IDENT {
	     $v += " " + $IDENT.text;
	   } )
	   ( annotationTopLevelScope {
	     $v += " " + $annotationTopLevelScope.v;
	   } )
	 )
	;

// }}}

// {{{ extendsClause
// actually 'type' for classes and 'type+' for interfaces, but this has 
// been resolved by the parser grammar.

extendsClause returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( EXTENDS_CLAUSE
	   ( type {
	     $v += (_i == 0 ? "" : "/* extendsClause */" )
		 + $type.v;
	   } )+
	 )
	;

// }}}
    
// {{{ implementsClause

implementsClause returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( IMPLEMENTS_CLAUSE
	   ( type {
	     $v += ( _i == 0 ? "" : "/* implementsClause */" )
		 + $type.v;
	   } )+
	 )
	;

// }}}
        
// {{{ genericTypeParameterList

genericTypeParameterList returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( GENERIC_TYPE_PARAM_LIST
	   ( genericTypeParameter {
	     $v += ( _i == 0 ? "" : "/* genericTypeParameter */" )
		 + $genericTypeParameter.v;
	   } )+
	 )
	;

// }}}

// {{{ genericTypeParameter

genericTypeParameter returns [String v]
	:
	^( ( IDENT {
	     $v = $IDENT.text;
	   } )
	   ( bound {
	     $v += $bound.v;
	   } )?
	 )
	;

// }}}
        
// {{{ bound

bound returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( EXTENDS_BOUND_LIST
	   ( type {
	     $v += ( _i == 0 ? "" : "/* bound */" )
		 + $type.v;
	   } )+
	 )
	;

// }}}

// {{{ enumTopLevelScope

enumTopLevelScope returns [String v]
@init{ int _i = 0; }
	:
	^( ENUM_TOP_LEVEL_SCOPE
	   ( enumConstant {
	     $v += ( _i++ == 0 ? "" : "/* enumTopLevelScope */" )
		 + $enumConstant.v;
	   } )+
	   ( classTopLevelScope {
	     $v += $classTopLevelScope.v;
	   } )?
	 )
	;

// }}}
    
// {{{ enumConstant

enumConstant returns [String v]
@init{ int _i = 0; }
	:
	^( ( IDENT {
	     $v = $IDENT.text;
	   } )
	   ( annotationList {
	     $v += $annotationList.v;
	   } )
	   ( arguments {
	     $v += $arguments.v;
	   } )?
	   ( classTopLevelScope {
	     $v += $classTopLevelScope.v;
	   } )?
	 )
	;

// }}}
    
// {{{ classTopLevelScope

classTopLevelScope returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	{ $v = "{"; }
	{ $v += "\n"; }
	^( CLASS_TOP_LEVEL_SCOPE
	   ( classScopeDeclarations
	     { $v += ( _i == 0 ? "" : "/* classTopLevelScope */" )
		   + $classScopeDeclarations.v; } )*
	 )
	{ $v += "}"; }
	{ $v += "\n"; }
	;

// }}}
    
// {{{ classScopeDeclarations

classScopeDeclarations returns [String v]
	:
	^( CLASS_INSTANCE_INITIALIZER
	   ( block {
	     $v = $block.v;
	   } )?
	 )
	|
	^( CLASS_STATIC_INITIALIZER
	   ( block {
	     $v = $block.v;
	   } )?
	 )
	|
	^( FUNCTION_METHOD_DECL
	   ( modifierList {
	     $v = $modifierList.v;
	   } )
	   ( genericTypeParameterList {
	     $v += " " + $genericTypeParameterList.v;
	   } )?
	   ( type {
	     $v += $type.v;
	   } )
	   ( IDENT {
	     $v += " " + $IDENT.text;
	   } )
	   ( formalParameterList {
	     $v += " " + $formalParameterList.v;
	   } )
	   ( arrayDeclaratorList {
	     $v += $arrayDeclaratorList.v;
	   } )?
	   ( throwsClause {
	     $v += " " + $throwsClause.v;
	   } )?
	   ( block {
	     $v = $block.v;
	   } )?
	  )
	|
	^( VOID_METHOD_DECL
	   ( modifierList {
	     $v = $modifierList.v;
	   } )
	   ( genericTypeParameterList {
	     $v += " " + $genericTypeParameterList.v;
	   } )?
	   { $v += " " + "void"; }
	   ( IDENT {
	     $v += " " + $IDENT.text;
	   } )
	   ( formalParameterList {
	     $v += " " + $formalParameterList.v;
	   } )
	   ( throwsClause {
	     $v += " " + $throwsClause.v;
	   } )?
	   ( block {
	     $v += " " + $block.v;
	   } )?
	 )
	|
	^( VAR_DECLARATION
	   ( modifierList {
	     $v = $modifierList.v;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	   ( variableDeclaratorId {
	     $v += $variableDeclaratorId.v;
	   } )
	 )
	|
	^( CONSTRUCTOR_DECL
	   ( modifierList {
	     $v = $modifierList.v;
	   } )
	   ( genericTypeParameterList {
	     $v += " " + $genericTypeParameterList.v;
	   } )?
	   ( formalParameterList {
	     $v += " " + $formalParameterList.v;
	   } )
	   ( throwsClause {
	     $v += " " + $throwsClause.v;
	   } )?
	   ( block {
	     $v += " " + $block.v;
	   } )
	 )
	| ( typeDeclaration {
	    $v = $typeDeclaration.v;
	  } )
    ;

// }}}
    
// {{{ interfaceTopLevelScope

interfaceTopLevelScope returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( INTERFACE_TOP_LEVEL_SCOPE
	   ( interfaceScopeDeclarations {
	     $v += ( _i++ == 0 ? "" : "/* interfaceTopLevelScope */" )
		 + $interfaceScopeDeclarations.v;
	   } )*
	 )
	;

// }}}
    
// {{{ interfaceScopeDeclarations

interfaceScopeDeclarations returns [String v]
	:
	^( FUNCTION_METHOD_DECL
	   ( modifierList {
	     $v = $modifierList.v;
	   } )
	   ( genericTypeParameterList {
	     $v += $genericTypeParameterList.v;
	   } )?
	   ( type {
	     $v += $type.v;
	   } )
	   ( IDENT {
	     $v += $IDENT.text;
	   } )
	   ( formalParameterList {
	     $v += $formalParameterList.v;
	   } )
	   ( arrayDeclaratorList {
	     $v += $arrayDeclaratorList.v;
	   } )?
	   ( throwsClause {
	     $v += $throwsClause.v;
	   } )?
	 )
	|
	// Interface constant declarations have been switched to variable
	// declarations by 'java.g'; the parser has already checked that
	// there's an obligatory initializer.
	^( VOID_METHOD_DECL
	   ( modifierList {
	     $v = $modifierList.v;
	   } )
	   ( genericTypeParameterList {
	     $v += $genericTypeParameterList.v;
	   } )?
	   ( IDENT {
	     $v += $IDENT.text;
	   } )
	   ( formalParameterList {
	     $v += $formalParameterList.v;
	   } )
	   ( throwsClause {
	     $v += $throwsClause.v;
	   } )?
	 )
	|
	^( VAR_DECLARATION
	   ( modifierList {
	     $v = $modifierList.v;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	   ( variableDeclaratorList {
	     $v = $variableDeclaratorList.v;
	   } )
	 )
	| 
	( typeDeclaration {
	  $v = $typeDeclaration.v;
	} )
	;

// }}}

// {{{ variableDeclaratorList

variableDeclaratorList returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( VAR_DECLARATOR_LIST
	   ( variableDeclarator {
	     $v += ( _i++ == 0 ? "" : ", " )
	         + $variableDeclarator.v;
	   } )+
	 )
	;

// }}}

// {{{ variableDeclarator

variableDeclarator returns [String v]
	:
	^( VAR_DECLARATOR
	   ( variableDeclaratorId {
	     $v = $variableDeclaratorId.v;
	   } )
	   ( variableInitializer {
	     $v += " " + "=" + " " + $variableInitializer.v;
	   } )?
	 )
	;

// }}}
    
// {{{ variableDeclaratorId

variableDeclaratorId returns [String v]
	:
	^( ( IDENT {
	     $v = $IDENT.text;
	   } )
	   ( arrayDeclaratorList {
	     $v += $arrayDeclaratorList.v;
	   } )?
	 )
	;

// }}}

// {{{ variableInitializer

variableInitializer returns [String v]
	: ( arrayInitializer {
	    $v = $arrayInitializer.v;
	  } )
	| ( expression {
	    $v = $expression.v;
	  } )
	;

// }}}

// {{{ arrayDeclarator

arrayDeclarator returns [String v]
	:
	( LBRACK {
	  $v = $LBRACK.text;
	} )
	( RBRACK {
	  $v += $RBRACK.text;
	} )
	;

// }}}

// {{{ arrayDeclaratorList

arrayDeclaratorList returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( ARRAY_DECLARATOR_LIST
	   ( arrayDeclarator {
	     $v += ( _i++ == 0 ? "" : "/* arrayDeclaratorList */" )
		 + $arrayDeclarator.v;
	   } )+
	 )
	;

// }}}
    
// {{{ arrayInitializer

arrayInitializer returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	{ $v += "{"; }
	^( ARRAY_INITIALIZER
	   ( variableInitializer {
	     $v += ( _i++ == 0 ? "" : ", " )
		 + $variableInitializer.v;
	   } )*
	 )
	{ $v += "}"; }
	;

// }}}

// {{{ throwsClause

throwsClause returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( THROWS_CLAUSE
	   ( qualifiedIdentifier {
	     $v += ( _i++ == 0 ? "" : "/* throwsClause */" )
		 + $qualifiedIdentifier.v;
	   } )+
	 )
	;

// }}}

// {{{ modifierList

modifierList returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( MODIFIER_LIST
	   ( modifier {
	     $v += ( _i == 0 ? "" : "/* modifierList */" )
	 	 + $modifier.v;
	   } )*
	 )
	;

// }}}

// {{{ modifier

modifier returns [String v]
	: ( PUBLIC {
	    $v = $PUBLIC.text;
	  } )
	| ( PROTECTED {
	     $v = $PROTECTED.text;
	  } )
	| ( PRIVATE {
	     $v = $PRIVATE.text;
	  } )
	| ( STATIC {
	     $v = $STATIC.text;
	  } )
	| ( ABSTRACT {
	     $v = $ABSTRACT.text;
	  } )
	| ( NATIVE {
	     $v = $NATIVE.text;
	  } )
	| ( SYNCHRONIZED {
	     $v = $SYNCHRONIZED.text;
	  } )
	| ( TRANSIENT {
	     $v = $TRANSIENT.text;
	  } )
	| ( VOLATILE {
	     $v = $VOLATILE.text;
	  } )
	| ( STRICTFP {
	     $v = $STRICTFP.text;
	  } )
	| ( localModifier {
	     $v = $localModifier.v;
	  } )
	;

// }}}

// {{{ localModifierList

localModifierList returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( LOCAL_MODIFIER_LIST
	   ( localModifier {
	     $v += ( _i == 0 ? "" : "/* localModifierList */" )
		 + $localModifier.v;
	   } )*
	 )
	;

// }}}

// {{{ localModifier

localModifier returns [String v]
	: ( FINAL {
	    $v = $FINAL.text;
	  } )
	| ( annotation {
	    $v = $annotation.v;
	  } )
	;

// }}}

// {{{ type

type returns [String v]
	:
	^( TYPE
	   ( ( primitiveType {
	       $v = $primitiveType.v;
	     } )
	   | ( qualifiedTypeIdent {
	       $v = $qualifiedTypeIdent.v;
	     } )
	   )
	   ( arrayDeclaratorList {
	     $v += " " + $arrayDeclaratorList.v;
	   } )?
	 )
	;

// }}}

// {{{ qualifiedTypeIdent

qualifiedTypeIdent returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( QUALIFIED_TYPE_IDENT
	   ( typeIdent {
	     $v += ( _i++ == 0 ? "" : "/* qualifiedTypeIdent */" )
		 + $typeIdent.v;
	   } )+
	 )
	;

// }}}

// {{{ typeIdent

typeIdent returns [String v]
	:
	^( ( IDENT {
	     $v = $IDENT.text;
	   } )
	   ( genericTypeArgumentList {
	     $v += " " + $genericTypeArgumentList.v;
	   } )?
	 )
	;

// }}}

// {{{ primitiveType

primitiveType returns [String v]
	: ( BOOLEAN {
	    $v = $BOOLEAN.text;
	  } )
	| ( CHAR {
	    $v = $CHAR.text;
	  } )
	| ( BYTE {
	    $v = $BYTE.text;
	  } )
	| ( SHORT {
	    $v = $SHORT.text;
	  } )
	| ( INT {
	    $v = $INT.text;
	  } )
	| ( LONG {
	    $v = $LONG.text;
	  } )
	| ( FLOAT {
	    $v = $FLOAT.text;
	  } )
	| ( DOUBLE {
	    $v = $DOUBLE.text;
	  } )
	;

// }}}

// {{{ genericTypeArgumentList

genericTypeArgumentList returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( GENERIC_TYPE_ARG_LIST
	   ( genericTypeArgument {
	     $v += ( _i++ == 0 ? "" : "/* genericTypeArgumentList */" )
		 + $genericTypeArgument.v;
	   } )+
	 )
	;

// }}}
    
// {{{ genericTypeArgument

genericTypeArgument returns [String v]
	:
	( type {
	  $v = $type.v;
	} )
	|
	^( ( QUESTION {
	     $v = $QUESTION.text;
	   } )
	   ( genericWildcardBoundType {
	     $v += $genericWildcardBoundType.v;
	   } )?
 	 )
	;

// }}}

// {{{ genericWildcardBoundType

genericWildcardBoundType returns [String v]
	:
	^( ( EXTENDS {
	     $v = $EXTENDS.text;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	 )
	|
	^( ( SUPER {
	     $v = $SUPER.text;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	 )
	;

// }}}

// {{{ formalParameterList

formalParameterList returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	{ $v = "("; }
	^( FORMAL_PARAM_LIST
	   ( formalParameterStandardDecl {
	     $v += ( _i++ == 0 ? "" : "/* formalParameterList */" )
		 + $formalParameterStandardDecl.v;
	   } )*
	   ( formalParameterVarargDecl {
	     $v += $formalParameterVarargDecl.v;
	   } )?
	 )
	{ $v += ")"; }
	;

// }}}
    
// {{{ formalParameterStandardDecl
formalParameterStandardDecl returns [String v]
	:
	^( FORMAL_PARAM_STD_DECL
	   ( localModifierList {
	     $v = $localModifierList.v;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	   ( variableDeclaratorId {
	     $v += " " + $variableDeclaratorId.v;
	   } )
	 )
	;

// }}}
    
// {{{ formalParameterVarargDecl

formalParameterVarargDecl returns [String v]
	:
	^( FORMAL_PARAM_VARARG_DECL
	   ( localModifierList {
	     $v = $localModifierList.v;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	   ( variableDeclaratorId {
	     $v += $variableDeclaratorId.v;
	   } )
	 )
	;

// }}}
    
// {{{ qualifiedIdentifier

qualifiedIdentifier returns [String v]
	:
	( IDENT {
	  $v = $IDENT.text;
	} )
	|
	^( ( DOT {
	     $v = $DOT.text;
	   } )
	   ( a=qualifiedIdentifier {
	     $v += " " + $a.text;
	   } )
	   ( IDENT {
	     $v += " " + $IDENT.text;
	   } )
	 )
	;

// }}}
    
// ANNOTATIONS

// {{{ annotationList

annotationList returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( ANNOTATION_LIST
	   ( annotation {
	     $v += ( _i++ == 0 ? "" : "/* annotationList */" )
		 + $annotationList.v;
	   } )*
	 )
	;

// }}}

// {{{ annotation

annotation returns [String v]
	:
	^( ( AT {
	     $v = $AT.text;
	   } )
	   ( qualifiedIdentifier {
 	     $v += " " + $qualifiedIdentifier.v;
	   } )
	   ( annotationInit {
 	     $v += " " + $annotationInit.v;
	   } )?
	 )
	;

// }}}
    
// {{{ annotationInit

annotationInit returns [String v]
	:
	^( ANNOTATION_INIT_BLOCK
	   ( annotationInitializers {
	     $v += $annotationInitializers.v;
	   } ) ) 
	;

// }}}

// {{{ annotationInitializers

annotationInitializers returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( ANNOTATION_INIT_KEY_LIST
	   ( annotationInitializer {
	     $v += ( _i++ == 0 ? "" : "/* annotationInitializer 1 */" )
		 + $annotationInitializer.v;
	   } )+
	 )
	|
	^( ANNOTATION_INIT_DEFAULT_KEY
	   ( annotationElementValue {
	     $v += _i++ == 0 ? $annotationElementValue.v
			     : "/* annotationElementValue 1 */" + $annotationElementValue.v;
	   } )+
	 )
	;

// }}}
    
// {{{ annotationInitializer

annotationInitializer returns [String v]
	:
	^( ( IDENT {
	     $v = $IDENT.text;
	   } )
	   ( annotationElementValue {
	     $v += " " + $annotationElementValue.v;
	   } )
	 )
	;

// }}}
    
// {{{ annotationElementValue

annotationElementValue returns [String v]
	:
	^( ANNOTATION_INIT_ARRAY_ELEMENT
	   ( a=annotationElementValue {
	     $v += $a.v;
	   } )*
	 )
	|
	( annotation {
	  $v += $annotation.v;
	} )
	|
	( expression {
	  $v += $expression.v;
	} )
	;

// }}}
    
// {{{ annotationTopLevelScope

annotationTopLevelScope returns [String v]
@init{ int _i = 0; }
	:
	^( ANNOTATION_TOP_LEVEL_SCOPE
	   ( annotationScopeDeclarations {
	     $v += ( _i++ == 0 ? "" : "/* annotationTopLevelScope */" )
		 + $annotationScopeDeclarations.v;
	   } )*
	  )
	;

// }}}
    
// {{{ annotationScopeDeclarations

annotationScopeDeclarations returns [String v]
	:
	^( ANNOTATION_METHOD_DECL
	   ( modifierList {
	     $v += $modifierList.v;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	   ( IDENT {
	     $v += $IDENT.text;
	   } )
	   ( annotationDefaultValue {
	     $v += $annotationDefaultValue.v;
	   } )?
	  )
	|
	^( VAR_DECLARATION
	   ( modifierList {
	     $v += " " + $modifierList.v;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	   ( variableDeclaratorList {
	     $v += $variableDeclaratorList.v;
	   } )
	 )
	| ( typeDeclaration {
	    $v = $typeDeclaration.v;
	  } )
	;

// }}}
    
// {{{ annotationDefaultValue

annotationDefaultValue returns [String v]
	:
	^( DEFAULT
	   ( annotationElementValue {
	     $v = $annotationElementValue.v;
	   } )
	 )
	;

// }}}

// STATEMENTS / BLOCKS

// {{{ block

block returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	{ $v += "{"; }
	{ $v += "\n"; }
	^( BLOCK_SCOPE
	   ( blockStatement {
	     $v += ( _i == 0 ? "" : "/* block */" )
		  + $blockStatement.v;
// XXX Hack to suppress trailing semicolon on {}
// XXX Aha, and here's how it fails. Array initializers have trailing braces.
// XXX Time to reword the condition.
// XXX
String last = $v.substring($v.length()-1,$v.length());
//if( last != "}" ) {
if( !( $v.endsWith( "}" ) ) ) {
  $v += ";/* XXX(1) ('" + last + "') */";
}
else {
  $v += "/* XXX(1) ('}') suppressing */";
}
	   } )*
	 )
	{ $v += "}"; }
	;

// }}}
    
// {{{ blockStatement

blockStatement returns [String v]
	: ( localVariableDeclaration {
	    $v = $localVariableDeclaration.v;
	  } )
	| ( typeDeclaration {
	    $v = $typeDeclaration.v;
	  } )
	| ( statement {
	    $v = $statement.v;
	  } )
	;

// }}}
    
// {{{ localVariableDeclaration
// int i;

localVariableDeclaration returns [String v]
	:
	^( VAR_DECLARATION
	   ( localModifierList {
	     $v = $localModifierList.v;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	   { $v += " "; }
	   ( variableDeclaratorList {
	     $v += $variableDeclaratorList.v;
	   } )
	 )
	;

// }}}

// {{{ statement
        
statement returns [String v]
	: ( block {
	    $v = $block.v;
	  } )
	|
	^( ( ASSERT {
	     $v = $ASSERT.text;
	   } )
	   ( a=expression {
	     $v += $a.v;
	   } )
	   ( b=expression {
	     $v += $b.v;
	   } )?
	 )
	|
	^( ( IF {
	     $v = $IF.text;
	   } )
	   ( parenthesizedExpression {
	     $v += $parenthesizedExpression.v;
	   } )
	   ( a=statement {
	     $v += $a.v;
	   } )
{
// XXX Hack to suppress trailing semicolon on {}
String last = $v.substring($v.length()-1,$v.length());
//if( last != "}" ) {
if( !( $v.endsWith( "}" ) ) ) {
  $v += ";/* XXX(2) ('" + last + "') */";
}
}
	   ( b=statement {
	     $v += " ";
	     $v += "else";
	     $v += " ";
	     $v += $b.v;
	   } )?
	 )
	|
	^( ( FOR {
	     $v = $FOR.text;
	   } )
	   { $v += "("; }
	   ( forInit {
	     $v += $forInit.v;
	   } )
	   { $v += ";"; }
	   ( forCondition {
	     $v += $forCondition.v;
	   } )
	   { $v += ";"; }
	   ( forUpdater {
	     $v += $forUpdater.v;
	   } )
	   { $v += ")"; }
	   ( a=statement {
	     $v += $a.v;
	   } )
	 )
	|
	^( ( FOR_EACH {
	     $v = $FOR_EACH.text;
	   } )
	   ( localModifierList {
	     $v += $localModifierList.v;
	   } )
	   ( type {
	     $v += $type.v;
	   } )
	   ( IDENT {
	     $v += $IDENT.text;
	   } )
	   ( expression {
	     $v += $expression.v;
	   } )
	   ( a=statement {
	     $v += $a.v;
	   } )
	 ) 
	|
	^( ( WHILE {
	     $v = $WHILE.text;
	   } )
	   ( parenthesizedExpression {
	     $v += $parenthesizedExpression.v;
	   } )
	   ( a=statement {
	     $v += $a.v;
	   } )
	 )
	|
	^( ( DO {
	     $v = $DO.text;
	   } )
	   ( a=statement {
	     $v += " " + $a.v;
// XXX Hack to suppress trailing semicolon on {}
String last = $v.substring($v.length()-1,$v.length());
//if( last != "}" ) {
if( !( $v.endsWith( "}" ) ) ) {
  $v += ";/* XXX(1) ('" + last + "') */";
}
	   } )
	   { $v += " " + "while" + " "; }
	   ( parenthesizedExpression {
	     $v += $parenthesizedExpression.v;
	   } )
	 )
	|
	// The second optional block is the optional finally block.
	^( ( TRY {
	     $v = $TRY.text;
	   } )
	   ( a=block {
	     $v += $a.v;
	   } )
	   ( catches {
	     $v += $catches.v;
	   } )?
	   ( b=block {
	     $v += $b.v;
	   } )?
	 )
	|
	^( ( SWITCH {
	     $v = $SWITCH.text;
	   } )
	   ( parenthesizedExpression {
	     $v += $parenthesizedExpression.v;
	   } )
	   ( switchBlockLabels {
	     $v += $switchBlockLabels.v;
	   } )
	 )
	|
	^( ( SYNCHRONIZED {
	     $v = $SYNCHRONIZED.text;
	   } )
	   ( parenthesizedExpression {
	     $v += $parenthesizedExpression.v;
	   } )
	   ( block {
	     $v += $block.v;
	   } )
	 )
	|
	^( ( RETURN {
	     $v = $RETURN.text;
	   } )
	   ( expression {
	     $v += $expression.v;
	   } )?
	 )
	|
	^( ( THROW {
	     $v = $THROW.text;
	   } )
	   ( expression {
	     $v += $expression.v;
	   } )
	 )
	|
	^( ( BREAK {
	     $v = $BREAK.text;
	   } )
	   ( IDENT {
	     $v += $IDENT.text;
	   } )?
	 )
	|
	^( ( CONTINUE {
	     $v = $CONTINUE.text;
	   } )
	   ( IDENT {
	     $v += $IDENT.text;
	   } )?
	 )
	|
	^( ( LABELED_STATEMENT {
	     $v = $LABELED_STATEMENT.text;
	   } )
	   ( IDENT {
	     $v += $IDENT.text;
	   } )
	   ( a=statement {
	     $v += $a.v;
	   } )
	 )
	| ( expression {
	    $v = $expression.v;
	  } )
	| ( SEMI {
	    $v = $SEMI.text;
	  } ) // Empty statement.
	;

// }}}
        
// {{{ catches

catches returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( CATCH_CLAUSE_LIST
	   ( catchClause {
	     $v += ( _i == 0 ? "" : "/* catches */" )
		 + $catchClause.v;
	   } )+
	 )
	;

// }}}
    
// {{{ catchClause

catchClause returns [String v]
	:
	^( ( CATCH {
	     $v = $CATCH.text;
	   } )
	   ( formalParameterStandardDecl {
	     $v += $formalParameterStandardDecl.v;
	   } )
	   ( block {
	     $v += $block.v;
	   } )
	 )
	;

// }}}

// {{{ switchBlockLabels

switchBlockLabels returns [String v]
@init{ int _i = 0, _j = 0; }
	: { $v = ""; }
	^( SWITCH_BLOCK_LABEL_LIST
	   ( a=switchCaseLabel {
	     $v += ( _i++ == 0 ? "" : "/* switchBlockLabels */" )
		 + $a.v;
	   } )*
	   ( switchDefaultLabel {
	     $v += $switchDefaultLabel.v;
	   } )?
	   ( b=switchCaseLabel {
	     $v += ( _j++ == 0 ? "" : "/* switchBlockLabels */" )
		 + $b.v;
	   } )*
	 )
	;

// }}}
        
// {{{ switchCaseLabel

switchCaseLabel returns [String v]
@init{ int _i = 0; }
	:
	^( ( CASE {
	     $v = $CASE.text;
	   } )
	   ( expression {
	     $v += $expression.v;
	   } )
	   ( blockStatement {
	     $v += ( _i == 0 ? "" : "/* switchCaseLabel */" )
		 + $blockStatement.v;
	   } )*
	 )
	;

// }}}

// {{{ switchDefaultLabel

switchDefaultLabel returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( DEFAULT
	   ( blockStatement {
	     $v += ( _i == 0 ? "" : "/* switchDefaultLabel */" )
		 + $blockStatement.v;
	   } )*
	 )
	;

// }}}
    
// {{{ forInit

forInit returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( FOR_INIT
	   ( ( localVariableDeclaration {
	       $v = $localVariableDeclaration.v;
	     } )
	   | ( expression {
	       $v += ( _i++ == 0 ? "" : "/* forInit */" )
		   + $expression.v;
	     } )*
	   )? 
	 )
	;

// }}}
    
// {{{ forCondition

forCondition returns [String v]
	: { $v = ""; }
	^( FOR_CONDITION
	   ( expression {
	     $v += $expression.v;
	   } )?
	 )
	;

// }}}

// {{{ forUpdater

forUpdater returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	^( FOR_UPDATE
	   ( expression {
	     $v += ( _i == 0 ? "" : "/* forUpdater */" )
		 + $expression.v;
	   } )*
	 )
	;

// }}}
    
// EXPRESSIONS

// {{{ parenthesizedExpression

parenthesizedExpression returns [String v]
	:
	{ $v = "("; }
	^( PARENTESIZED_EXPR
	   ( expression {
	     $v += $expression.v;
	   } )
	 )
	{ $v += ")"; }
	;

// }}}
    
// {{{ expression

expression returns [String v]
	:
	^( EXPR
	   ( expr {
	     $v = $expr.v;
	   } )
	 )
	;

// }}}

// {{{ expr

expr returns [String v]
	:
	^( ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( PLUS_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "+="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( MINUS_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "-="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( STAR_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "*="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( DIV_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "/="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( AND_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "&="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( OR_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "|="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( XOR_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "^="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( MOD_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "\%="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( BIT_SHIFT_RIGHT_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += ">>>="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( SHIFT_RIGHT_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += ">>="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( SHIFT_LEFT_ASSIGN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "<<="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^(QUESTION a=expr b=expr c=expr)
		{ $v = $a.v + " ? " + $b.v + " : " + $c.v; }
	|
	^( LOGICAL_OR
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "||"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( LOGICAL_AND
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "&&"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( OR
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "|"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( XOR
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "^"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( AND
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "&"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( EQUAL
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "=="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( NOT_EQUAL
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "!="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( LESS_OR_EQUAL
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "instanceof"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( LESS_OR_EQUAL
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "<="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( GREATER_THAN_OR_EQUAL
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += ">="; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( BIT_SHIFT_RIGHT
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += ">>>"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( SHIFT_RIGHT
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += ">>"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( GREATER_THAN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += ">"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( SHIFT_LEFT
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "<<"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( LESS_THAN
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "<"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( PLUS
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "+"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( MINUS
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "-"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( STAR
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "*"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( DIV
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "/"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( MOD
	   ( lhs=expr {
	     $v = $lhs.v;
	   } )
	   { $v += " "; }
	   { $v += "\%"; }
	   { $v += " "; }
	   ( rhs=expr {
	     $v += $rhs.v;
	   } )
	 )
	|
	^( UNARY_PLUS
	   ( a=expr {
	     $v = "+" + $a.v;
	   } )
	 )
	|
	^( UNARY_MINUS
	   ( a=expr {
	     $v = "-" + $a.v;
	   } )
	 )
	|
	^( PRE_INC
	   ( a=expr {
	     $v = "++" + $a.v;
	   } )
	 )
	|
	^( PRE_DEC
	   ( a=expr {
	     $v = "--" + $a.v;
	   } )
	 )
	|
	^( POST_INC
	   ( a=expr {
	     $v = $a.v + "++";
	   } )
	 )
	|
	^( POST_DEC
	   ( a=expr {
	     $v = $a.v + "--";
	   } )
	 )
	|
	^( NOT
	   ( a=expr {
	     $v = "~" + $a.v;
	   } )
	 )
	|
	^( LOGICAL_NOT
	   ( a=expr {
	     $v = "!" + $a.v;
	   } )
	 )
	|
	^( CAST_EXPR type a=expr
		{
			$v = " " + "(" + " " +
			         $type.v +
				 " " + ")" + " " + $a.v;
		}
	 )
	|
	( primaryExpression {
	  $v = $primaryExpression.v;
	} )
	;

// }}}

// {{{ primaryExpression

primaryExpression returns [String v]
	:
	^( ( DOT {
	     $v = $DOT.text;
	   } )
           ( ( a=primaryExpression {
	       $v += $a.v;
	     } )
             ( ( IDENT {
	         $v += $IDENT.text;
	       } )
             | ( THIS {
	         $v += $THIS.text;
	       } )
             | ( SUPER {
	         $v += $SUPER.text;
	       } )
             | ( innerNewExpression {
	         $v += $innerNewExpression.v;
	       } )
             | ( A=CLASS {
	         $v += $A.text;
	       } )
             )
           | ( primitiveType {
	       $v += $primitiveType.v;
	     } )
             ( B=CLASS {
	       $v += $B.text;
	     } )
           | ( VOID {
	       $v += $VOID.text;
	     } )
             ( C=CLASS {
	       $v += $C.text;
	     } )
           )
        )
	| ( parenthesizedExpression {
	    $v = $parenthesizedExpression.v;
	  } )
	| ( IDENT {
	    $v = $IDENT.text;
	  } )
	|
	^( METHOD_CALL
	   ( a=primaryExpression {
	     $v = $a.v;
	   } )
	   ( genericTypeArgumentList {
	     $v += $genericTypeArgumentList.v;
	   } )?
	   ( arguments {
	     $v += $arguments.v;
	   } )
	 )
	| ( explicitConstructorCall {
	    $v = $explicitConstructorCall.v;
	  } )
	|
	^( ARRAY_ELEMENT_ACCESS
	   ( a=primaryExpression {
	     $v = $a.v;
	   } )
	   ( expression {
	     $v+="[";
	     $v += $expression.v;
	     $v+="]";
	   } )
	 )
	| ( literal {
	    $v = $literal.v;
	  } )
	| ( newExpression {
	    $v = $newExpression.v;
	  } )
	| ( THIS {
	    $v = $THIS.text;
	  } )
	| ( arrayTypeDeclarator {
	    $v = $arrayTypeDeclarator.v;
	  } )
	| ( SUPER {
	    $v = $SUPER.text;
	  } )
    ;

// }}}
    
// {{{ explicitConstructorCall

explicitConstructorCall returns [String v]
	:
	^( THIS_CONSTRUCTOR_CALL
	   ( genericTypeArgumentList {
	     $v += $genericTypeArgumentList.v;
	   } )?
	   ( arguments {
	     $v += $arguments.v;
	   } )
	 )
	|
	^( SUPER_CONSTRUCTOR_CALL
	   ( primaryExpression {
	     $v += $primaryExpression.v;
	   } )?
	   ( genericTypeArgumentList {
	     $v += $genericTypeArgumentList.v;
	   } )?
	   ( arguments {
	     $v += $arguments.v;
	   } )
	 )
	;

// }}}

// {{{ arrayTypeDeclarator

arrayTypeDeclarator returns [String v]
	:
	^( ARRAY_DECLARATOR
	   ( ( a=arrayTypeDeclarator {
	       $v = $a.v;
	     } )
	   | ( qualifiedIdentifier {
	       $v = $qualifiedIdentifier.v;
	     } )
	   | ( primitiveType {
	       $v = $primitiveType.v;
	     } )
	   )
	 )
	;

// }}}

// {{{ newExpression

newExpression returns [String v]
	:
	^( STATIC_ARRAY_CREATOR
	   ( ( primitiveType {
	       $v = $primitiveType.v;
	     } )
	     ( a=newArrayConstruction {
	       $v += $a.v;
	     } )
	   | ( genericTypeArgumentList {
	       $v = $genericTypeArgumentList.v;
	     } )?
	     ( qualifiedTypeIdent {
	       $v += $qualifiedTypeIdent.v;
	     } )
	     ( b=newArrayConstruction {
	       $v += $b.v;
	     } )
	   )
	 )
	|
	^( CLASS_CONSTRUCTOR_CALL
	   ( genericTypeArgumentList {
	     $v = $genericTypeArgumentList.v;
	   } )?
	   ( qualifiedTypeIdent {
	     $v += $qualifiedTypeIdent.v;
	   } )
	   ( arguments {
	     $v += $arguments.v;
	   } )
	   ( classTopLevelScope {
	     $v += $classTopLevelScope.v;
	   } )?
	 )
	;

// }}}

// {{{ innerNewExpression
// something like 'InnerType innerType = outer.new InnerType();'

innerNewExpression returns [String v]
	: { $v = ""; }
	^( CLASS_CONSTRUCTOR_CALL
	   ( genericTypeArgumentList {
	     $v += " " + $genericTypeArgumentList.v;
	   } )?
	   ( IDENT {
	     $v += $IDENT.text;
	   } )
	   ( arguments {
	     $v += $arguments.v;
	   } )
	   ( classTopLevelScope {
	     $v += " " + $classTopLevelScope.v;
	   } )?
	 )
	;

// }}}
    
// {{{ newArrayConstruction

newArrayConstruction returns [String v]
@init{ int _i = 0; }
	: ( arrayDeclaratorList {
	    $v = $arrayDeclaratorList.v;
	  } )
	  ( arrayInitializer {
	    $v = $arrayInitializer.v;
	  } )
	  { $v += ";"; }
	| { $v = ""; }
	  ( expression {
	    $v += ( _i++ == 0 ? "" : "/* newArrayConstruction */" )
		+ $expression.v;
	  } )+
	  ( arrayDeclaratorList {
	    $v += $arrayDeclaratorList.v;
	  } )?
	;

// }}}

// {{{ arguments

arguments returns [String v]
@init{ int _i = 0; }
	: { $v = ""; }
	{ $v += "("; }
	^( ARGUMENT_LIST
	   ( expression {
	     $v += ( _i++ == 0 ? "" : "/* arguments */" )
		 + $expression.v;
	   } )*
	 )
	{ $v += ")"; }
	;

// }}}

// {{{ literal

literal returns [String v]
	: ( HEX_LITERAL {
	    $v = $HEX_LITERAL.text;
	  } )
	| ( OCTAL_LITERAL {
	    $v = $OCTAL_LITERAL.text;
	  } )
	| ( DECIMAL_LITERAL {
	    $v = $DECIMAL_LITERAL.text;
	  } )
	| ( FLOATING_POINT_LITERAL {
	    $v = $FLOATING_POINT_LITERAL.text;
	  } )
	| ( CHARACTER_LITERAL {
	    $v = $CHARACTER_LITERAL.text;
	  } )
	| ( STRING_LITERAL {
	    $v = $STRING_LITERAL.text;
	  } )
	| ( TRUE {
	    $v = $TRUE.text;
	  } )
	| ( FALSE {
	    $v = $FALSE.text;
	  } )
	| ( NULL {
	    $v = $NULL.text;
	  } )
	;

// }}}
