// {{{ License
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
  public boolean cover = false;
  private String foo;
  private void nonterminal ( String s ) {
    foo = s;
    if ( cover )
      System.out.println( "Nonterminal: " + s );
  }
  private void children ( String s ) {
//    if ( cover )
//      System.out.println( "Child: " + foo + " " + s );
  }

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
@init
  {
  int _i = 0, _j = 0;
  nonterminal( "javaSource" );
  }
  :
  ^( JAVA_SOURCE
     ( annotationList {
       children( "annotationList" );
       $v = $annotationList.v;
     } )
     ( packageDeclaration {
       children( "packageDeclaration" );
       $v += " " + $packageDeclaration.v;
     {$v+=";";}
     } )?
     ( importDeclaration {
       children( "importDeclaration" );
       $v += ( _i++ == 0 ? "" : "/* javaSource 1 */" )
  	 + $importDeclaration.v;
     {$v+=";";}
     } )*
     ( typeDeclaration {
       children( "typeDeclaration" );
       $v += ( _j++ == 0 ? "" : "/* javaSource 2 */" )
  	 + $typeDeclaration.v;
     } )*
   )
  ;

// }}}

// {{{ packageDeclaration

packageDeclaration returns [String v]
@init
  {
  nonterminal( "packageDeclaration" );
  }
  :
  ^( ( PACKAGE {
       children( "PACKAGE" );
       $v = $PACKAGE.text;
     } )
     ( qualifiedIdentifier {
       children( "qualifiedIdentifier" );
       $v += " " + $qualifiedIdentifier.v;
     } )
   )
  ;

// }}}

// {{{ importDeclaration

importDeclaration returns [String v]
@init
  {
  nonterminal( "importDeclaration" );
  }
  :
  ^( ( IMPORT {
       children( "IMPORT" );
       $v = $IMPORT.text;
     } )
     ( STATIC {
       children( "STATIC" );
       $v += " " + $STATIC.text;
     } )?
     ( qualifiedIdentifier {
       children( "qualifiedIdentifier" );
       $v += " " + $qualifiedIdentifier.v;
     } )
     ( DOTSTAR {
       children( "DOTSTAR" );
       $v += " " + $DOTSTAR.text;
     } )?
   )
  ;

// }}}

// {{{ typeDeclaration

typeDeclaration returns [String v]
@init
  {
  nonterminal( "typeDeclaration" );
  }
  :
  ^( ( CLASS {
       children( "CLASS" );
     } )
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
       $v += " " + $CLASS.text;
     } )
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
     ( genericTypeParameterList {
       children( "genericTpeParameterList" );
       $v += " " + $genericTypeParameterList.v;
     } )?
     ( extendsClause {
       children( "extendsClause" );
       $v += " " + $extendsClause.v;
     } )?
     ( implementsClause {
       children( "implementsClause" );
       $v += " " + $implementsClause.v;
     } )?
     ( classTopLevelScope {
       children( "classTopLevelScope" );
       $v += " " + $classTopLevelScope.v;
     } )
   )
  |
  ^( ( INTERFACE {
       children( "INTERFACE" );
       $v = $INTERFACE.text;
     } )
     ( modifierList {
       children( "modifierList" );
       $v += " " + $modifierList.v;
     } )
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
     ( genericTypeParameterList {
       children( "genericTypeParameterList" );
       $v += " " + $genericTypeParameterList.v;
     } )?
     ( extendsClause {
       children( "extendsClause" );
       $v += " " + $extendsClause.v;
     } )?
     ( interfaceTopLevelScope {
       children( "interfaceTopLevelScope" );
       $v += " " + $interfaceTopLevelScope.v;
     } )
   )
  |
  ^( ( ENUM {
       children( "ENUM" );
     } )
     ( modifierList {
       children( "modifierList" );
       $v = " " + $modifierList.v;
     } )
     { $v += " " + $ENUM.text; }
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
     ( implementsClause {
       children( "implementsClause" );
       $v += " " + $implementsClause.v;
     } )?
     { $v += " "; }
     { $v += "{"; }
     { $v += "\n"; }
     ( enumTopLevelScope {
       children( "enumTopLevelScope" );
       $v += " " + $enumTopLevelScope.v;
     } )
     { $v += "\n"; }
     { $v += "}"; }
     { $v += "\n"; }
   )
  |
  ^( ( AT {
       children( "AT" );
     } )
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
     } )
     { $v += " " + $AT.text; }
     { $v += "interface"; }
     { $v += " "; }
     ( IDENT {
       children( "IDENT" );
       $v += $IDENT.text;
     } )
     { $v += "{"; }
     ( annotationTopLevelScope {
       children( "annotationTopLevelScope" );
       $v += " " + $annotationTopLevelScope.v;
     } )
     { $v += "}"; }
   )
  ;

// }}}

// {{{ extendsClause
// actually 'type' for classes and 'type+' for interfaces, but this has 
// been resolved by the parser grammar.

extendsClause returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "extendsClause" );
  }
  :
  { $v = ""; }
  ^( EXTENDS_CLAUSE
     { children( "type" ); }
     { $v += " " + "extends" + " "; }
     ( type {
       $v += (_i == 0 ? "" + " " : ",/* extendsClause */" )
  	 + $type.v;
     } )+
   )
  ;

// }}}

// {{{ implementsClause

implementsClause returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "implementsClause" );
  }
  :
  { $v = ""; }
  ^( IMPLEMENTS_CLAUSE
     { children( "type" ); }
     ( type {
       $v += ( _i++ == 0 ? "" : "/* implementsClause */" )
  	 + $type.v;
     } )+
   )
  ;

// }}}

// {{{ genericTypeParameterList

genericTypeParameterList returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "genericTypeParameterList" );
  }
  :
  { $v = ""; }
  ^( GENERIC_TYPE_PARAM_LIST
     { children( "genericTypeParameter" ); }
     ( genericTypeParameter {
       $v += ( _i++ == 0 ? "" : "/* genericTypeParameter */" )
  	 + $genericTypeParameter.v;
     } )+
   )
  ;

// }}}

// {{{ genericTypeParameter

genericTypeParameter returns [String v]
@init
  {
  nonterminal( "genericTypeParameter" );
  }
  :
  ^( ( IDENT {
       children( "IDENT" );
       $v = $IDENT.text;
     } )
     ( bound {
       children( "bound" );
       $v += " " + $bound.v;
     } )?
   )
  ;

// }}}

// {{{ bound

bound returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "bound" );
  }
  :
  { $v = ""; }
  ^( EXTENDS_BOUND_LIST
     { children( "type" ); }
     ( type {
       $v += ( _i++ == 0 ? "" : "/* bound */" )
  	 + $type.v;
     } )+
   )
  ;

// }}}

// {{{ enumTopLevelScope

enumTopLevelScope returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "enumTopLevelScope" );
  }
  :
  { $v = ""; }
  ^( ENUM_TOP_LEVEL_SCOPE
     ( enumConstant {
       children( "enumConstant" );
       $v += ( _i++ == 0 ? "" : ",/* enumTopLevelScope */" )
  	 + $enumConstant.v;
     } )+
     ( classTopLevelScope {
       children( "classTopLevelScope" );
       $v += " " + $classTopLevelScope.v;
     } )?
   )
  ;

// }}}

// {{{ enumConstant

enumConstant returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "enumConstant" );
  }
  :
  ^( ( IDENT {
       children( "IDENT" );
       $v = $IDENT.text;
     } )
     ( annotationList {
       children( "annotationList" );
       $v += " " + $annotationList.v;
     } )
     ( arguments {
       children( "arguments" );
       $v += " " + $arguments.v;
     } )?
     ( classTopLevelScope {
       children( "classTopLevelScope" );
       $v += " " + $classTopLevelScope.v;
     } )?
   )
  ;

// }}}

// {{{ classTopLevelScope

classTopLevelScope returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "classTopLevelScope" );
  }
  :
  { $v = "{"; }
  { $v += "\n"; }
  ^( CLASS_TOP_LEVEL_SCOPE
     { children( "classScopeDeclarations" ); }
     ( classScopeDeclarations {
       $v += ( _i++ == 0 ? "" : "/* classTopLevelScope */" )
  	 + $classScopeDeclarations.v;
     } )*
   )
  { $v += "\n"; }
  { $v += "}"; }
  { $v += "\n"; }
  ;

// }}}

// {{{ classScopeDeclarations

classScopeDeclarations returns [String v]
@init
  {
  nonterminal( "classScopeDeclarations" );
  }
  :
  { $v = ""; }
  ^( CLASS_INSTANCE_INITIALIZER
     ( block {
       children( "block" );
       $v = $block.s.string;
     } )?
   )
  |
  { $v = ""; }
  ^( CLASS_STATIC_INITIALIZER
     ( block {
       children( "block" );
       $v = $block.s.string;
     } )?
   )
  |
  ^( FUNCTION_METHOD_DECL
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
     } )
     ( genericTypeParameterList {
       children( "genericTypeParameterList" );
       $v += " " + $genericTypeParameterList.v;
     } )?
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
     ( formalParameterList {
       $v += " " + $formalParameterList.v;
     } )
     ( arrayDeclaratorList {
       children( "arrayDeclaratorList" );
       $v += " " + $arrayDeclaratorList.v;
     } )?
     ( throwsClause {
       children( "throwsClause" );
       $v += " " + $throwsClause.v;
     } )?
     ( block {
       children( "block" );
       $v += " " + $block.s.string;
     } )?
    )
  |
  ^( VOID_METHOD_DECL
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
     } )
     ( genericTypeParameterList {
       children( "genericTypeParameterList" );
       $v += " " + $genericTypeParameterList.v;
     } )?
     { $v += " " + "void"; }
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
     ( formalParameterList {
       children( "formalParameterList" );
       $v += " " + $formalParameterList.v;
     } )
     ( throwsClause {
       children( "throwsClause" );
       $v += " " + $throwsClause.v;
     } )?
     ( block {
       children( "block" );
       $v += " " + $block.s.string;
     } )?
   )
  |
  ^( VAR_DECLARATION // XXX public int aTest = 42;
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( variableDeclaratorList {
       children( "variableDeclaratorList" );
       $v += " " + $variableDeclaratorList.v;
     } )
     { $v += ";" + "\n"; }
   )
  |
  ^( CONSTRUCTOR_DECL
     ( IDENT )
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
     } )
     { $v+= " " + $IDENT.text; }
     ( genericTypeParameterList {
       children( "genericTypeParameterList" );
       $v += " " + $genericTypeParameterList.v;
     } )?
     ( formalParameterList {
       children( "formalParameterList" );
       $v += " " + $formalParameterList.v;
     } )
     ( throwsClause {
       children( "throwsClause" );
       $v += " " + $throwsClause.v;
     } )?
     ( block {
       children( "block" );
       $v += " " + $block.s.string;
     } )
   )
  |
  ( typeDeclaration {
    children( "typeDeclaration" );
    $v = $typeDeclaration.v;
  } )
  ;

// }}}

// {{{ interfaceTopLevelScope

interfaceTopLevelScope returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "interfaceTopLevelScope" );
  }
  :
  { $v = ""; }
  ^( INTERFACE_TOP_LEVEL_SCOPE
     { children( "interfaceScopeDeclarations" ); }
     ( interfaceScopeDeclarations {
       $v += ( _i++ == 0 ? "" : "/* interfaceTopLevelScope */" )
  	 + $interfaceScopeDeclarations.v;
     } )*
   )
  ;

// }}}

// {{{ interfaceScopeDeclarations

interfaceScopeDeclarations returns [String v]
@init
  {
  nonterminal( "interfaceScopeDeclarations" );
  }
  :
  ^( FUNCTION_METHOD_DECL
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
     } )
     ( genericTypeParameterList {
       children( "genericTypeParameterList" );
       $v += " " + $genericTypeParameterList.v;
     } )?
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
     ( formalParameterList {
       children( "formalParameterList" );
       $v += " " + $formalParameterList.v;
     } )
     ( arrayDeclaratorList {
       children( "arrayDeclaratorList" );
       $v += " " + $arrayDeclaratorList.v;
     } )?
     ( throwsClause {
       children( "throwsClause" );
       $v += " " + $throwsClause.v;
     } )?
   )
  |
  // Interface constant declarations have been switched to variable
  // declarations by 'java.g'; the parser has already checked that
  // there's an obligatory initializer.
  ^( VOID_METHOD_DECL
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
     } )
     ( genericTypeParameterList {
       children( "genericTypeParameterList" );
       $v += " " + $genericTypeParameterList.v;
     } )?
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
     ( formalParameterList {
       children( "formalParameterList" );
       $v += " " + $formalParameterList.v;
     } )
     ( throwsClause {
       children( "throwsClause" );
       $v += " " + $throwsClause.v;
     } )?
   )
  |
  ^( VAR_DECLARATION
     ( modifierList {
       children( "modifierList" );
       $v = $modifierList.v;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( variableDeclaratorList {
       children( "variableDeclaratorList" );
       $v = " " + $variableDeclaratorList.v;
     } )
   )
  | 
  ( typeDeclaration {
    children( "typeDeclaration" );
    $v = $typeDeclaration.v;
  } )
  ;

// }}}

// {{{ variableDeclaratorList

variableDeclaratorList returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "variableDeclaratorList" );
  }
  :
  { $v = ""; }
  ^( VAR_DECLARATOR_LIST
     { children( "variableDeclarator" ); }
     ( variableDeclarator {
       $v += ( _i++ == 0 ? "" : ", " )
           + $variableDeclarator.v;
     } )+
   )
  ;

// }}}

// {{{ variableDeclarator

variableDeclarator returns [String v]
@init
  {
  nonterminal( "variableDeclarator" );
  }
  :
  ^( VAR_DECLARATOR
     ( variableDeclaratorId {
       children( "variableDeclaratorId" );
       $v = $variableDeclaratorId.v;
     } )
     ( variableInitializer {
       children( "variableInitializer" );
       $v += " " + "=" + " " + $variableInitializer.v;
     } )?
   )
  ;

// }}}

// {{{ variableDeclaratorId

variableDeclaratorId returns [String v]
@init
  {
  nonterminal( "variableDeclaratorId" );
  }
  :
  ^( ( IDENT {
       children( "IDENT" );
       $v = $IDENT.text;
     } )
     ( arrayDeclaratorList {
       children( "arrayDeclaratorList" );
       $v += " " + $arrayDeclaratorList.v;
     } )?
   )
  ;

// }}}

// {{{ variableInitializer

variableInitializer returns [String v]
@init
  {
  nonterminal( "variableInitializer" );
  }
  :
  ( arrayInitializer {
    children( "arrayInitializer" );
    $v = $arrayInitializer.v;
  } )
  |
  ( expression {
    children( "expression" );
    $v = $expression.v;
  } )
  ;

// }}}

// {{{ arrayDeclarator

arrayDeclarator returns [String v]
@init
  {
  nonterminal( "arrayDeclarator" );
  }
  :
  ( LBRACK {
    children( "LBRACK" );
    $v = $LBRACK.text;
  } )
  ( RBRACK {
    children( "RBRACK" );
    $v += " " + $RBRACK.text;
  } )
  ;

// }}}

// {{{ arrayDeclaratorList

arrayDeclaratorList returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "arrayDeclaratorList" );
  }
  :
  { $v = ""; }
  ^( ARRAY_DECLARATOR_LIST
     { children( "arrayDeclarator" ); }
     ( arrayDeclarator {
       $v += ( _i++ == 0 ? "" : "/* arrayDeclaratorList */" )
  	 + $arrayDeclarator.v;
     } )+
   )
  ;

// }}}

// {{{ arrayInitializer

arrayInitializer returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "arrayInitializer" );
  }
  :
  { $v = "{"; }
  { $v += " "; }
  ^( ARRAY_INITIALIZER
     { children( "variableInitializer" ); }
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
@init
  {
  int _i = 0;
  nonterminal( "throwsClause" );
  }
  :
  { $v = ""; }
  ^( THROWS_CLAUSE
     { children( "qualifiedIdentifier" ); }
     ( qualifiedIdentifier {
       $v += ( _i++ == 0 ? "" : "/* throwsClause */" )
  	 + $qualifiedIdentifier.v;
     } )+
   )
  ;

// }}}

// {{{ modifierList

modifierList returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "modifierList" );
  }
  :
  { $v = ""; }
  ^( MODIFIER_LIST
     { children( "modifier" ); }
     ( modifier {
       $v += ( _i++ == 0 ? "" : " " )
   	 + $modifier.v;
     } )*
   )
  ;

// }}}

// {{{ modifier

modifier returns [String v]
@init
  {
  nonterminal( "modifier" );
  }
  :
  ( PUBLIC {
    children( "PUBLIC" );
    $v = $PUBLIC.text;
  } )
  |
  ( PROTECTED {
    children( "PROTECTED" );
    $v = $PROTECTED.text;
  } )
  |
  ( PRIVATE {
    children( "PRIVATE" );
    $v = $PRIVATE.text;
  } )
  |
  ( STATIC {
    children( "STATIC" );
    $v = $STATIC.text;
  } )
  |
  ( ABSTRACT {
    children( "ABSTRACT" );
    $v = $ABSTRACT.text;
  } )
  |
  ( NATIVE {
    children( "NATIVE" );
    $v = $NATIVE.text;
  } )
  |
  ( SYNCHRONIZED {
    children( "SYNCHRONIZED" );
    $v = $SYNCHRONIZED.text;
  } )
  |
  ( TRANSIENT {
    children( "TRANSIENT" );
    $v = $TRANSIENT.text;
  } )
  |
  ( VOLATILE {
    children( "VOLATILE" );
    $v = $VOLATILE.text;
  } )
  |
  ( STRICTFP {
    children( "STRICTFP" );
    $v = $STRICTFP.text;
  } )
  |
  ( localModifier {
    children( "localModifier" );
    $v = $localModifier.v;
  } )
  ;

// }}}

// {{{ localModifierList

localModifierList returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "localModifierList" );
  }
  :
  { $v = ""; }
  ^( LOCAL_MODIFIER_LIST
     { children( "localModifier" ); }
     ( localModifier {
       $v += ( _i++ == 0 ? "" : "/* localModifierList */" )
  	 + $localModifier.v;
     } )*
   )
  ;

// }}}

// {{{ localModifier

localModifier returns [String v]
@init
  {
  nonterminal( "localModifier" );
  }
  :
  ( FINAL {
    children( "FINAL" );
    $v = $FINAL.text;
  } )
  |
  ( annotation {
    children( "annotation" );
    $v = $annotation.v;
  } )
  ;

// }}}

// {{{ type

type returns [String v]
@init
  {
  nonterminal( "type" );
  }
  :
  ^( TYPE
     ( ( primitiveType {
         children( "primitiveType" );
         $v = $primitiveType.v;
       } )
     | ( qualifiedTypeIdent {
         children( "qualifiedTypeIdent" );
         $v = $qualifiedTypeIdent.v;
       } )
     )
     ( arrayDeclaratorList {
       children( "arrayDeclaratorList" );
       $v += " " + $arrayDeclaratorList.v;
     } )?
   )
  ;

// }}}

// {{{ qualifiedTypeIdent

qualifiedTypeIdent returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "qualifiedTypeIdent" );
  }
  :
  { $v = ""; }
  ^( QUALIFIED_TYPE_IDENT
     { children( "typeIdent" ); }
     ( typeIdent {
       $v += ( _i++ == 0 ? "" : "/* qualifiedTypeIdent */" )
  	 + $typeIdent.v;
     } )+
   )
  ;

// }}}

// {{{ typeIdent

typeIdent returns [String v]
@init
  {
  nonterminal( "typeIdent" ); 
  }
  :
  ^( ( IDENT {
       children( "IDENT" );
       $v = $IDENT.text;
     } )
     ( genericTypeArgumentList {
       children( "genericTypeArgumentList" );
       $v += " " + $genericTypeArgumentList.v;
     } )?
   )
  ;

// }}}

// {{{ primitiveType

primitiveType returns [String v]
@init
  {
  nonterminal( "primitiveType" );
  }
  :
  ( BOOLEAN {
    children( "BOOLEAN" );
    $v = $BOOLEAN.text;
  } )
  |
  ( CHAR {
    children( "CHAR" );
    $v = $CHAR.text;
  } )
  |
  ( BYTE {
    children( "BYTE" );
    $v = $BYTE.text;
  } )
  |
  ( SHORT {
    children( "SHORT" );
    $v = $SHORT.text;
  } )
  |
  ( INT {
    children( "INT" );
    $v = $INT.text;
  } )
  |
  ( LONG {
    children( "LONG" );
    $v = $LONG.text;
  } )
  |
  ( FLOAT {
    children( "FLOAT" );
    $v = $FLOAT.text;
  } )
  |
  ( DOUBLE {
    children( "DOUBLE" );
    $v = $DOUBLE.text;
  } )
  ;

// }}}

// {{{ genericTypeArgumentList

genericTypeArgumentList returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "genericTypeArgumentList" );
  }
  :
  { $v = ""; }
  ^( GENERIC_TYPE_ARG_LIST
     { children( "genericTypeArgument" ); }
     ( genericTypeArgument {
       $v += ( _i++ == 0 ? "" : "/* genericTypeArgumentList */" )
  	 + $genericTypeArgument.v;
     } )+
   )
  ;

// }}}

// {{{ genericTypeArgument

genericTypeArgument returns [String v]
@init
  {
  nonterminal( "genericTypeArgument" ); 
  }
  :
  ( type {
    children( "type" );
    $v = $type.v;
  } )
  |
  ^( ( QUESTION {
       children( "QUESTION" );
       $v = $QUESTION.text;
     } )
     ( genericWildcardBoundType {
       children( "genericWildcardBoundType" );
       $v += " " + $genericWildcardBoundType.v;
     } )?
   )
  ;

// }}}

// {{{ genericWildcardBoundType

genericWildcardBoundType returns [String v]
@init
  {
  nonterminal( "genericWildcardBoundType" );
  }
  :
  ^( ( EXTENDS {
       children( "EXTENDS" );
       $v = $EXTENDS.text;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
   )
  |
  ^( ( SUPER {
       children( "SUPER" );
       $v = $SUPER.text;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
   )
  ;

// }}}

// {{{ formalParameterList

formalParameterList returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "formalParameterList" );
  }
  :
  { $v = "("; }
  { $v += " "; }
  ^( FORMAL_PARAM_LIST
     ( formalParameterStandardDecl {
       children( "formalParameterStandardDecl" );
       $v += ( _i++ == 0 ? "" : "/* formalParameterList */" )
  	 + $formalParameterStandardDecl.v;
     } )*
     ( formalParameterVarargDecl {
       children( "formalParameterVarargDecl" );
       $v += " " + $formalParameterVarargDecl.v;
     } )?
   )
  { $v += " "; }
  { $v += ")"; }
  ;

// }}}

// {{{ formalParameterStandardDecl
formalParameterStandardDecl returns [String v]
@init
  {
  nonterminal( "formalParameterStandardDecl" ); 
  }
  :
  ^( FORMAL_PARAM_STD_DECL
     ( localModifierList {
       children( "localModifierList" );
       $v = $localModifierList.v;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( variableDeclaratorId {
       children( "variableDeclaratorId" );
       $v += " " + $variableDeclaratorId.v;
     } )
   )
  ;

// }}}

// {{{ formalParameterVarargDecl

formalParameterVarargDecl returns [String v]
@init
  {
  nonterminal( "formalParameterVarargDecl" );
  }
  :
  ^( FORMAL_PARAM_VARARG_DECL
     ( localModifierList {
       children( "localModifierList" );
       $v = $localModifierList.v;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( variableDeclaratorId {
       children( "variableDeclaratorId" );
       $v += " " + $variableDeclaratorId.v;
     } )
   )
  ;

// }}}

// {{{ qualifiedIdentifier

qualifiedIdentifier returns [String v]
@init
  {
  nonterminal( "qualifiedIdentifier" ); 
  }
  :
  ( IDENT {
    children( "IDENT" );
    $v = $IDENT.text;
  } )
  |
  ^( ( DOT {
       children( "DOT" );
     } )
     ( aQualifiedIdentifier=qualifiedIdentifier {
       children( "aQualifiedIdentifier" );
       $v = " " + $aQualifiedIdentifier.v;
       $v += $DOT.text;
     } )
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
   )
  ;

// }}}

// ANNOTATIONS

// {{{ annotationList

annotationList returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "annotationList" );
  }
  :
  { $v = ""; }
  ^( ANNOTATION_LIST
     { children( "annotation" ); }
     ( annotation {
       $v += ( _i++ == 0 ? "" : "/* annotationList */" )
  	 + $annotationList.v;
     } )*
   )
  ;

// }}}

// {{{ annotation

annotation returns [String v]
@init
  {
  nonterminal( "annotation" );
  }
  :
  ^( ( AT {
       children( "AT" );
       $v = $AT.text;
     } )
     ( qualifiedIdentifier {
       children( "qualifiedIdentifier" );
       $v += $qualifiedIdentifier.v;
     } )
     ( annotationInit {
       children( "annotationInit" );
       $v += " " + $annotationInit.v;
     } )?
   )
  ;

// }}}

// {{{ annotationInit

annotationInit returns [String v]
@init
  {
  nonterminal( "annotationInit" );
  }
  :
  ^( ANNOTATION_INIT_BLOCK
     { children( "annotationInitializers" ); }
     ( annotationInitializers {
       $v = $annotationInitializers.v;
     } ) ) 
  ;

// }}}

// {{{ annotationInitializers

annotationInitializers returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "annotationInitializers" );
  }
  :
  { $v = "("; }
  { $v += " "; }
  ^( ANNOTATION_INIT_KEY_LIST
     ( annotationInitializer {
       children( "annotationInitializer" );
       $v += ( _i++ == 0 ? "" : ", " )
  	 + $annotationInitializer.v;
     } )+
   )
  { $v += " "; }
  { $v += ")"; }
  |
  { $v = "("; }
  { $v += " "; }
  ^( ANNOTATION_INIT_DEFAULT_KEY
    {$v += " ";}
     ( annotationElementValue {
       children( "annotationElementValue" );
       $v += ( _i++ == 0 ? "" : "/* annotationElementValue 1 */" )
  	 + $annotationElementValue.v;
     } )+
   )
  { $v += " "; }
  { $v += ")"; }
  ;

// }}}

// {{{ annotationInitializer

annotationInitializer returns [String v]
@init
  {
  nonterminal( "annotationInitializer" ); 
  }
  :
  ^( ( IDENT {
       children( "IDENT" );
       $v = $IDENT.text;
     } )
     { $v += " "; }
     { $v += "="; }
     { $v += " "; }
     ( annotationElementValue {
       children( "annotationElementValue" );
       $v += " " + $annotationElementValue.v;
     } )
   )
  ;

// }}}

// {{{ annotationElementValue

annotationElementValue returns [String v]
@init
  {
  nonterminal( "annotationElementValue" );
  }
  :
  { $v = ""; }
  ^( ANNOTATION_INIT_ARRAY_ELEMENT
     { children( "aAnnotationElementValue" ); }
     ( aAnnotationElementValue=annotationElementValue {
       $v += $aAnnotationElementValue.v;
     } )*
   )
  |
  ( annotation {
    children( "annotation" );
    $v = $annotation.v;
  } )
  |
  ( expression {
    children( "expression" );
    $v = $expression.v;
  } )
  ;

// }}}

// {{{ annotationTopLevelScope

annotationTopLevelScope returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "annotationTopLevelScope" );
  }
  :
  { $v = ""; }
  ^( ANNOTATION_TOP_LEVEL_SCOPE
     { children( "annotationScopeDeclarations" ); }
     ( annotationScopeDeclarations {
       $v += ( _i++ == 0 ? "" : ";/* annotationTopLevelScope 1 */" )
  	 + $annotationScopeDeclarations.v;
     } )*
     {$v+=";/* annotationTopLevelScope 2 */";}
    )
  ;

// }}}

// {{{ annotationScopeDeclarations

annotationScopeDeclarations returns [String v]
@init
  {
  nonterminal( "annotationScopeDeclarations" );
  }
  :
  { $v = ""; }
  ^( ANNOTATION_METHOD_DECL
     ( modifierList {
       children( "modifierList" );
       $v += $modifierList.v;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
       $v += "(";
       $v += " ";
       $v += ")";
     } )
     ( annotationDefaultValue {
       children( "annotationDefaultValue" );
       $v+=" ";
       $v+="default";
       $v+=" ";
       $v += " " + $annotationDefaultValue.v;
     } )?
    )
  |
  ^( VAR_DECLARATION
     ( modifierList {
       children( "modifierList" );
       $v += $modifierList.v;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( variableDeclaratorList {
       children( "variableDeclaratorList" );
       $v += " " + $variableDeclaratorList.v;
     } )
   )
  |
  ( typeDeclaration {
    children( "typeDeclaration" );
    $v = $typeDeclaration.v;
  } )
  ;

// }}}

// {{{ annotationDefaultValue

annotationDefaultValue returns [String v]
@init
  {
  nonterminal( "annotationDefaultValue" ); 
  }
  :
  ^( DEFAULT
     ( annotationElementValue {
       children( "annotationElementValue" );
       $v = $annotationElementValue.v;
     } )
{$v+=";";}
   )
  ;

// }}}

// STATEMENTS / BLOCKS

// {{{ block

block returns [Statement s]
@init
  {
  int _i = 0;
  nonterminal( "block" );
  }
  :
  { $s = new Statement( 1 ); }
  { $s.string += "{"; }
  { $s.string += "\n"; }
  ^( BLOCK_SCOPE
     ( blockStatement {
       children( "blockStatement" );
       $s.string += ( _i++ == 0 ? "" : "/* block */" )
  	  + $blockStatement.s.string;

$s.string +=
  ( $blockStatement.s.id == 2 ? ";" : "" ) +
  ( $blockStatement.s.id == 8 ? ";" : "" ) + // for ( a : b ) i++; // The 'i++'
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
@init
  {
  nonterminal( "blockStatement" );
  }
  :
  ( localVariableDeclaration { // XXX 'int i = 40;'
    children( "localVariableDeclaration" );
    $s = new Statement( 2 );
    $s.string = $localVariableDeclaration.v;
  } )
  |
  ( typeDeclaration {
    children( "typeDeclaration" );
    $s = new Statement( 3 );
    $s.string = $typeDeclaration.v;
  } )
  |
  ( statement {
    children( "statement" );
    $s = new Statement( $statement.s.id );
    $s.string = $statement.s.string;
  } )
  ;

// }}}

// {{{ localVariableDeclaration
// int i;

localVariableDeclaration returns [String v]
@init
  {
  nonterminal( "localVariableDeclaration" );
  }
  :
  ^( VAR_DECLARATION
     ( localModifierList {
       children( "localModifierList" );
       $v = $localModifierList.v;
     } )
     ( type {
       children( "type" );
       $v += " " + $type.v;
     } )
     ( variableDeclaratorList {
       children( "variableDeclaratorList" );
       $v += " " + $variableDeclaratorList.v;
     } )
   )
  ;

// }}}

// {{{ statement
        
statement returns [Statement s]
@init
  {
  nonterminal( "statement" ); 
  }
  :
  ( block {
    children( "block" );
    $s = new Statement( 5 );
    $s.string = $block.s.string;
  } )
  |
  ^( ( ASSERT {
       children( "ASSERT" );
       $s = new Statement( 6 );
       $s.string = $ASSERT.text;
     } )
     ( aExpression=expression {
       $s.string += " " + $aExpression.v;
     } )
     ( bExpression=expression {
       $s.string += " " + $bExpression.v;
     } )?
   )
  |
  ^( ( IF {
       children( "IF" );
       $s = new Statement( 7 );
       $s.string = $IF.text;
     } )
     ( parenthesizedExpression {
       $s.string += " " + $parenthesizedExpression.v;
     } )
     ( cStatement=statement {
       $s.string += " " + $cStatement.s.string;
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
       children( "FOR" );
       $s = new Statement( 21 );
       $s.string = $FOR.text;
     } )
     { $s.string += "("; }
     ( forInit {
       $s.string += " " + $forInit.v;
     } )
     { $s.string += ";"; }
     ( forCondition {
       $s.string += " " + $forCondition.v;
     } )
     { $s.string += ";"; }
     ( forUpdater {
       $s.string += " " + $forUpdater.v;
     } )
     { $s.string += ")"; }
     ( eStatement=statement {
       $s.string += $eStatement.s.string;
     } )
   )
  |
  ^( ( FOR_EACH {
       children( "FOR_EACH" );
       $s = new Statement( 8 );
       $s.string = "for";
     } )
     { $s.string += "("; }
     ( localModifierList {
       $s.string += " " + $localModifierList.v;
     } )
     ( type {
       $s.string += " " + $type.v;
     } )
     ( IDENT {
       $s.string += " " + $IDENT.text;
     } )
     { $s.string += " "; }
     { $s.string += ":"; }
     ( expression {
       $s.string += " " + $expression.v;
     } )
     { $s.string += " "; }
     { $s.string += ")"; }
     ( fStatement=statement {
       $s.string += " " + $fStatement.s.string;
     } )
   ) 
  |
  ^( ( WHILE {
       children( "WHILE" );
       $s = new Statement( 9 );
       $s.string = $WHILE.text;
     } )
     ( parenthesizedExpression {
       $s.string += " " + $parenthesizedExpression.v;
     } )
     ( gStatement=statement {
       $s.string += " " + $gStatement.s.string;
     } )
   )
  |
  ^( ( DO {
       children( "DO" );
       $s = new Statement( 10 );
       $s.string = $DO.text;
     } )
     ( hStatement=statement {
       $s.string += " " + $hStatement.s.string;
$s.string +=
  ( $hStatement.s.id == 19 ? ";" : "" ) +
  "/* 4 (" + $hStatement.s.id + ") */";
     } )
     { $s.string += " " + "while"; }
     ( parenthesizedExpression {
       $s.string += " " + $parenthesizedExpression.v;
     } )
   )
  |
  // The second optional block is the optional finally block.
  ^( ( TRY {
       children( "TRY" );
       $s = new Statement( 11 );
       $s.string = $TRY.text;
     } )
     ( iBlock=block {
       $s.string += " " + $iBlock.s.string;
     } )
     ( catches {
       $s.string += " " + $catches.v;
     } )?
     ( jBlock=block {
       $s.string += " " + $jBlock.s.string;
     } )?
   )
  |
  ^( ( SWITCH {
       children( "SWITCH" );
       $s = new Statement( 12 );
       $s.string = $SWITCH.text;
     } )
     ( parenthesizedExpression {
       $s.string += " " + $parenthesizedExpression.v;
     } )
     { $s.string += "{"; }
     { $s.string += "\n"; }
     ( switchBlockLabels {
       $s.string += " " + $switchBlockLabels.v;
     } )
     { $s.string += ";"; }
     { $s.string += "\n"; }
     { $s.string += "}"; }
   )
  |
  ^( ( SYNCHRONIZED {
       children( "SYNCHRONIZED" );
       $s = new Statement( 13 );
       $s.string = $SYNCHRONIZED.text;
     } )
     ( parenthesizedExpression {
       $s.string += " " + $parenthesizedExpression.v;
     } )
     ( block {
       $s.string += " " + $block.s.string;
     } )
   )
  |
  ^( ( RETURN { // XXX 'return 0;'
       children( "RETURN" );
       $s = new Statement( 14 );
       $s.string = $RETURN.text;
     } )
     ( expression {
       $s.string += " " + $expression.v;
     } )?
   )
  |
  ^( ( THROW {
       children( "THROW" );
       $s = new Statement( 15 );
       $s.string = $THROW.text;
     } )
     ( expression {
       $s.string += " " + $expression.v;
     } )
   )
  |
  ^( ( BREAK {
       children( "BREAK" );
       $s = new Statement( 16 );
       $s.string = $BREAK.text;
     } )
     ( IDENT {
       $s.string += " " + $IDENT.text;
     } )?
   )
  |
  ^( ( CONTINUE {
       children( "CONTINUE" );
       $s = new Statement( 17 );
       $s.string = $CONTINUE.text;
     } )
     ( IDENT {
       $s.string += " " + $IDENT.text;
     } )?
   )
  |
  ^( ( LABELED_STATEMENT {
       children( "LABELED_STATEMENT" );
       $s = new Statement( 18 );
       $s.string = $LABELED_STATEMENT.text;
     } )
     ( IDENT {
       $s.string += " " + $IDENT.text;
     } )
     ( kStatement=statement {
       $s.string += " " + $kStatement.s.string;
     } )
   )
  |
  ( expression {
    children( "expression" );
    $s = new Statement( 19 );
    $s.string = $expression.v;
  } )
  |
  ( SEMI { // Empty statement.
    children( "SEMI" );
    $s = new Statement( 20 );
    $s.string = $SEMI.text;
  } )
  ;

// }}}

// {{{ catches

catches returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "catches" );
  }
  :
  { $v = ""; }
  ^( CATCH_CLAUSE_LIST
     { children( "catchClause" ); }
     ( catchClause {
       $v += ( _i++ == 0 ? "" : "/* catches */" )
  	 + $catchClause.v;
     } )+
   )
  ;

// }}}

// {{{ catchClause

catchClause returns [String v]
@init
  {
  nonterminal( "catchClause" ); 
  }
  :
  ^( ( CATCH {
       children( "CATCH" );
       $v = $CATCH.text;
     } )
     { $v += "("; }
     { $v += " "; }
     ( formalParameterStandardDecl {
       children( "formalParameterStandardDecl" );
       $v += " " + $formalParameterStandardDecl.v;
     } )
     { $v += " "; }
     { $v += ")"; }
     ( block {
       children( "block" );
       $v += " " + $block.s.string;
     } )
   )
  ;

// }}}

// {{{ switchBlockLabels

switchBlockLabels returns [String v]
@init
  {
  int _i = 0, _j = 0;
  nonterminal( "switchBlockLabels" );
  }
  :
  { $v = ""; }
  ^( SWITCH_BLOCK_LABEL_LIST
     ( aSwitchCaseLabel=switchCaseLabel {
       children( "aSwitchCaseLabel" );
       $v += ( _i++ == 0 ? "" : ";/* switchBlockLabels */" )
  	 + $aSwitchCaseLabel.v;
     } )*
     ( switchDefaultLabel {
       children( "SwitchDefaultLabel" );
       $v += ";" + " " + $switchDefaultLabel.v;
     } )?
     ( bSwitchCaseLabel=switchCaseLabel {
       children( "bSwitchCaseLabel" );
       $v += ( _j++ == 0 ? "" : ";/* switchBlockLabels */" )
  	 + $bSwitchCaseLabel.v;
     } )*
   )
  ;

// }}}

// {{{ switchCaseLabel

switchCaseLabel returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "switchCaseLabel" );
  }
  :
  ^( ( CASE {
       children( "CASE" );
       $v = $CASE.text;
     } )
     ( expression {
       children( "expression" );
       $v += " " + $expression.v;
     } )
     { $v += ":"; }
     ( blockStatement {
       children( "blockStatement" );
       $v += ( _i++ == 0 ? "" : ";/* switchCaseLabel */" )
  	 + $blockStatement.s.string;
     } )*
   )
  ;

// }}}

// {{{ switchDefaultLabel

switchDefaultLabel returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "switchDefaultLabel" );
  }
  :
  { $v = ""; }
  ^( DEFAULT
     { children( "blockStatement" ); }
     { $v += "default"; }
     { $v += ":"; }
     ( blockStatement {
       $v += ( _i++ == 0 ? "" : "/* switchDefaultLabel */" )
  	 + $blockStatement.s.string;
     } )*
   )
  ;

// }}}

// {{{ forInit

forInit returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "forInit" );
  }
  :
  { $v = ""; }
  ^( FOR_INIT
     ( ( localVariableDeclaration {
         children( "localVariableDeclaration" );
         $v = $localVariableDeclaration.v;
       } )
     | ( expression {
         children( "expression" );
         $v += ( _i++ == 0 ? "" : "/* forInit */" )
  	   + $expression.v;
       } )*
     )? 
   )
  ;

// }}}

// {{{ forCondition

forCondition returns [String v]
@init
  {
  nonterminal( "forCondition" );
  }
  :
  { $v = ""; }
  ^( FOR_CONDITION
     ( expression {
       children( "expression" );
       $v += $expression.v;
     } )?
   )
  ;

// }}}

// {{{ forUpdater

forUpdater returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "forUpdater" );
  }
  :
  { $v = ""; }
  ^( FOR_UPDATE
     { children( "expression" ); }
     ( expression {
       $v += ( _i++ == 0 ? "" : "/* forUpdater */" )
  	 + $expression.v;
     } )*
   )
  ;

// }}}

// EXPRESSIONS

// {{{ parenthesizedExpression

parenthesizedExpression returns [String v]
@init
  {
  nonterminal( "parenthesizedExpression" );
  }
  :
  { $v = "("; }
  { $v += " "; }
  ^( PARENTESIZED_EXPR
     ( expression {
       children( "expression" );
       $v += $expression.v;
     } )
   )
  { $v += " "; }
  { $v += ")"; }
  ;

// }}}

// {{{ expression

expression returns [String v]
@init
  {
  nonterminal( "expression" );
  }
  :
  ^( EXPR
     ( expr {
       children( "expr" );
       $v = $expr.v;
     } )
   )
  ;

// }}}

// {{{ expr

expr returns [String v]
@init
  {
  nonterminal( "expr" );
  }
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
@init
  { 
  nonterminal( "primaryExpression" );
  }
  :
  ^( ( DOT {
       children( "DOT" );
     } )
     ( ( aPrimaryExpression=primaryExpression {
         children( "aPrimaryExpression" );
         $v = " " + $aPrimaryExpression.v;
       } )
       { $v += $DOT.text; }
       ( ( IDENT {
           children( "IDENT" );
           $v += $IDENT.text;
         } )
       | ( THIS {
           children( "THIS" );
           $v += $THIS.text;
         } )
       | ( SUPER {
           children( "SUPER" );
           $v += $SUPER.text;
         } )
       | ( innerNewExpression {
           children( "innerNewExpression" );
           $v += $innerNewExpression.v;
         } )
       | ( bCLASS=CLASS {
           children( "bCLASS" );
           $v += $bCLASS.text;
         } )
       )
     | ( primitiveType {
         children( "primitiveType" );
         $v += $primitiveType.v;
       } )
       ( cCLASS=CLASS {
         children( "cCLASS" );
         $v += " " + $cCLASS.text;
       } )
     | ( VOID {
         children( "VOID" );
         $v += $VOID.text;
       } )
       ( dCLASS=CLASS {
         children( "dCLASS" );
         $v += " " + $dCLASS.text;
       } )
     )
  )
  |
  ( parenthesizedExpression {
    children( "parenthesizedExpression" );
    $v = $parenthesizedExpression.v;
  } )
  |
  ( IDENT {
    children( "IDENT" );
    $v = $IDENT.text;
  } )
  |
  ^( METHOD_CALL
     ( ePrimaryExpression=primaryExpression {
       children( "ePrimaryExpression" );
       $v = $ePrimaryExpression.v;
     } )
     ( genericTypeArgumentList {
       children( "genericTypeArgumentList" );
       $v += " " + $genericTypeArgumentList.v;
     } )?
     ( arguments {
       children( "arguments" );
       $v += " " + $arguments.v;
     } )
   )
  |
  ( explicitConstructorCall {
    children( "explicitConstructorCall" );
    $v = $explicitConstructorCall.v;
  } )
  |
  ^( ARRAY_ELEMENT_ACCESS
     ( fPrimaryExpression=primaryExpression {
       children( "fPrimaryExpression" );
       $v = $fPrimaryExpression.v;
     } )
     ( expression {
       children( "expression" );
       $v+="[";
       $v += $expression.v;
       $v+="]";
     } )
   )
  |
  ( literal {
    children( "literal" );
    $v = $literal.v;
  } )
  |
  ( newExpression {
    children( "newExpression" );
    $v = $newExpression.v;
  } )
  |
  ( THIS {
    children( "THIS" );
    $v = $THIS.text;
  } )
  |
  ( arrayTypeDeclarator {
    children( "arrayTypeDeclarator" );
    $v = $arrayTypeDeclarator.v;
  } )
  |
  ( SUPER {
    children( "SUPER" );
    $v = $SUPER.text;
  } )
  ;

// }}}

// {{{ explicitConstructorCall

explicitConstructorCall returns [String v]
@init
  {
  nonterminal( "explicitConstructorCall" );
  }
  :
  { $v = ""; }
  ^( THIS_CONSTRUCTOR_CALL
     ( genericTypeArgumentList {
       children( "genericTypeArgumentList" );
       $v += $genericTypeArgumentList.v;
     } )?
     ( arguments {
       $v += " " + $arguments.v;
     } )
   )
  |
  ^( SUPER_CONSTRUCTOR_CALL
     ( primaryExpression {
       children( "primaryExpression" );
       $v += $primaryExpression.v;
     } )?
     ( genericTypeArgumentList {
       children( "genericTypeArgumentList" );
       $v += " " + $genericTypeArgumentList.v;
     } )?
     ( arguments {
       children( "arguments" );
       $v += " " + $arguments.v;
     } )
   )
  ;

// }}}

// {{{ arrayTypeDeclarator

arrayTypeDeclarator returns [String v]
@init
  {
  nonterminal( "arrayTypeDeclarator" );
  }
  :
  ^( ARRAY_DECLARATOR
     ( ( aArrayTypeDeclarator=arrayTypeDeclarator {
         children( "aArrayTypeDeclarator" );
         $v = $aArrayTypeDeclarator.v;
       } )
       |
       ( qualifiedIdentifier {
         children( "qualifiedIdentifier" );
         $v = $qualifiedIdentifier.v;
       } )
       |
       ( primitiveType {
         children( "primitiveType" );
         $v = $primitiveType.v;
       } )
     )
   )
  ;

// }}}

// {{{ newExpression

newExpression returns [String v]
@init
  {
  nonterminal( "newExpression" );
  }
  :
  ^( STATIC_ARRAY_CREATOR
     ( { $v = "new"; }
       { $v += " "; }
       ( primitiveType {
         children( "primitiveType" );
         $v += $primitiveType.v;
       } )
       { $v += "["; }
       ( aNewArrayConstruction=newArrayConstruction {
         children( "aNewArrayConstruction" );
         $v += $aNewArrayConstruction.v;
       } )
       { $v += "]"; }
     | { $v="new";} ( genericTypeArgumentList {
         children( "genericTypeArgumentList" );
         $v += $genericTypeArgumentList.v;
       } )?
       ( qualifiedTypeIdent {
         children( "qualifiedTypeIdent" );
         $v += " " + $qualifiedTypeIdent.v;
       } )
       ( bNewArrayConstruction=newArrayConstruction {
         children( "bNewArrayConstruction" );
         $v += " " + $bNewArrayConstruction.v;
       } )
     )
   )
  |
  ^( CLASS_CONSTRUCTOR_CALL
     ( genericTypeArgumentList {
       children( "genericTypeArgumentList" );
       $v = $genericTypeArgumentList.v;
     } )?
     ( qualifiedTypeIdent {
       children( "qualifiedTypeIdent" );
       $v += " " + $qualifiedTypeIdent.v;
     } )
     ( arguments {
       children( "arguemnts" );
       $v += " " + $arguments.v;
     } )
     ( classTopLevelScope {
       children( "classTopLevelScope" );
       $v += " " + $classTopLevelScope.v;
     } )?
   )
  ;

// }}}

// {{{ innerNewExpression
// something like 'InnerType innerType = outer.new InnerType();'

innerNewExpression returns [String v]
@init
  {
  nonterminal( "innerNewExpression" );
  }
  :
  { $v = ""; }
  ^( CLASS_CONSTRUCTOR_CALL
     ( genericTypeArgumentList {
       children( "genericTypeArgumentList" );
       $v += $genericTypeArgumentList.v;
     } )?
     ( IDENT {
       children( "IDENT" );
       $v += " " + $IDENT.text;
     } )
     ( arguments {
       children( "arguments" );
       $v += " " + $arguments.v;
     } )
     ( classTopLevelScope {
       children( "classTopLevelScope" );
       $v += " " + $classTopLevelScope.v;
     } )?
   )
  ;

// }}}
    
// {{{ newArrayConstruction

newArrayConstruction returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "newArrayConstruction" );
  }
  :
  ( arrayDeclaratorList {
    children( "arrayDeclaratorList" );
    $v = $arrayDeclaratorList.v;
  } )
  ( arrayInitializer {
    children( "arrayInitializer" );
    $v += " " + $arrayInitializer.v;
  } )
  { $v += ";/*;5*/" + "\n"; }
  |
  { $v = ""; }
  ( expression {
    children( "expression" );
    $v += ( _i++ == 0 ? "" : "/* newArrayConstruction */" )
        + $expression.v;
  } )+
  ( arrayDeclaratorList {
    children( "arrayDeclaratorList" );
    $v += " " + $arrayDeclaratorList.v;
  } )?
  ;

// }}}

// {{{ arguments

arguments returns [String v]
@init
  {
  int _i = 0;
  nonterminal( "arguments" );
  }
  :
  { $v = "("; }
  { $v += " "; }
  ^( ARGUMENT_LIST
     { children( "expression" ); }
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
@init
  {
  nonterminal( "literal" ); 
  }
  :
  ( HEX_LITERAL {
    children( "HEX_LITERAL" );
    $v = $HEX_LITERAL.text;
  } )
  |
  ( OCTAL_LITERAL {
    children( "OCTAL_LITERAL" );
    $v = $OCTAL_LITERAL.text;
  } )
  |
  ( DECIMAL_LITERAL {
    children( "DECIMAL_LITERAL" );
    $v = $DECIMAL_LITERAL.text;
  } )
  |
  ( FLOATING_POINT_LITERAL {
    children( "FLOATING_POINT_LITERAL" );
    $v = $FLOATING_POINT_LITERAL.text;
  } )
  |
  ( CHARACTER_LITERAL {
    children( "CHARACTER_LITERAL" );
    $v = $CHARACTER_LITERAL.text;
  } )
  |
  ( STRING_LITERAL {
    children( "STRING_LITERAL" );
    $v = $STRING_LITERAL.text;
  } )
  |
  ( TRUE {
    children( "TRUE" );
    $v = $TRUE.text;
  } )
  |
  ( FALSE {
    children( "FALSE" );
    $v = $FALSE.text;
  } )
  |
  ( NULL {
    children( "NULL" );
    $v = $NULL.text;
  } )
  ;

// }}}

