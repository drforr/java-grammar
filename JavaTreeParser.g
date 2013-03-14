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
{ System.out.println( $packageDeclaration.value ); }
	;

/* {{{ packageDeclaration */

packageDeclaration returns [String value]
	:	^(PACKAGE qualifiedIdentifier)  
		{
			$value = $PACKAGE.text + " " +
				 $qualifiedIdentifier.value;
		}
	;

/* }}} */
    
importDeclaration returns [String value]
	:   ^(IMPORT STATIC? qualifiedIdentifier DOTSTAR?)
{
	$value = "[importDeclaration]";
}
	;
    
typeDeclaration returns [String value]
	:   ^(CLASS modifierList IDENT
		genericTypeParameterList?
		extendsClause?
		implementsClause?
		classTopLevelScope)
{
	$value = "[typeDeclaration 1]";
}
	|   ^(INTERFACE modifierList IDENT
		    genericTypeParameterList?
		    extendsClause?
		    interfaceTopLevelScope)
{
	$value = "[typeDeclaration 2]";
}
	|   ^(ENUM modifierList IDENT implementsClause? enumTopLevelScope)
{
	$value = "[typeDeclaration 3]";
}
	|   ^(AT modifierList IDENT annotationTopLevelScope)
{
	$value = "[typeDeclaration 4]";
}
	;

extendsClause // actually 'type' for classes and 'type+' for interfaces,
	      //  but this has been resolved by the parser grammar.
	returns [String value]
	:   ^(EXTENDS_CLAUSE type+)
{
	$value = "[extendsClause]";
}
	;   
    
implementsClause returns [String value]
	:   ^(IMPLEMENTS_CLAUSE type+)
{
	$value = "[implementsClause]";
}
	;
        
genericTypeParameterList returns [String value]
	:   ^(GENERIC_TYPE_PARAM_LIST genericTypeParameter+)
{
	$value = "[genericTypeParameterList]";
}
	;

genericTypeParameter returns [String value]
	:   ^(IDENT bound?)
{
	$value = "[genericTypeParameter]";
}
	;
        
bound returns [String value]
	:   ^(EXTENDS_BOUND_LIST type+)
{
	$value = "[bound]";
}
	;

enumTopLevelScope returns [String value]
	:   ^(ENUM_TOP_LEVEL_SCOPE enumConstant+ classTopLevelScope?)
{
	$value = "[enumTopLevelScope]";
}
	;
    
enumConstant returns [String value]
	:   ^(IDENT annotationList arguments? classTopLevelScope?)
{
	$value = "[enumConstant]";
}
	;
    
    
classTopLevelScope returns [String value]
	:   ^(CLASS_TOP_LEVEL_SCOPE classScopeDeclarations*)
{
	$value = "[classTopLevelScope]";
}
	;
    
classScopeDeclarations returns [String value]
	:   ^(CLASS_INSTANCE_INITIALIZER block)
{
	$value = "[classScopeDeclarations 1]";
}
	|   ^(CLASS_STATIC_INITIALIZER block)
{
	$value = "[classScopeDeclarations 2]";
}
	|   ^(FUNCTION_METHOD_DECL modifierList
				   genericTypeParameterList?
				   type
			     IDENT formalParameterList
				   arrayDeclaratorList?
				   throwsClause? block?)
{
	$value = "[classScopeDeclarations 3]";
}
	|   ^(VOID_METHOD_DECL modifierList
			       genericTypeParameterList?
			 IDENT formalParameterList
			       throwsClause?
			       block?)
{
	$value = "[classScopeDeclarations 4]";
}
	|   ^(VAR_DECLARATION modifierList
			      type
			      variableDeclaratorList)
{
	$value = "[classScopeDeclarations 5]";
}
	|   ^(CONSTRUCTOR_DECL modifierList
			       genericTypeParameterList?
			       formalParameterList
			       throwsClause?
			       block)
{
	$value = "[classScopeDeclarations 6]";
}
	|   typeDeclaration
{
	$value = "[classScopeDeclarations 7]";
}
	;
    
interfaceTopLevelScope returns [String value]
	:   ^(INTERFACE_TOP_LEVEL_SCOPE interfaceScopeDeclarations*)
{
	$value = "[interfaceTopLevelScope]";
}
	;
    
interfaceScopeDeclarations returns [String value]
	:   ^(FUNCTION_METHOD_DECL modifierList
				   genericTypeParameterList?
				   type
			     IDENT formalParameterList
				   arrayDeclaratorList?
				   throwsClause?)
{
	$value = "[interfaceScopeDeclarations 1]";
}
	|   ^(VOID_METHOD_DECL modifierList
			       genericTypeParameterList?
			 IDENT formalParameterList
			       throwsClause?)
			 // Interface constant declarations have been switched
			 // to variable declarations by 'java.g';
			 //  the parser has already checked that
			 // there's an obligatory initializer.
{
	$value = "[interfaceScopeDeclarations 2]";
}
	|   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
{
	$value = "[interfaceScopeDeclarations 3]";
}
	|   typeDeclaration
{
	$value = "[interfaceScopeDeclarations 4]";
}
	;

variableDeclaratorList returns [String value]
	:   ^(VAR_DECLARATOR_LIST variableDeclarator+)
{
	$value = "[variableDeclaratorList]";
}
	;

variableDeclarator returns [String value]
	:   ^(VAR_DECLARATOR variableDeclaratorId variableInitializer?)
{
	$value = "[variableDeclarator]";
}
	;
    
variableDeclaratorId returns [String value]
	:   ^(IDENT arrayDeclaratorList?)
{
	$value = "[variableDeclaratorId]";
}
	;

/* {{{ variableInitializer */

variableInitializer
	:	arrayInitializer
		{
			System.out.println( $arrayInitializer.value );
		}
	|	expression
		{
			System.out.println( $expression.value );
		}
	;

/* }}} */

/* {{{ arrayDeclarator */

arrayDeclarator returns [String value]
	:	LBRACK RBRACK
		{
			$value = $LBRACK.text + $RBRACK.text;
		}
	;

/* }}} */

arrayDeclaratorList returns [String value]
	:   ^(ARRAY_DECLARATOR_LIST ARRAY_DECLARATOR*)  
{
	$value = "[arrayDeclaratorList]";
}
	;
    
arrayInitializer returns [String value]
	:   ^(ARRAY_INITIALIZER variableInitializer*)
{
	$value = "[arrayInitialized]";
}
	;

throwsClause returns [String value]
	:   ^(THROWS_CLAUSE qualifiedIdentifier+)
{
	$value = "[throwsClause]";
}
	;

modifierList returns [String value]
	:   ^(MODIFIER_LIST modifier*)
{
	$value = "[modifierList]";
}
	;

/* {{{ modifier */

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

/* }}} */

localModifierList returns [String value]
	:   ^(LOCAL_MODIFIER_LIST localModifier*)
{
	$value = "[localModifierList]";
}
	;

/* {{{ localModifier */

localModifier returns [String value]
	:	FINAL
		{
			$value = $FINAL.text;
		}
	|	annotation
		{
			$value = $annotation.value;
		}
	;

/* }}} */

type returns [String value]
	:   ^(TYPE (primitiveType | qualifiedTypeIdent) arrayDeclaratorList?)
{
	$value = "[type]";
}
	;

qualifiedTypeIdent returns [String value]
	:   ^(QUALIFIED_TYPE_IDENT typeIdent+) 
{
	$value = "[qualifiedTypeIdent]";
}
	;

typeIdent returns [String value]
	:   ^(IDENT genericTypeArgumentList?)
{
	$value = "[typeIdent]";
}
	;

/* {{{ primitiveType */

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

/* }}} */

genericTypeArgumentList returns [String value]
	:   ^(GENERIC_TYPE_ARG_LIST genericTypeArgument+)
{
	$value = "[genericTypeArgumentList]";
}
	;
    
genericTypeArgument returns [String value]
	:   type
{
	$value = "[genericTypeArgument]";
}
	|   ^(QUESTION genericWildcardBoundType?)
{
	$value = "[genericTypeArgument]";
}
	;

genericWildcardBoundType returns [String value]
	:   ^(EXTENDS type)
{
	$value = "[genericWildcardBoundType]";
}
	|   ^(SUPER type)
{
	$value = "[genericWildcardBoundType]";
}
	;

formalParameterList returns [String value]
	:   ^(FORMAL_PARAM_LIST formalParameterStandardDecl*
				formalParameterVarargDecl?) 
{
	$value = "[formalParameterList]";
}
	;
    
formalParameterStandardDecl returns [String value]
	:   ^(FORMAL_PARAM_STD_DECL localModifierList
				    type
				    variableDeclaratorId)
{
	$value = "[formalParameterStandardDecl]";
}
	;
    
formalParameterVarargDecl returns [String value]
	:   ^(FORMAL_PARAM_VARARG_DECL localModifierList
				       type
				       variableDeclaratorId)
{
	$value = "[formalParameterVarargDecl]";
}
	;
    
/* {{{ qualifiedIdentifier */

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

/* }}} */
    
// ANNOTATIONS

annotationList returns [String value]
	:   ^(ANNOTATION_LIST annotation*)
{
	$value = "[annotationList]";
}
	;

annotation returns [String value]
	:   ^(AT qualifiedIdentifier annotationInit?)
{
	$value = "[annotation]";
}
	;
    
annotationInit
	returns [String value]
	:   ^(ANNOTATION_INIT_BLOCK annotationInitializers)
{
	$value = "[annotationInit]";
}
	;

annotationInitializers returns [String value]
	:   ^(ANNOTATION_INIT_KEY_LIST annotationInitializer+)
{
	$value = "[annotationInitializers]";
}
	|   ^(ANNOTATION_INIT_DEFAULT_KEY annotationElementValue)
{
	$value = "[annotationInitializers]";
}
	;
    
annotationInitializer returns [String value]
	:   ^(IDENT annotationElementValue)
{
	$value = "[annotationInitializer]";
}
	;
    
annotationElementValue
	:   ^(ANNOTATION_INIT_ARRAY_ELEMENT annotationElementValue*)
	|   annotation
	|	expression
{
	System.out.println( $expression.value );
}
	;
    
annotationTopLevelScope returns [String value]
	:   ^(ANNOTATION_TOP_LEVEL_SCOPE annotationScopeDeclarations*)
{
	$value = "[annotationTopLevelScope]";
}
	;
    
annotationScopeDeclarations returns [String value]
	:   ^(ANNOTATION_METHOD_DECL modifierList type
			       IDENT annotationDefaultValue?)
{
	$value = "[annotationScopeDeclarations]";
}
	|   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
{
	$value = "[annotationScopeDeclarations]";
}
	|   typeDeclaration
{
	$value = "[annotationScopeDeclarations]";
}
	;
    
annotationDefaultValue returns [String value]
	:   ^(DEFAULT annotationElementValue)
{
	$value = "[annotationDefaultValue]";
}
	;

// STATEMENTS / BLOCKS

block
	returns [String value]
	:   ^(BLOCK_SCOPE blockStatement*)
{
	$value = "[block]";
}
	;
    
blockStatement
	:   localVariableDeclaration
	|   typeDeclaration
	|	statement
{
	System.out.println( $statement.value );
}
	;
    
localVariableDeclaration returns [String value]
	:   ^(VAR_DECLARATION localModifierList type variableDeclaratorList)
{
	$value = "[localVariableDeclaration]";
}
	;
    
        
statement returns [String value]
	:   block
	|   ^(ASSERT expression expression?)
	|   ^(IF parenthesizedExpression statement statement?)
	|   ^(FOR forInit forCondition forUpdater statement)
	|   ^(FOR_EACH localModifierList type IDENT expression statement) 
	|	^(WHILE parenthesizedExpression a=statement)
		{
			$value = $WHILE.text + " " +
				 $parenthesizedExpression.value + " { " +
				 $a.value +
			         " } ";
		}
	|   ^(DO statement parenthesizedExpression)
	|   ^(TRY block catches? block?)
            // The second optional block is the optional finally block.
	|   ^(SWITCH parenthesizedExpression switchBlockLabels)
	|   ^(SYNCHRONIZED parenthesizedExpression block)
	|	^(RETURN expression?)
		{
			if ( $expression.value != null ) {
				$value = $RETURN.text + " " + $expression.value;
			}
			else {
				$value = $RETURN.text;
			}
		}
	|	^(THROW expression)
		{
			$value = $THROW.text + " " + $expression.value;
		}
	|	^(BREAK IDENT?)
		{
			if ( $IDENT.text != null ) {
				$value = $BREAK.text + " " + $IDENT.text;
			}
			else {
				$value = $BREAK.text;
			}
		}
	|	^(CONTINUE IDENT?)
		{
			if ( $IDENT.text != null ) {
				$value = $CONTINUE.text + " " + $IDENT.text;
			}
			else {
				$value = $CONTINUE.text;
			}
		}
	|	^(LABELED_STATEMENT IDENT a=statement)
		{
			$value = $IDENT.text + ": " + $a.value;
		}
	|	expression
		{
			$value = $expression.value;
		}
	|	SEMI // Empty statement.
		{
			$value = $SEMI.text;
		}
	;
        
catches returns [String value]
	:   ^(CATCH_CLAUSE_LIST catchClause+)
{
	$value = "[catches]";
}
	;
    
catchClause returns [String value]
	:   ^(CATCH formalParameterStandardDecl block)
{
	$value = "[catchClause]";
}
	;

switchBlockLabels returns [String value]
	:   ^(SWITCH_BLOCK_LABEL_LIST switchCaseLabel*
				      switchDefaultLabel?
				      switchCaseLabel*)
{
	$value = "[switchBlockLabels]";
}
	;
        
switchCaseLabel returns [String value]
	:   ^(CASE expression blockStatement*)
{
	$value = "[switchCaseLabel]";
}
	;
    
switchDefaultLabel returns [String value]
	:   ^(DEFAULT blockStatement*)
{
	$value = "[switchDefaultLabel]";
}
	;
    
forInit returns [String value]
	:   ^(FOR_INIT (localVariableDeclaration | expression*)?)
{
	$value = "[forInit]";
}
	;
    
forCondition returns [String value]
	:   ^(FOR_CONDITION expression?)
{
	$value = "[forCondition]";
}
	;
    
forUpdater returns [String value]
	:   ^(FOR_UPDATE expression*)
{
	$value = "[forUpdater]";
}
	;
    
// EXPRESSIONS

/* {{{ parenthesizedExpression */

parenthesizedExpression returns [String value]
	:	^(PARENTESIZED_EXPR expression)
		{
			$value = "( " + $expression.value + " )";
		}
	;

/* }}} */

/* {{{ expression */
    
expression returns [String value]
	:	^(EXPR expr)
		{
			$value = $expr.value;
		}
	;

/* }}} */

expr returns [String value]
	:	^(ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(PLUS_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $PLUS_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(MINUS_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $MINUS_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(STAR_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $STAR_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(DIV_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $DIV_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(AND_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $AND_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(OR_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $OR_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(XOR_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $XOR_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(MOD_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $MOD_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(BIT_SHIFT_RIGHT_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $BIT_SHIFT_RIGHT_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(SHIFT_RIGHT_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $SHIFT_RIGHT_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(SHIFT_LEFT_ASSIGN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $SHIFT_LEFT_ASSIGN.text + " " +
				 $rhs.value;
		}
	|	^(QUESTION a=expr b=expr c=expr)
		{
			$value = $a.value + " ? " + $b.value + " : " + $c.value;
		}
	|	^(LOGICAL_OR lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $LOGICAL_OR.text + " " +
				 $rhs.value;
		}
	|	^(LOGICAL_AND lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $LOGICAL_AND.text + " " +
				 $rhs.value;
		}
	|	^(OR lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $OR.text + " " +
				 $rhs.value;
		}
	|	^(XOR lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $XOR.text + " " +
				 $rhs.value;
		}
	|	^(AND lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $AND.text + " " +
				 $rhs.value;
		}
	|	^(EQUAL lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $EQUAL.text + " " +
				 $rhs.value;
		}
	|	^(NOT_EQUAL lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $NOT_EQUAL.text + " " +
				 $rhs.value;
		}
	|	^(INSTANCEOF expr type)
		{
			$value = "[instanceof]";
		}
	|	^(LESS_OR_EQUAL lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $LESS_OR_EQUAL.text + " " +
				 $rhs.value;
		}
	|	^(GREATER_OR_EQUAL lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $GREATER_OR_EQUAL.text + " " +
				 $rhs.value;
		}
	|	^(BIT_SHIFT_RIGHT lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $BIT_SHIFT_RIGHT.text + " " +
				 $rhs.value;
		}
	|	^(SHIFT_RIGHT lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $SHIFT_RIGHT.text + " " +
				 $rhs.value;
		}
	|	^(GREATER_THAN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $GREATER_THAN.text + " " +
				 $rhs.value;
		}
	|	^(SHIFT_LEFT lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $SHIFT_LEFT.text + " " +
				 $rhs.value;
		}
	|	^(LESS_THAN lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $LESS_THAN.text + " " +
				 $rhs.value;
		}
	|	^(PLUS lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $PLUS.text + " " +
				 $rhs.value;
		}
	|	^(MINUS lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $MINUS.text + " " +
				 $rhs.value;
		}
	|	^(STAR lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $STAR.text + " " +
				 $rhs.value;
		}
	|	^(DIV lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $DIV.text + " " +
				 $rhs.value;
		}
	|	^(MOD lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $MOD.text + " " +
				 $rhs.value;
		}
	|	^(UNARY_PLUS a=expr)
		{
			$value = $UNARY_PLUS.text + $a.value;
		}
	|	^(UNARY_MINUS a=expr)
		{
			$value = $UNARY_MINUS.text + $a.value;
		}
	|	^(PRE_INC a=expr)
		{
			$value = $PRE_INC.text + $a.value;
		}
	|	^(PRE_DEC a=expr)
		{
			$value = $PRE_DEC.text + $a.value;
		}
	|	^(POST_INC a=expr)
		{
			$value = $a.value + $POST_INC.text;
		}
	|	^(POST_DEC a=expr)
		{
			$value = $a.value + $POST_DEC.text;
		}
	|	^(NOT a=expr)
		{
			$value = $NOT.text + $a.value;
		}
	|	^(LOGICAL_NOT a=expr)
		{
			$value = $LOGICAL_NOT.text + $a.value;
		}
	|	^(CAST_EXPR type a=expr)
//		{ $value = "(" + $type.value + ")" + $a.value; }
	|	primaryExpression
	 	{
			$value = $primaryExpression.value;
		}
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
{
	$value=new String("[foo 1]");
}
	|	parenthesizedExpression
		{
			$value = $parenthesizedExpression.value;
		}
	|	IDENT
		{
			$value = $IDENT.text;
		}
	|   ^(METHOD_CALL primaryExpression genericTypeArgumentList? arguments)
{
	$value=new String("[foo 4]");
}
	|   explicitConstructorCall
{
	$value=new String("[foo 5]");
}
	|	^(ARRAY_ELEMENT_ACCESS variable=primaryExpression expression)
		{
			$value = $variable.value +
				 "[" + $expression.value + "]";
		}
	|	literal
		{
			$value = $literal.value;
		}
	|   newExpression
		{
			$value = $newExpression.value;
		}
	|	THIS
		{
			$value = $THIS.text;
		}
	|   arrayTypeDeclarator
		{
			$value = $arrayTypeDeclarator.value;
		}
	|	SUPER
		{
			$value = $SUPER.text;
		}
	;
    
explicitConstructorCall returns [String value]
	:   ^(THIS_CONSTRUCTOR_CALL genericTypeArgumentList? arguments)
{
	$value = "[explicitConstructorCall]";
}
	|   ^(SUPER_CONSTRUCTOR_CALL primaryExpression?
				     genericTypeArgumentList?
				     arguments)
{
	$value = "[explicitConstructorCall]";
}
	;

arrayTypeDeclarator returns [String value]
	:   ^(ARRAY_DECLARATOR
	      (arrayTypeDeclarator | qualifiedIdentifier | primitiveType))
{
	$value = "[arrayTypeDeclarator]";
}
	;

newExpression returns [String value]
	:   ^(  STATIC_ARRAY_CREATOR
	        (   primitiveType newArrayConstruction
	        |   genericTypeArgumentList?
                    qualifiedTypeIdent
                    newArrayConstruction
	        )
	    )
{
	$value = "[newExpression]";
}
	|   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList?
				     qualifiedTypeIdent
				     arguments
				     classTopLevelScope?)
{
	$value = "[newExpression]";
}
	;

// something like 'InnerType innerType = outer.new InnerType();'
innerNewExpression returns [String value]
	:   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList?
			       IDENT arguments
				     classTopLevelScope?)
{
	$value = "[innerNewExpression]";
}
	;
    
newArrayConstruction returns [String value]
	:   arrayDeclaratorList arrayInitializer
{
	$value = "[newArrayConstruction]";
}
	|   expression+ arrayDeclaratorList?
{
	$value = "[newArrayConstruction]";
}
	;

arguments returns [String value]
	:   ^(ARGUMENT_LIST expression*)
{
	$value = "[arguments]";
}
	;

/* {{{ literal */

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

/* }}} */
