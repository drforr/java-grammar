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

// Starting point for parsing a Java file.
javaSource
	:   ^(JAVA_SOURCE annotationList
		          packageDeclaration?
		          importDeclaration*
		          typeDeclaration*)
	;

packageDeclaration
	:   ^(PACKAGE qualifiedIdentifier)  
	;
    
importDeclaration
	:   ^(IMPORT STATIC? qualifiedIdentifier DOTSTAR?)
	;
    
typeDeclaration
	:   ^(CLASS modifierList IDENT
		genericTypeParameterList?
		extendsClause?
		implementsClause?
		classTopLevelScope)
	|   ^(INTERFACE modifierList IDENT
		    genericTypeParameterList?
		    extendsClause?
		    interfaceTopLevelScope)
	|   ^(ENUM modifierList IDENT implementsClause? enumTopLevelScope)
	|   ^(AT modifierList IDENT annotationTopLevelScope)
	;

extendsClause // actually 'type' for classes and 'type+' for interfaces,
	      //  but this has been resolved by the parser grammar.
	:   ^(EXTENDS_CLAUSE type+)
	;   
    
implementsClause
	:   ^(IMPLEMENTS_CLAUSE type+)
	;
        
genericTypeParameterList
	:   ^(GENERIC_TYPE_PARAM_LIST genericTypeParameter+)
	;

genericTypeParameter
	:   ^(IDENT bound?)
	;
        
bound
	:   ^(EXTENDS_BOUND_LIST type+)
	;

enumTopLevelScope
	:   ^(ENUM_TOP_LEVEL_SCOPE enumConstant+ classTopLevelScope?)
	;
    
enumConstant
	:   ^(IDENT annotationList arguments? classTopLevelScope?)
	;
    
    
classTopLevelScope
	:   ^(CLASS_TOP_LEVEL_SCOPE classScopeDeclarations*)
	;
    
classScopeDeclarations
	:   ^(CLASS_INSTANCE_INITIALIZER block)
	|   ^(CLASS_STATIC_INITIALIZER block)
	|   ^(FUNCTION_METHOD_DECL
	  modifierList
	  genericTypeParameterList?
	  type
	  IDENT
	  formalParameterList
	  arrayDeclaratorList?
	  throwsClause? block?)
	|   ^(VOID_METHOD_DECL
	  modifierList
	  genericTypeParameterList?
	  IDENT
	  formalParameterList
	  throwsClause?
	  block?)
	|   ^(VAR_DECLARATION
	  modifierList
	  type
	  variableDeclaratorList)
	|   ^(CONSTRUCTOR_DECL
	  modifierList
	  genericTypeParameterList?
	  formalParameterList
	  throwsClause?
	  block)
	|   typeDeclaration
	;
    
interfaceTopLevelScope
	:   ^(INTERFACE_TOP_LEVEL_SCOPE interfaceScopeDeclarations*)
	;
    
interfaceScopeDeclarations
	:   ^(FUNCTION_METHOD_DECL
	  modifierList
	  genericTypeParameterList?
	  type
	  IDENT
	  formalParameterList
	  arrayDeclaratorList?
	  throwsClause?)
	|   ^(VOID_METHOD_DECL
	  modifierList
	  genericTypeParameterList?
	  IDENT
	  formalParameterList
	  throwsClause?)
			 // Interface constant declarations have been switched
			 // to variable declarations by 'java.g';
			 //  the parser has already checked that
			 // there's an obligatory initializer.
	|   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
	|   typeDeclaration
	;

variableDeclaratorList
	:   ^(VAR_DECLARATOR_LIST variableDeclarator+)
	;

variableDeclarator
	:   ^(VAR_DECLARATOR variableDeclaratorId variableInitializer?)
	;
    
variableDeclaratorId
	:   ^(IDENT arrayDeclaratorList?)
	;

variableInitializer
	:   arrayInitializer
	|   expression
		{ System.out.println( $expression.value ); }
	;

arrayDeclarator
	:   LBRACK RBRACK
	;

arrayDeclaratorList
	:   ^(ARRAY_DECLARATOR_LIST ARRAY_DECLARATOR*)  
	;
    
arrayInitializer
	:   ^(ARRAY_INITIALIZER variableInitializer*)
	;

throwsClause
	:   ^(THROWS_CLAUSE qualifiedIdentifier+)
	;

modifierList
	:   ^(MODIFIER_LIST modifier*)
	;

modifier
	:   PUBLIC
	|   PROTECTED
	|   PRIVATE
	|   STATIC
	|   ABSTRACT
	|   NATIVE
	|   SYNCHRONIZED
	|   TRANSIENT
	|   VOLATILE
	|   STRICTFP
	|   localModifier
	;

localModifierList
	:   ^(LOCAL_MODIFIER_LIST localModifier*)
	;

localModifier
	:   FINAL
	|   annotation
	;

type
	:   ^(TYPE (primitiveType | qualifiedTypeIdent) arrayDeclaratorList?)
	;

qualifiedTypeIdent
	:   ^(QUALIFIED_TYPE_IDENT typeIdent+) 
	;

typeIdent
	:   ^(IDENT genericTypeArgumentList?)
	;

primitiveType
	:   BOOLEAN
	|   CHAR
	|   BYTE
	|   SHORT
	|   INT
	|   LONG
	|   FLOAT
	|   DOUBLE
	;

genericTypeArgumentList
	:   ^(GENERIC_TYPE_ARG_LIST genericTypeArgument+)
	;
    
genericTypeArgument
	:   type
	|   ^(QUESTION genericWildcardBoundType?)
	;

genericWildcardBoundType
	:   ^(EXTENDS type)
	|   ^(SUPER type)
	;

formalParameterList
    :   ^(FORMAL_PARAM_LIST
          formalParameterStandardDecl*
          formalParameterVarargDecl?) 
    ;
    
formalParameterStandardDecl
	:   ^(FORMAL_PARAM_STD_DECL
	  localModifierList
	  type
	  variableDeclaratorId)
	;
    
formalParameterVarargDecl
	:   ^(FORMAL_PARAM_VARARG_DECL
	  localModifierList
	  type
	  variableDeclaratorId)
	;
    
qualifiedIdentifier
	:   IDENT
	|   ^(DOT qualifiedIdentifier IDENT)
	;
    
// ANNOTATIONS

annotationList
	:   ^(ANNOTATION_LIST annotation*)
	;

annotation
	:   ^(AT qualifiedIdentifier annotationInit?)
	;
    
annotationInit
	:   ^(ANNOTATION_INIT_BLOCK annotationInitializers)
	;

annotationInitializers
	:   ^(ANNOTATION_INIT_KEY_LIST annotationInitializer+)
	|   ^(ANNOTATION_INIT_DEFAULT_KEY annotationElementValue)
	;
    
annotationInitializer
	:   ^(IDENT annotationElementValue)
	;
    
annotationElementValue
	:   ^(ANNOTATION_INIT_ARRAY_ELEMENT annotationElementValue*)
	|   annotation
	|   expression
		{ System.out.println( $expression.value ); }
	;
    
annotationTopLevelScope
	:   ^(ANNOTATION_TOP_LEVEL_SCOPE annotationScopeDeclarations*)
	;
    
annotationScopeDeclarations
	:   ^(ANNOTATION_METHOD_DECL
	  modifierList
	  type
	  IDENT
	  annotationDefaultValue?)
	|   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
	|   typeDeclaration
	;
    
annotationDefaultValue
	:   ^(DEFAULT annotationElementValue)
	;

// STATEMENTS / BLOCKS

block
	:   ^(BLOCK_SCOPE blockStatement*)
	;
    
blockStatement
	:   localVariableDeclaration
	|   typeDeclaration
	|   statement
	;
    
localVariableDeclaration
	:   ^(VAR_DECLARATION localModifierList type variableDeclaratorList)
	;
    
        
statement
	:   block
	|   ^(ASSERT a=expression b=expression?)
//		{ System.out.println( $a.value ); }
	|   ^(IF parenthesizedExpression statement statement?)
	|   ^(FOR forInit forCondition forUpdater statement)
	|   ^(FOR_EACH localModifierList type IDENT expression statement) 
//		{ System.out.println( $expression.value ); }
	|   ^(WHILE parenthesizedExpression statement)
	|   ^(DO statement parenthesizedExpression)
	|   ^(TRY block catches? block?)
            // The second optional block is the optional finally block.
	|   ^(SWITCH parenthesizedExpression switchBlockLabels)
	|   ^(SYNCHRONIZED parenthesizedExpression block)
	|	^(RETURN expression?)
		{ System.out.println( $RETURN.text + " " + $expression.value ); }
	|	^(THROW expression)
		{ System.out.println( $THROW.text + " " + $expression.value ); }
	|   ^(BREAK IDENT?)
	|   ^(CONTINUE IDENT?)
	|   ^(LABELED_STATEMENT IDENT statement)
	|	expression
		{ System.out.println( $expression.value ); }
	|   SEMI // Empty statement.
	;
        
catches
	:   ^(CATCH_CLAUSE_LIST catchClause+)
	;
    
catchClause
	:   ^(CATCH formalParameterStandardDecl block)
	;

switchBlockLabels
	:   ^(SWITCH_BLOCK_LABEL_LIST switchCaseLabel* switchDefaultLabel? switchCaseLabel*)
	;
        
switchCaseLabel
	:   ^(CASE expression blockStatement*)
	;
    
switchDefaultLabel
	:   ^(DEFAULT blockStatement*)
	;
    
forInit
	:   ^(FOR_INIT (localVariableDeclaration | expression*)?)
	;
    
forCondition
	:   ^(FOR_CONDITION expression?)
	;
    
forUpdater
	:   ^(FOR_UPDATE expression*)
	;
    
// EXPRESSIONS

parenthesizedExpression
	:   ^(PARENTESIZED_EXPR expression)
	;
    
expression returns [String value]
	:	^(EXPR expr)
		{ $value = $expr.value; }
	;

expr returns [String value]
	:	^(ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " = " + $rhs.value; }
	|	^(PLUS_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " += " + $rhs.value; }
	|	^(MINUS_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " -= " + $rhs.value; }
	|	^(STAR_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " *= " + $rhs.value; }
	|	^(DIV_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " /= " + $rhs.value; }
	|	^(AND_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " &= " + $rhs.value; }
	|	^(OR_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " |= " + $rhs.value; }
	|	^(XOR_ASSIGN lhs=expr rhs=expr)
		{ $value = $lhs.value + " ^= " + $rhs.value; }
	|	^(MOD_ASSIGN expr expr)
		{ $value = "[mod_assign]"; }
	|	^(BIT_SHIFT_RIGHT_ASSIGN expr expr)
		{ $value = "[bsr_assign]"; }
	|	^(SHIFT_RIGHT_ASSIGN expr expr)
		{ $value = "[sr_assign]"; }
	|	^(SHIFT_LEFT_ASSIGN expr expr)
		{ $value = "[sl_assign]"; }
	|	^(QUESTION expr expr expr)
		{ $value = "[question]"; }
	|	^(LOGICAL_OR expr expr)
		{ $value = "[logical_or]"; }
	|	^(LOGICAL_AND expr expr)
		{ $value = "[logical_and]"; }
	|	^(OR lhs=expr rhs=expr)
		{ $value = $lhs.value + " |= " + $rhs.value; }
	|	^(XOR lhs=expr rhs=expr)
		{ $value = $lhs.value + " ^ " + $rhs.value; }
	|	^(AND lhs=expr rhs=expr)
		{ $value = $lhs.value + " & " + $rhs.value; }
	|	^(EQUAL lhs=expr rhs=expr)
		{ $value = $lhs.value + " == " + $rhs.value; }
	|	^(NOT_EQUAL lhs=expr rhs=expr)
		{ $value = $lhs.value + " != " + $rhs.value; }
	|	^(INSTANCEOF expr type)
		{ $value = "[instanceof]"; }
	|	^(LESS_OR_EQUAL lhs=expr rhs=expr)
		{ $value = $lhs.value + " <= " + $rhs.value; }
	|	^(GREATER_OR_EQUAL lhs=expr rhs=expr)
		{ $value = $lhs.value + " >= " + $rhs.value; }
	|	^(BIT_SHIFT_RIGHT expr expr)
		{ $value = "[1...assign]"; }
	|	^(SHIFT_RIGHT expr expr)
		{ $value = "[2...assign]"; }
	|	^(GREATER_THAN lhs=expr rhs=expr)
		{ $value = $lhs.value + " > " + $rhs.value; }
	|	^(SHIFT_LEFT expr expr)
		{ $value = "[4...assign]"; }
	|	^(LESS_THAN lhs=expr rhs=expr)
		{ $value = $lhs.value + " < " + $rhs.value; }
	|	^(PLUS lhs=expr rhs=expr)
		{ $value = $lhs.value + " + " + $rhs.value; }
	|	^(MINUS lhs=expr rhs=expr)
		{ $value = $lhs.value + " - " + $rhs.value; }
	|	^(STAR lhs=expr rhs=expr)
		{ $value = $lhs.value + " * " + $rhs.value; }
	|	^(DIV lhs=expr rhs=expr)
		{ $value = $lhs.value + " / " + $rhs.value; }
	|	^(MOD lhs=expr rhs=expr)
		{ $value = "[10...assign]"; }
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
		{ $value = "!" + $a.value; }
	|	^(LOGICAL_NOT a=expr)
		{ $value = "~" + $a.value; }
	|	^(CAST_EXPR type a=expr)
//		{ $value = "(" + $type.value + ")" + $a.value; }
	|	primaryExpression
	 	{ $value = $primaryExpression.value; }
	;
    
primaryExpression returns [String value]
	:   ^(  DOT
	        (   primaryExpression
	            (   IDENT
	            |   THIS
	            |   SUPER
	            |   innerNewExpression
	            |   CLASS
	            )
	        |   primitiveType CLASS
	        |   VOID CLASS
	        )
	    )
{$value=new String("foo 1");}
	|   parenthesizedExpression
{$value=new String("foo 2");}
	|	IDENT
		{ $value = $IDENT.text; }
	|   ^(METHOD_CALL primaryExpression genericTypeArgumentList? arguments)
{$value=new String("foo 4");}
	|   explicitConstructorCall
{$value=new String("foo 5");}
	|	^(ARRAY_ELEMENT_ACCESS variable=primaryExpression expression)
		{ $value = $variable.value + "[" + $expression.value + "]"; }
	|	literal
		{ $value = $literal.value; }
	|   newExpression
{$value=new String("foo 8");}
	|   THIS
{$value=new String("foo 9");}
	|   arrayTypeDeclarator
{$value=new String("foo 10");}
	|   SUPER
{$value=new String("foo 11");}
	;
    
explicitConstructorCall
	:   ^(THIS_CONSTRUCTOR_CALL genericTypeArgumentList? arguments)
	|   ^(SUPER_CONSTRUCTOR_CALL
	      primaryExpression?
	      genericTypeArgumentList?
	      arguments)
	;

arrayTypeDeclarator
	:   ^(ARRAY_DECLARATOR
	      (arrayTypeDeclarator | qualifiedIdentifier | primitiveType))
	;

newExpression
	:   ^(  STATIC_ARRAY_CREATOR
	        (   primitiveType newArrayConstruction
	        |   genericTypeArgumentList?
                    qualifiedTypeIdent
                    newArrayConstruction
	        )
	    )
	|   ^(CLASS_CONSTRUCTOR_CALL
	      genericTypeArgumentList?
	      qualifiedTypeIdent
	      arguments
	      classTopLevelScope?)
	;

// something like 'InnerType innerType = outer.new InnerType();'
innerNewExpression 
	:   ^(CLASS_CONSTRUCTOR_CALL
	      genericTypeArgumentList?
	      IDENT
	      arguments
	      classTopLevelScope?)
	;
    
newArrayConstruction
	:   arrayDeclaratorList arrayInitializer
	|   expression+ arrayDeclaratorList?
	;

arguments
	:   ^(ARGUMENT_LIST expression*)
	;

/* {{{ literal */

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

/* }}} */
