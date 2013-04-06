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
  public JavaTreeParser( CommonTreeNodeStream nodes,
                         List<CommonTree> functionDefinitions ) {
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
  public void enableErrorMessageCollection( boolean pNewState ) {
    mMessageCollectionEnabled = pNewState;
    if ( mMessages == null && mMessageCollectionEnabled ) {
      mMessages = new ArrayList<String>( );
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
  public void emitErrorMessage( String pMessage ) {
    if ( mMessageCollectionEnabled ) {
      mMessages.add( pMessage );
    } else {
      super.emitErrorMessage( pMessage );
    }
  }
  
  /**
   *  Returns collected error messages.
   *
   *  @return  A list holding collected error messages or <code>null</code> if
   *           collecting error messages hasn't been enabled. Of course, this
   *           list may be empty if no error message has been emited.
   */
  public List<String> getMessages( ) {
    return mMessages;
  }
  
  /**
   *  Tells if parsing a Java source has caused any error messages.
   *
   *  @return  <code>true</code> if parsing a Java source has caused at
   *           least one error message.
   */
  public boolean hasErrors( ) {
    return mHasErrors;
  }
}

// }}}

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
	   ( interfaceTopLevelScope {
	     $v += " " + $interfaceTopLevelScope.v;
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
	:
	{ $v = ""; }
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
	:
	{ $v = ""; }
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
	:
	{ $v = ""; }
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
	:
	{ $v = ""; }
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
	:
	{ $v = "{"; }
	{ $v += "\n"; }
	^( CLASS_TOP_LEVEL_SCOPE
	   ( classScopeDeclarations
	     { $v += ( _i == 0 ? "" : "/* classTopLevelScope */" )
		   + $classScopeDeclarations.v; } )*
	 )
	{ $v += "\n"; }
	{ $v += "}"; }
	{ $v += "\n"; }
	;

// }}}
    
// {{{ classScopeDeclarations

classScopeDeclarations returns [String v]
	:
	^( CLASS_INSTANCE_INITIALIZER
	   ( block {
	     $v = $block.s.string;
	   } )?
	 )
	|
	^( CLASS_STATIC_INITIALIZER
	   ( block {
	     $v = $block.s.string;
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
	     $v += " " + $type.v;
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
	     $v += " " + $block.s.string;
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
	     $v += " " + $block.s.string;
	   } )?
	 )
	|
	^( VAR_DECLARATION // XXX public int aTest = 42;
	   ( modifierList {
	     $v = $modifierList.v;
	   } )
	   ( type {
	     $v += " " + $type.v;
	   } )
	   ( variableDeclaratorList {
	     $v += " " + $variableDeclaratorList.v;
	   } )
	   { $v += ";" + "\n"; }
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
	     $v += " " + $block.s.string;
	   } )
	 )
	|
	( typeDeclaration {
	  $v = $typeDeclaration.v;
	} )
    ;

// }}}
    
// {{{ interfaceTopLevelScope

interfaceTopLevelScope returns [String v]
@init{ int _i = 0; }
	:
	{ $v = ""; }
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
	:
	{ $v = ""; }
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
	     $v += " " + $arrayDeclaratorList.v;
	   } )?
	 )
	;

// }}}

// {{{ variableInitializer

variableInitializer returns [String v]
	:
	( arrayInitializer {
	  $v = $arrayInitializer.v;
	} )
	|
	( expression {
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
	:
	{ $v = ""; }
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
	:
	{ $v = "{"; }
	{ $v += " "; }
	^( ARRAY_INITIALIZER
	   ( variableInitializer {
	     $v += ( _i++ == 0 ? "" : ", " )
		 + $variableInitializer.v;
	   } )*
	 )
	{ $v += " "; }
	{ $v += "}"; }
	;

// }}}

// {{{ throwsClause

throwsClause returns [String v]
@init{ int _i = 0; }
	:
	{ $v = ""; }
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
	:
	{ $v = ""; }
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
	:
	( PUBLIC {
	  $v = $PUBLIC.text;
	} )
	|
	( PROTECTED {
	  $v = $PROTECTED.text;
	} )
	|
	( PRIVATE {
	  $v = $PRIVATE.text;
	} )
	|
	( STATIC {
	  $v = $STATIC.text;
	} )
	|
	( ABSTRACT {
	  $v = $ABSTRACT.text;
	} )
	|
	( NATIVE {
	  $v = $NATIVE.text;
	} )
	|
	( SYNCHRONIZED {
	  $v = $SYNCHRONIZED.text;
	} )
	|
	( TRANSIENT {
	  $v = $TRANSIENT.text;
	} )
	|
	( VOLATILE {
	  $v = $VOLATILE.text;
	} )
	|
	( STRICTFP {
	  $v = $STRICTFP.text;
	} )
	|
	( localModifier {
	  $v = $localModifier.v;
	} )
	;

// }}}

// {{{ localModifierList

localModifierList returns [String v]
@init{ int _i = 0; }
	:
	{ $v = ""; }
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
	:
	( FINAL {
	  $v = $FINAL.text;
	} )
	|
	( annotation {
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
	:
	{ $v = ""; }
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
	:
	( BOOLEAN {
	  $v = $BOOLEAN.text;
	} )
	|
	( CHAR {
	  $v = $CHAR.text;
	} )
	|
	( BYTE {
	  $v = $BYTE.text;
	} )
	|
	( SHORT {
	  $v = $SHORT.text;
	} )
	|
	( INT {
	  $v = $INT.text;
	} )
	|
	( LONG {
	  $v = $LONG.text;
	} )
	|
	( FLOAT {
	  $v = $FLOAT.text;
	} )
	|
	( DOUBLE {
	  $v = $DOUBLE.text;
	} )
	;

// }}}

// {{{ genericTypeArgumentList

genericTypeArgumentList returns [String v]
@init{ int _i = 0; }
	:
	{ $v = ""; }
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
	:
	{ $v = "("; }
	{ $v += " "; }
	^( FORMAL_PARAM_LIST
	   ( formalParameterStandardDecl {
	     $v += ( _i++ == 0 ? "" : "/* formalParameterList */" )
		 + $formalParameterStandardDecl.v;
	   } )*
	   ( formalParameterVarargDecl {
	     $v += $formalParameterVarargDecl.v;
	   } )?
	 )
	{ $v += " "; }
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
	   ( aQualifiedIdentifier=qualifiedIdentifier {
	     $v += " " + $aQualifiedIdentifier.text;
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
	:
	{ $v = ""; }
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
	:
	{ $v = ""; }
	^( ANNOTATION_INIT_KEY_LIST
	   ( annotationInitializer {
	     $v += ( _i++ == 0 ? "" : "/* annotationInitializer 1 */" )
		 + $annotationInitializer.v;
	   } )+
	 )
	|
	^( ANNOTATION_INIT_DEFAULT_KEY
	   ( annotationElementValue {
	     $v += ( _i++ == 0 ? "" : "/* annotationElementValue 1 */" )
		 + $annotationElementValue.v;
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
	   ( aAnnotationElementValue=annotationElementValue {
	     $v += $aAnnotationElementValue.v;
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
	|
	( typeDeclaration {
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

block returns [Statement s]
@init{ int _i = 0; }
	:
	{ $s = new Statement();
$s.id = 1;
	  $s.string = "";
	}
	{ $s.string += "{"; }
	{ $s.string += "\n"; }
	^( BLOCK_SCOPE
	   ( blockStatement {
	     $s.string += ( _i == 0 ? "" : "/* block */" )
		  + $blockStatement.s.string;


$s.string +=
  ( $blockStatement.s.id == 2 ? ";" : "" ) +
  ( $blockStatement.s.id == 9 ? ";" : "" ) + // while ( j++ ) i++; // The 'i++'
  ( $blockStatement.s.id == 10 ? ";" : "" ) + // while ( j++ )
  ( $blockStatement.s.id == 14 ? ";" : "" ) +
  ( $blockStatement.s.id == 19 ? ";" : "" ) +
  ( $blockStatement.s.id == 21 ? ";" : "" ) +
  "/* 1 (" + $blockStatement.s.id + ") */";


	   } )*
	 )
	{ $s.string += "\n"; }
	{ $s.string += "}"; }
	{ $s.string += "\n"; }
	;

// }}}
    
// {{{ blockStatement

blockStatement returns [Statement s]
	:
	( localVariableDeclaration { // XXX 'int i = 40;'
	  $s = new Statement();
          $s.id = 2;
	  $s.string = $localVariableDeclaration.v;
	} )
	|
	( typeDeclaration {
	  $s = new Statement();
$s.id = 3;
	  $s.string = $typeDeclaration.v;
	} )
	|
	( statement {
	  $s = new Statement();
//$s.id = 4;
	  $s.string = $statement.s.string;
$s.id = $statement.s.id;
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
        
statement returns [Statement s]
	:
	( block {
	  $s = new Statement();
$s.id = 5;
	  $s.string = $block.s.string;
	} )
	|
	^( ( ASSERT {
	     $s = new Statement();
$s.id = 6;
	     $s.string = $ASSERT.text;
	   } )
	   ( aExpression=expression {
	     $s.string += $aExpression.v;
	   } )
	   ( bExpression=expression {
	     $s.string += $bExpression.v;
	   } )?
	 )
	|
	^( ( IF {
	     $s = new Statement();
$s.id = 7;
	     $s.string = $IF.text;
	   } )
	   ( parenthesizedExpression {
	     $s.string += $parenthesizedExpression.v;
	   } )
	   ( cStatement=statement {
	     $s.string += $cStatement.s.string;
	   } )
{
$s.string +=
  // XXX Not id=5, that's the block
  // XXX not id=14, while it 
  ( $cStatement.s.id == 14 ? ";" : "" ) +
  "/* 2 (" + $cStatement.s.id + ") */";

}
	   ( dStatement=statement {
	     $s.string += " ";
	     $s.string += "else";
	     $s.string += " ";
	     $s.string += $dStatement.s.string;
$s.string +=
  // XXX Not id=5, that's the block
  // XXX not id=14, while it 
  ( $dStatement.s.id == 14 ? ";" : "" ) +
  "/* 3 (" + $dStatement.s.id + ") */";
	   } )?
	 )
	|
	^( ( FOR {
	     $s = new Statement();
$s.id = 21;
	     $s.string = $FOR.text;
	   } )
	   { $s.string += "("; }
	   ( forInit {
	     $s.string += $forInit.v;
	   } )
	   { $s.string += ";"; }
	   ( forCondition {
	     $s.string += $forCondition.v;
	   } )
	   { $s.string += ";"; }
	   ( forUpdater {
	     $s.string += $forUpdater.v;
	   } )
	   { $s.string += ")"; }
	   ( eStatement=statement {
	     $s.string += $eStatement.s.string;
	   } )
	 )
	|
	^( ( FOR_EACH {
	     $s = new Statement();
$s.id = 8;
	     $s.string = $FOR_EACH.text;
	   } )
	   ( localModifierList {
	     $s.string += $localModifierList.v;
	   } )
	   ( type {
	     $s.string += $type.v;
	   } )
	   ( IDENT {
	     $s.string += $IDENT.text;
	   } )
	   ( expression {
	     $s.string += $expression.v;
	   } )
	   ( fStatement=statement {
	     $s.string += $fStatement.s.string;
	   } )
	 ) 
	|
	^( ( WHILE {
	     $s = new Statement();
$s.id = 9;
	     $s.string = $WHILE.text;
	   } )
	   ( parenthesizedExpression {
	     $s.string += $parenthesizedExpression.v;
	   } )
	   ( gStatement=statement {
	     $s.string += $gStatement.s.string;
	   } )
	 )
	|
	^( ( DO {
	     $s = new Statement();
$s.id = 10;
	     $s.string = $DO.text;
	   } )
	   ( hStatement=statement {
	     $s.string += " " + $hStatement.s.string;
$s.string +=
  ( $hStatement.s.id == 19 ? ";" : "" ) +
  "/* 4 (" + $hStatement.s.id + ") */";
	   } )
	   { $s.string += " " + "while" + " "; }
	   ( parenthesizedExpression {
	     $s.string += $parenthesizedExpression.v;
	   } )
	 )
	|
	// The second optional block is the optional finally block.
	^( ( TRY {
	     $s = new Statement();
$s.id = 11;
	     $s.string = $TRY.text;
	   } )
	   ( iBlock=block {
	     $s.string += $iBlock.s.string;
	   } )
	   ( catches {
	     $s.string += $catches.v;
	   } )?
	   ( jBlock=block {
	     $s.string += $jBlock.s.string;
	   } )?
	 )
	|
	^( ( SWITCH {
	     $s = new Statement();
$s.id = 12;
	     $s.string = $SWITCH.text;
	   } )
	   ( parenthesizedExpression {
	     $s.string += $parenthesizedExpression.v;
	   } )
	   ( switchBlockLabels {
	     $s.string += $switchBlockLabels.v;
	   } )
	 )
	|
	^( ( SYNCHRONIZED {
	     $s = new Statement();
$s.id = 13;
	     $s.string = $SYNCHRONIZED.text;
	   } )
	   ( parenthesizedExpression {
	     $s.string += $parenthesizedExpression.v;
	   } )
	   ( block {
	     $s.string += $block.s.string;
	   } )
	 )
	|
	^( ( RETURN { // XXX 'return 0;'
	     $s = new Statement();
             $s.id = 14;
	     $s.string = $RETURN.text;
	   } )
	   ( expression {
	     $s.string += " " + $expression.v;
	   } )?
	 )
	|
	^( ( THROW {
	     $s = new Statement();
$s.id = 15;
	     $s.string = $THROW.text;
	   } )
	   ( expression {
	     $s.string += $expression.v;
	   } )
	 )
	|
	^( ( BREAK {
	     $s = new Statement();
$s.id = 16;
	     $s.string = $BREAK.text;
	   } )
	   ( IDENT {
	     $s.string += $IDENT.text;
	   } )?
	 )
	|
	^( ( CONTINUE {
	     $s = new Statement();
$s.id = 17;
	     $s.string = $CONTINUE.text;
	   } )
	   ( IDENT {
	     $s.string += $IDENT.text;
	   } )?
	 )
	|
	^( ( LABELED_STATEMENT {
	     $s = new Statement();
$s.id = 18;
	     $s.string = $LABELED_STATEMENT.text;
	   } )
	   ( IDENT {
	     $s.string += $IDENT.text;
	   } )
	   ( kStatement=statement {
	     $s.string += $kStatement.s.string;
	   } )
	 )
	|
	( expression {
	  $s = new Statement();
$s.id = 19;
	  $s.string = $expression.v;
	} )
	|
	( SEMI { // Empty statement.
	  $s = new Statement();
$s.id = 20;
	  $s.string = $SEMI.text;
	} )
	;

// }}}
        
// {{{ catches

catches returns [String v]
@init{ int _i = 0; }
	:
	{ $v = ""; }
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
	     $v += $block.s.string;
	   } )
	 )
	;

// }}}

// {{{ switchBlockLabels

switchBlockLabels returns [String v]
@init{ int _i = 0, _j = 0; }
	:
	{ $v = ""; }
	^( SWITCH_BLOCK_LABEL_LIST
	   ( aSwitchCaseLabel=switchCaseLabel {
	     $v += ( _i++ == 0 ? "" : "/* switchBlockLabels */" )
		 + $aSwitchCaseLabel.v;
	   } )*
	   ( switchDefaultLabel {
	     $v += $switchDefaultLabel.v;
	   } )?
	   ( bSwitchCaseLabel=switchCaseLabel {
	     $v += ( _j++ == 0 ? "" : "/* switchBlockLabels */" )
		 + $bSwitchCaseLabel.v;
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
		 + $blockStatement.s.string;
	   } )*
	 )
	;

// }}}

// {{{ switchDefaultLabel

switchDefaultLabel returns [String v]
@init{ int _i = 0; }
	:
	{ $v = ""; }
	^( DEFAULT
	   ( blockStatement {
	     $v += ( _i == 0 ? "" : "/* switchDefaultLabel */" )
		 + $blockStatement.s.string;
	   } )*
	 )
	;

// }}}
    
// {{{ forInit

forInit returns [String v]
@init{ int _i = 0; }
	:
	{ $v = ""; }
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
	:
	{ $v = ""; }
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
	:
	{ $v = ""; }
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
	   ( aExpr=expr {
	     $v = $aExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "="; }
	   { $v += " "; }
	   ( bExpr=expr {
	     $v += $bExpr.v;
	   } )
	 )
	|
	^( PLUS_ASSIGN
	   ( cExpr=expr {
	     $v = $cExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "+="; }
	   { $v += " "; }
	   ( dExpr=expr {
	     $v += $dExpr.v;
	   } )
	 )
	|
	^( MINUS_ASSIGN
	   ( eExpr=expr {
	     $v = $eExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "-="; }
	   { $v += " "; }
	   ( fExpr=expr {
	     $v += $fExpr.v;
	   } )
	 )
	|
	^( STAR_ASSIGN
	   ( gExpr=expr {
	     $v = $gExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "*="; }
	   { $v += " "; }
	   ( hExpr=expr {
	     $v += $hExpr.v;
	   } )
	 )
	|
	^( DIV_ASSIGN
	   ( iExpr=expr {
	     $v = $iExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "/="; }
	   { $v += " "; }
	   ( jExpr=expr {
	     $v += $jExpr.v;
	   } )
	 )
	|
	^( AND_ASSIGN
	   ( kExpr=expr {
	     $v = $kExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "&="; }
	   { $v += " "; }
	   ( lExpr=expr {
	     $v += $lExpr.v;
	   } )
	 )
	|
	^( OR_ASSIGN
	   ( mExpr=expr {
	     $v = $mExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "|="; }
	   { $v += " "; }
	   ( nExpr=expr {
	     $v += $nExpr.v;
	   } )
	 )
	|
	^( XOR_ASSIGN
	   ( oExpr=expr {
	     $v = $oExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "^="; }
	   { $v += " "; }
	   ( pExpr=expr {
	     $v += $pExpr.v;
	   } )
	 )
	|
	^( MOD_ASSIGN
	   ( qExpr=expr {
	     $v = $qExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "\%="; }
	   { $v += " "; }
	   ( rExpr=expr {
	     $v += $rExpr.v;
	   } )
	 )
	|
	^( BIT_SHIFT_RIGHT_ASSIGN
	   ( sExpr=expr {
	     $v = $sExpr.v;
	   } )
	   { $v += " "; }
	   { $v += ">>>="; }
	   { $v += " "; }
	   ( tExpr=expr {
	     $v += $tExpr.v;
	   } )
	 )
	|
	^( SHIFT_RIGHT_ASSIGN
	   ( uExpr=expr {
	     $v = $uExpr.v;
	   } )
	   { $v += " "; }
	   { $v += ">>="; }
	   { $v += " "; }
	   ( vExpr=expr {
	     $v += $vExpr.v;
	   } )
	 )
	|
	^( SHIFT_LEFT_ASSIGN
	   ( wExpr=expr {
	     $v = $wExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "<<="; }
	   { $v += " "; }
	   ( xExpr=expr {
	     $v += $xExpr.v;
	   } )
	 )
	|
	^( QUESTION
	   ( yExpr=expr {
	     $v = $yExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "?"; }
	   { $v += " "; }
	   ( zExpr=expr {
	     $v += $zExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "?"; }
	   { $v += " "; }
	   ( aaExpr=expr {
	     $v += $aaExpr.v;
	   } )
	 )
	|
	^( LOGICAL_OR
	   ( abExpr=expr {
	     $v = $abExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "||"; }
	   { $v += " "; }
	   ( acExpr=expr {
	     $v += $acExpr.v;
	   } )
	 )
	|
	^( LOGICAL_AND
	   ( adExpr=expr {
	     $v = $adExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "&&"; }
	   { $v += " "; }
	   ( aeExpr=expr {
	     $v += $aeExpr.v;
	   } )
	 )
	|
	^( OR
	   ( afExpr=expr {
	     $v = $afExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "|"; }
	   { $v += " "; }
	   ( agExpr=expr {
	     $v += $agExpr.v;
	   } )
	 )
	|
	^( XOR
	   ( ahExpr=expr {
	     $v = $ahExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "^"; }
	   { $v += " "; }
	   ( aiExpr=expr {
	     $v += $aiExpr.v;
	   } )
	 )
	|
	^( AND
	   ( ajExpr=expr {
	     $v = $ajExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "&"; }
	   { $v += " "; }
	   ( akExpr=expr {
	     $v += $akExpr.v;
	   } )
	 )
	|
	^( EQUAL
	   ( alExpr=expr {
	     $v = $alExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "=="; }
	   { $v += " "; }
	   ( amExpr=expr {
	     $v += $amExpr.v;
	   } )
	 )
	|
	^( NOT_EQUAL
	   ( anExpr=expr {
	     $v = $anExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "!="; }
	   { $v += " "; }
	   ( aoExpr=expr {
	     $v += $aoExpr.v;
	   } )
	 )
	|
	^( LESS_OR_EQUAL
	   ( apExpr=expr {
	     $v = $apExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "instanceof"; }
	   { $v += " "; }
	   ( aqExpr=expr {
	     $v += $aqExpr.v;
	   } )
	 )
	|
	^( LESS_OR_EQUAL
	   ( arExpr=expr {
	     $v = $arExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "<="; }
	   { $v += " "; }
	   ( asExpr=expr {
	     $v += $asExpr.v;
	   } )
	 )
	|
	^( GREATER_THAN_OR_EQUAL
	   ( atExpr=expr {
	     $v = $atExpr.v;
	   } )
	   { $v += " "; }
	   { $v += ">="; }
	   { $v += " "; }
	   ( auExpr=expr {
	     $v += $auExpr.v;
	   } )
	 )
	|
	^( BIT_SHIFT_RIGHT
	   ( avExpr=expr {
	     $v = $avExpr.v;
	   } )
	   { $v += " "; }
	   { $v += ">>>"; }
	   { $v += " "; }
	   ( awExpr=expr {
	     $v += $awExpr.v;
	   } )
	 )
	|
	^( SHIFT_RIGHT
	   ( axExpr=expr {
	     $v = $axExpr.v;
	   } )
	   { $v += " "; }
	   { $v += ">>"; }
	   { $v += " "; }
	   ( ayExpr=expr {
	     $v += $ayExpr.v;
	   } )
	 )
	|
	^( GREATER_THAN
	   ( azExpr=expr {
	     $v = $azExpr.v;
	   } )
	   { $v += " "; }
	   { $v += ">"; }
	   { $v += " "; }
	   ( baExpr=expr {
	     $v += $baExpr.v;
	   } )
	 )
	|
	^( SHIFT_LEFT
	   ( bbExpr=expr {
	     $v = $bbExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "<<"; }
	   { $v += " "; }
	   ( bcExpr=expr {
	     $v += $bcExpr.v;
	   } )
	 )
	|
	^( LESS_THAN
	   ( bdExpr=expr {
	     $v = $bdExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "<"; }
	   { $v += " "; }
	   ( beExpr=expr {
	     $v += $beExpr.v;
	   } )
	 )
	|
	^( PLUS
	   ( bfExpr=expr {
	     $v = $bfExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "+"; }
	   { $v += " "; }
	   ( bgExpr=expr {
	     $v += $bgExpr.v;
	   } )
	 )
	|
	^( MINUS
	   ( bhExpr=expr {
	     $v = $bhExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "-"; }
	   { $v += " "; }
	   ( biIexpr=expr {
	     $v += $biIexpr.v;
	   } )
	 )
	|
	^( STAR
	   ( bjExpr=expr {
	     $v = $bjExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "*"; }
	   { $v += " "; }
	   ( bkExpr=expr {
	     $v += $bkExpr.v;
	   } )
	 )
	|
	^( DIV
	   ( blExpr=expr {
	     $v = $blExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "/"; }
	   { $v += " "; }
	   ( bmExpr=expr {
	     $v += $bmExpr.v;
	   } )
	 )
	|
	^( MOD
	   ( bnExpr=expr {
	     $v = $bnExpr.v;
	   } )
	   { $v += " "; }
	   { $v += "\%"; }
	   { $v += " "; }
	   ( boExpr=expr {
	     $v += $boExpr.v;
	   } )
	 )
	|
	^( UNARY_PLUS
	   ( bpExpr=expr {
	     $v = "+" + $bpExpr.v;
	   } )
	 )
	|
	^( UNARY_MINUS
	   ( bqExpr=expr {
	     $v = "-" + $bqExpr.v;
	   } )
	 )
	|
	^( PRE_INC
	   ( brExpr=expr {
	     $v = "++" + $brExpr.v;
	   } )
	 )
	|
	^( PRE_DEC
	   ( bsExpr=expr {
	     $v = "--" + $bsExpr.v;
	   } )
	 )
	|
	^( POST_INC
	   ( btExpr=expr {
	     $v = $btExpr.v + "++";
	   } )
	 )
	|
	^( POST_DEC
	   ( buExpr=expr {
	     $v = $buExpr.v + "--";
	   } )
	 )
	|
	^( NOT
	   ( bvExpr=expr {
	     $v = "~" + $bvExpr.v;
	   } )
	 )
	|
	^( LOGICAL_NOT
	   ( bwExpr=expr {
	     $v = "!" + $bwExpr.v;
	   } )
	 )
	|
	^( CAST_EXPR
	   ( type {
	     $v = " " + "(" + " " + $type.v;
	   } )
	   ( bxExpr=expr {
	     $v += " " + ")" + " " + $bxExpr.v;
	   } )
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
           ( ( aPrimaryExpression=primaryExpression {
	       $v += $aPrimaryExpression.v;
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
             | ( bCLASS=CLASS {
	         $v += $bCLASS.text;
	       } )
             )
           | ( primitiveType {
	       $v += $primitiveType.v;
	     } )
             ( cCLASS=CLASS {
	       $v += $cCLASS.text;
	     } )
           | ( VOID {
	       $v += $VOID.text;
	     } )
             ( dCLASS=CLASS {
	       $v += $dCLASS.text;
	     } )
           )
        )
	|
	( parenthesizedExpression {
	  $v = $parenthesizedExpression.v;
	} )
	|
	( IDENT {
	  $v = $IDENT.text;
	} )
	|
	^( METHOD_CALL
	   ( ePrimaryExpression=primaryExpression {
	     $v = $ePrimaryExpression.v;
	   } )
	   ( genericTypeArgumentList {
	     $v += $genericTypeArgumentList.v;
	   } )?
	   ( arguments {
	     $v += $arguments.v;
	   } )
	 )
	|
	( explicitConstructorCall {
	  $v = $explicitConstructorCall.v;
	} )
	|
	^( ARRAY_ELEMENT_ACCESS
	   ( fPrimaryExpression=primaryExpression {
	     $v = $fPrimaryExpression.v;
	   } )
	   ( expression {
	     $v+="[";
	     $v += $expression.v;
	     $v+="]";
	   } )
	 )
	|
	( literal {
	  $v = $literal.v;
	} )
	|
	( newExpression {
	  $v = $newExpression.v;
	} )
	|
	( THIS {
	  $v = $THIS.text;
	} )
	|
	( arrayTypeDeclarator {
	  $v = $arrayTypeDeclarator.v;
	} )
	|
	( SUPER {
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
	   ( ( aArrayTypeDeclarator=arrayTypeDeclarator {
	       $v = $aArrayTypeDeclarator.v;
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
	{ $v = ""; }
	^( STATIC_ARRAY_CREATOR
	   ( ( primitiveType {
	       $v = $primitiveType.v;
	     } )
	     ( aNewArrayConstruction=newArrayConstruction {
	       $v += " " + $aNewArrayConstruction.v;
	     } )
	   | ( genericTypeArgumentList {
	       $v = $genericTypeArgumentList.v;
	     } )?
	     ( qualifiedTypeIdent {
	       $v += " " + $qualifiedTypeIdent.v;
	     } )
	     ( bNewArrayConstruction=newArrayConstruction {
	       $v += " " + $bNewArrayConstruction.v;
	     } )
	   )
	 )
	|
	^( CLASS_CONSTRUCTOR_CALL
	   ( genericTypeArgumentList {
	     $v = $genericTypeArgumentList.v;
	   } )?
	   ( qualifiedTypeIdent {
	     $v += " " + $qualifiedTypeIdent.v;
	   } )
	   ( arguments {
	     $v += " " + $arguments.v;
	   } )
	   ( classTopLevelScope {
	     $v += " " + $classTopLevelScope.v;
	   } )?
	 )
	;

// }}}

// {{{ innerNewExpression
// something like 'InnerType innerType = outer.new InnerType();'

innerNewExpression returns [String v]
	:
	{ $v = ""; }
	^( CLASS_CONSTRUCTOR_CALL
	   ( genericTypeArgumentList {
	     $v += $genericTypeArgumentList.v;
	   } )?
	   ( IDENT {
	     $v += " " + $IDENT.text;
	   } )
	   ( arguments {
	     $v += " " + $arguments.v;
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
	:
	( arrayDeclaratorList {
	  $v = $arrayDeclaratorList.v;
	} )
	( arrayInitializer {
	  $v += $arrayInitializer.v;
	} )
	{ $v += "/*;5*/" + "\n"; }
	|
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
	:
	{ $v = "("; }
	{ $v += " "; }
	^( ARGUMENT_LIST
	   ( expression {
	     $v += ( _i++ == 0 ? "" : "/* arguments */" )
		 + $expression.v;
	   } )*
	 )
	{ $v += " "; }
	{ $v += ")"; }
	;

// }}}

// {{{ literal

literal returns [String v]
	:
	( HEX_LITERAL {
	  $v = $HEX_LITERAL.text;
	} )
	|
	( OCTAL_LITERAL {
	  $v = $OCTAL_LITERAL.text;
	} )
	|
	( DECIMAL_LITERAL {
	  $v = $DECIMAL_LITERAL.text;
	} )
	|
	( FLOATING_POINT_LITERAL {
	  $v = $FLOATING_POINT_LITERAL.text;
	} )
	|
	( CHARACTER_LITERAL {
	  $v = $CHARACTER_LITERAL.text;
	} )
	|
	( STRING_LITERAL {
	  $v = $STRING_LITERAL.text;
	} )
	|
	( TRUE {
	  $v = $TRUE.text;
	} )
	|
	( FALSE {
	  $v = $FALSE.text;
	} )
	|
	( NULL {
	  $v = $NULL.text;
	} )
	;

// }}}

