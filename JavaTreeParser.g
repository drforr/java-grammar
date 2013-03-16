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

/* {{{ FULL GRAMMAR

// {{{ packageDeclaration

packageDeclaration returns [String value]
	:	^(PACKAGE qualifiedIdentifier)  
		{
			$value = $PACKAGE.text + " " +
				 $qualifiedIdentifier.value;
		}
	;

// }}}
    
importDeclaration returns [String value]
	:   ^(IMPORT STATIC? qualifiedIdentifier DOTSTAR?)
{
	$value = $STATIC.text + " " + $qualifiedIdentifier.value + " " + $DOTSTAR.text + "[importDeclaration]";
}
	;
    
typeDeclaration returns [String value]
	:   ^(CLASS modifierList IDENT
		genericTypeParameterList?
		extendsClause?
		implementsClause?
		classTopLevelScope)
{
	$value = $CLASS.text + " " +
		 $modifierList.value + " " +
		 $IDENT.text + " " +
		 $genericTypeParameterList.value +
		 $extendsClause.value + " " +
		 $implementsClause.value + " " +
		 $classTopLevelScope + " [typeDeclaration]";
}
	|   ^(INTERFACE modifierList IDENT
		    genericTypeParameterList?
		    extendsClause?
		    interfaceTopLevelScope)
{
	$value = $INTERFACE.text + " " +
		 $modifierList.value + " " +
		 $IDENT.text + " " +
		 $genericTypeParameterList.value + " " +
		 $extendsClause.value + " " + 
		 $interfaceTopLevelScope.value + " [typeDeclaration]";
}
	|   ^(ENUM modifierList IDENT implementsClause? enumTopLevelScope)
{
	$value = $ENUM.text + " " +
		 $modifierList.value + " " +
		 $IDENT.text + " " +
		 $implementsClause.value + " " +
		 $enumTopLevelScope + " [typeDeclaration]";
}
	|   ^(AT modifierList IDENT annotationTopLevelScope)
{
	$value = $AT.text + " " +
		 $modifierList + " " +
		 $IDENT.text + " " +
		 $annotationTopLevelScope.value + " [typeDeclaration]";
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

// {{{ variableInitializer

variableInitializer returns [String value]
	:	arrayInitializer
		{
			$value = $arrayInitializer.value;
		}
	|	expression
		{
			$value = $expression.value;
		}
	;

// }}}

// {{{ arrayDeclarator

arrayDeclarator returns [String value]
	:	LBRACK RBRACK
		{
			$value = $LBRACK.text + $RBRACK.text;
		}
	;

// }}}

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
	:   ^(LOCAL_MODIFIER_LIST localModifier*)
{
	$value = "[localModifierList]";
}
	;

// {{{ localModifier

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

// }}}

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
	:   ^(GENERIC_TYPE_ARG_LIST genericTypeArgument+)
{
	$value = "[genericTypeArgumentList]";
}
	;
    
genericTypeArgument returns [String value]
	:   type
{
	$value = "[genericTypeArgument 1]";
}
	|   ^(QUESTION genericWildcardBoundType?)
{
	$value = "[genericTypeArgument 2]";
}
	;

genericWildcardBoundType returns [String value]
	:   ^(EXTENDS type)
{
	$value = "[genericWildcardBoundType 1]";
}
	|   ^(SUPER type)
{
	$value = "[genericWildcardBoundType 2]";
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
	$value = "[annotationInitializers 1]";
}
	|   ^(ANNOTATION_INIT_DEFAULT_KEY annotationElementValue)
{
	$value = $annotationElementValue.value;
}
	;
    
annotationInitializer returns [String value]
	:   ^(IDENT annotationElementValue)
{
	$value = $annotationElementValue.value;
}
	;
    
annotationElementValue returns [String value]
	:   ^(ANNOTATION_INIT_ARRAY_ELEMENT annotationElementValue*)
	|   annotation
{
	$value = $annotation.value;
}
	|	expression
{
	$value = $expression.value;
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
	$value = $annotationElementValue.value;
}
	;

// STATEMENTS / BLOCKS

block returns [String value]
	:   ^(BLOCK_SCOPE blockStatement*)
{
	$value = "[block]";
}
	;
    
blockStatement returns [String value]
	:	localVariableDeclaration
		{
			$value = $localVariableDeclaration.value;
		}
	|	typeDeclaration
		{
			$value = $typeDeclaration.value;
		}
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
{
	$value = "[statement 1]";
}
	|   ^(ASSERT expression expression?)
{
	$value = "[statement 2]";
}
	|   ^(IF parenthesizedExpression statement statement?)
{
	$value = "[statement 3]";
}
	|   ^(FOR forInit forCondition forUpdater statement)
{
	$value = "[statement 4]";
}
	|   ^(FOR_EACH localModifierList type IDENT expression statement) 
	|	^(WHILE parenthesizedExpression a=statement)
		{
			$value = $WHILE.text + " " +
				 $parenthesizedExpression.value + " { " +
				 $a.value +
			         " } ";
		}
	|   ^(DO statement parenthesizedExpression)
{
	$value = "[statement 5]";
}
	|   ^(TRY block catches? block?)
            // The second optional block is the optional finally block.
{
	$value = "[statement 6]";
}
	|   ^(SWITCH parenthesizedExpression switchBlockLabels)
{
	$value = "[statement 7]";
}
	|   ^(SYNCHRONIZED parenthesizedExpression block)
{
	$value = "[statement 8]";
}
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
	$value = $expression.value != null ? $expression.value : "[forCondition null]";
}
	;
    
forUpdater returns [String value]
	:   ^(FOR_UPDATE expression*)
{
	$value = "[forUpdater]";
}
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
	|	^(INSTANCEOF a=expr type)
{
	$value = $a.value + " instanceof " + $type.value;
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
{
	$value = "(" + $type.value + ") [cast]" + $a.value;
}
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
	$value = "[foo 4]";
}
	|	explicitConstructorCall
		{
			$value = $explicitConstructorCall.value;
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
	|	newExpression
		{
			$value = $newExpression.value;
		}
	|	THIS
		{
			$value = $THIS.text;
		}
	|	arrayTypeDeclarator
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
	      (a=arrayTypeDeclarator | qualifiedIdentifier | primitiveType))
{
	if ( $a.value != null ) {
		$value = $a.value + " [arrayTypeDeclarator]";
	}
	else if ( $qualifiedIdentifier.value != null ) {
		$value = $qualifiedIdentifier.value + " [qualifiedIdentifier]";
	}
	else if ( $primitiveType.value != null ) {
		$value = $primitiveType.value + " [primitiveType]";
	}
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
	$value = $arrayDeclaratorList.value + " [newArrayConstruction] " +
		 $arrayInitializer.value;
}
	|   expression+ arrayDeclaratorList?
{
	$value = "[newArrayConstruction 2]";
}
	;

arguments returns [String value]
	:   ^(ARGUMENT_LIST expression*)
{
	$value = "[arguments]";
}
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

}}} */




// Starting point for parsing a Java file.
javaSource returns [String value]
    :	^(JAVA_SOURCE	annotationList
			packageDeclaration?
			importDeclaration*
			typeDeclaration*)
{
	$value = $annotationList.value + "\n" +
		 $packageDeclaration.value + "\n" +
		 $importDeclaration.value + "\n" +
		 $typeDeclaration.value + "{{javaSource}}";
}
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
	$value = "{{importDeclaration " +
		 $IMPORT.text + " " +
		 $STATIC.text + " " +
		 $qualifiedIdentifier.value + " " +
		 $DOTSTAR.text + "}}";
}
    ;
    
typeDeclaration returns [String value]
    :   ^(CLASS modifierList
	  IDENT genericTypeParameterList?
		extendsClause?
		implementsClause?
		classTopLevelScope)
{
	$value = "{{typeDeclaration[1] " +
		 $CLASS.text + " " +
		 $modifierList.value + " " +
		 $IDENT.text + " " +
		 $genericTypeParameterList.value + " " +
		 $extendsClause.value + " " +
		 $implementsClause.value + " " +
		 $classTopLevelScope.value + "}}";
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
		 $genericTypeParameterList.value + " " +
		 $extendsClause.value + " " +
		 $interfaceTopLevelScope.value + " " + "}}";
}
    |   ^(ENUM modifierList
	 IDENT implementsClause?
	       enumTopLevelScope)
{
	$value = "{{typeDeclaration[3] " +
		 $ENUM.text + " " +
		 $modifierList.value + " " +
	 	 $IDENT.text + " " +
		 $implementsClause.value + " " +
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
		  $bound.value + "}}";
}
    ;
        
bound returns [String value]
    :	{ $value = "{{bound"; }
   	^( EXTENDS_BOUND_LIST
	   ( type { $value += " " + $type.value; } )+ )
	{ $value += "}}"; }
    ;

enumTopLevelScope returns [String value]
    :   ^(ENUM_TOP_LEVEL_SCOPE enumConstant+ classTopLevelScope?)
{
	$value = "{{enumTopLevelScope " +
		 $ENUM_TOP_LEVEL_SCOPE.text + " " +
		 $enumConstant.value + " " +
		 $classTopLevelScope.value + "}}";
}
    ;
    
enumConstant returns [String value]
    :   ^(IDENT annotationList arguments? classTopLevelScope?)
{
	$value = "{{enumConstant " +
		 $IDENT.text + " " +
		 $annotationList.value + " " +
		 $arguments.value + " " +
		 $classTopLevelScope.value + "}}";
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
	$value = "{{classScopeDeclarations[1] " + $block.value +  "}}";
}
    |   ^(CLASS_STATIC_INITIALIZER block)
{
	$value = "{{classScopeDeclarations[2] " + $block.value +  "}}";
}
    |   ^(FUNCTION_METHOD_DECL modifierList
			       genericTypeParameterList?
			       type
			 IDENT formalParameterList
			       arrayDeclaratorList?
			       throwsClause?
			       block?)
{
	$value = "{{classScopeDeclarations[3] " +
		 $FUNCTION_METHOD_DECL.text + " " +
		 $modifierList.value + " " +
		 $genericTypeParameterList.value + " " +
		 $type.value + " " +
		 $IDENT.text + " " +
		 $formalParameterList.value + " " +
		 $arrayDeclaratorList.value + " " +
		 $throwsClause.value + " " +
		 $block.value + "}}";
}
    |   ^(VOID_METHOD_DECL modifierList
			   genericTypeParameterList?
		     IDENT formalParameterList
			   throwsClause?
			   block?)
{
	$value = "{{classScopeDeclarations[4] " +
		 $VOID_METHOD_DECL.text + " " +
		 $modifierList.value + " " +
		 $genericTypeParameterList.value + " " +
		 $IDENT.text + " " +
		 $formalParameterList.value + " " +
		 $throwsClause.value + " " +
		 $block.value + "}}";
}
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
{
	$value = "{{classScopeDeclarations[5] " +
		 $VAR_DECLARATION.text + " " +
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
		 $CONSTRUCTOR_DECL.text + " " +
		 $genericTypeParameterList.value + " " +
		 $formalParameterList.value + " " +
		 $throwsClause.value + " " +
		 $block.value + "}}";
}
    |   typeDeclaration
{
	$value = "{{classScopeDeclarations[7] " + $typeDeclaration.value + "}}";
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
    :   ^(FUNCTION_METHOD_DECL modifierList genericTypeParameterList? type IDENT formalParameterList arrayDeclaratorList? throwsClause?)
{
	$value = "{{interfaceTopLevelDeclarations[1] " +
		 $FUNCTION_METHOD_DECL.text + " " +
		 $modifierList.value + " " +
		 $genericTypeParameterList.value + " " +
		 $type.value + " " +
		 $IDENT.text + " " +
		 $formalParameterList.value + " " +
		 $arrayDeclaratorList.value + " " +
		 $throwsClause.value + "}}";
}
    |   ^(VOID_METHOD_DECL modifierList genericTypeParameterList? IDENT formalParameterList throwsClause?)
                         // Interface constant declarations have been switched to variable
                         // declarations by 'java.g'; the parser has already checked that
                         // there's an obligatory initializer.
{
	$value = "{{interfaceTopLevelDeclarations[2] " +
		 $VOID_METHOD_DECL.text + " " +
		 $modifierList.value + " " +
		 $genericTypeParameterList.value + " " +
		 $IDENT.text + " " +
		 $formalParameterList.value + " " +
		 $throwsClause.value + "}}";
}
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
{
	$value = "{{interfaceTopLevelDeclarations[3] " +
		 $VAR_DECLARATION.text + " " +
		 $modifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorList.value + "}}";
}
    |   typeDeclaration
{
	$value = "{{interfaceTopLevelDeclarations[4] " +
		 $typeDeclaration.value + "}}";
}
    ;

variableDeclaratorList returns [String value]
    :	{ $value = "{{variableDeclaratorList"; }
   	^( VAR_DECLARATOR_LIST
	   ( variableDeclarator
	     { $value += " " + $variableDeclarator.value; } )+ )
	{ $value += "}}"; }
    ;

variableDeclarator returns [String value]
    :   ^(VAR_DECLARATOR variableDeclaratorId variableInitializer?)
{
	$value = "{{variableDeclarator " +
		 $VAR_DECLARATOR.text + " " +
		 $variableDeclaratorId.value + " " +
		 $variableInitializer.value + "}}";
}
    ;
    
variableDeclaratorId returns [String value]
    :   ^(IDENT arrayDeclaratorList?)
{
	$value = "{{variableDeclaratorId " +
		 $IDENT.text + " " +
		 $arrayDeclaratorList.value + "}}";
}
    ;

variableInitializer returns [String value]
    :   arrayInitializer
{
	$value = "{{variableInitializer[1] " +
		 $arrayInitializer.value +
		 "}}";
}
    |   expression
{
	$value = "{{variableInitializer[2] " +
		 $expression.value +
		 "}}";
}
    ;

arrayDeclarator returns [String value]
    :   LBRACK RBRACK
{
	$value = "{{arrayDeclarator " + $LBRACK.text + $RBRACK.text + "}}";
}
    ;

arrayDeclaratorList returns [String value]
    :	{ $value = "{{arrayDeclaratorList"; }
   	^( ARRAY_DECLARATOR_LIST
	   ( ARRAY_DECLARATOR // This is [] from the grammar
	     { $value += " " + "[" + "]"; } )* )
	{ $value += "}}"; }
    ;
    
arrayInitializer returns [String value]
    :	{ $value = "{{arrayInitializer"; }
   	^( ARRAY_INITIALIZER
	   ( variableInitializer
	     { $value += " " + $variableInitializer.value; } )* )
	{ $value += "}}"; }
    ;

throwsClause returns [String value]
    :	{ $value = "{{throwsClause"; }
   	^( THROWS_CLAUSE
	   ( qualifiedIdentifier
	     { $value += " " + $qualifiedIdentifier.value; } )+ )
	{ $value += "}}"; }
    ;

modifierList returns [String value]
    :   { $value = "{{modifierList"; }
	^( MODIFIER_LIST
	   ( modifier { $value += " " + $modifier.value; } )* )
	{ $value += "}}"; }
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
    :   { $value = "{{localModifierList"; }
        ^( LOCAL_MODIFIER_LIST
	   ( localModifier
	     { $value += " " + $localModifier.value; } )* )
	{ $value += "}}"; }
    ;

localModifier returns [String value]
    :   FINAL
{
	$value = "{{localModifier[1] " + $FINAL.text + "}}";
}
    |   annotation
{
	$value = "{{localModifier[2] " + $annotation.value + "}}";
}
    ;

type returns [String value]
    :   ^(TYPE (primitiveType | qualifiedTypeIdent) arrayDeclaratorList?)
{
	$value = "{{type " +
		 $TYPE.text + " " +
		 $primitiveType.value + " " +
		 $qualifiedTypeIdent.value + " " +
		 $arrayDeclaratorList.value + "}}";
}
    ;

qualifiedTypeIdent returns [String value]
    :	{ $value = "{{qualifiedTypeIdent"; }
   	^( QUALIFIED_TYPE_IDENT
	   ( typeIdent
	     { $value += " " + $typeIdent.value; } )+ )
	{ $value += "}}"; }
    ;

typeIdent returns [String value]
    :   ^(IDENT genericTypeArgumentList?)
{
	$value = "{{typeIdent " +
		 $IDENT.text + " " +
	 	 $genericTypeArgumentList.value + "}}";
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
	$value = "{{genericTypeArgument[1] " + $type.value + "}}";
}
    |   ^(QUESTION genericWildcardBoundType?)
{
	$value = "{{genericTypeArgument[2] " +
		 $QUESTION.text + " " +
	 	 $genericWildcardBoundType.value + "}}";
}
    ;

genericWildcardBoundType returns [String value]
    :   ^(EXTENDS type)
{
	$value = "{{genericWildcardBoundType[1] " +
		 $EXTENDS.text + " " +
	 	 $type.value + "}}";
}
    |   ^(SUPER type)
{
	$value = "{{genericWildcardBoundType[2] " +
		 $SUPER.text + " " +
	 	 $type.value + "}}";
}
    ;

formalParameterList returns [String value]
    :	{ $value = "{{formalParameterList"; }
   	^( FORMAL_PARAM_LIST
	   ( formalParameterStandardDecl
	     { $value += " " + $formalParameterStandardDecl.value; } )*
	   ( formalParameterVarargDecl
	     { $value += " " + $formalParameterVarargDecl.value; } )? )
	{ $value += "}}"; }
    ;
    
formalParameterStandardDecl returns [String value]
    :   ^(FORMAL_PARAM_STD_DECL localModifierList
				type
				variableDeclaratorId)
{
	$value = "{{formalParameterStandardDecl " +
		 $FORMAL_PARAM_STD_DECL.text + " " +
		 $localModifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorId.value + "}}";
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
    :	{ $value = "{{annotationList"; }
   	^( ANNOTATION_LIST
	   ( annotation
	     { $value += " " + $annotation.value; } )* )
	{ $value += "}}"; }
    ;

annotation returns [String value]
    :   ^(AT qualifiedIdentifier annotationInit?)
{
	$value = "{{annotation " +
		 $AT.text + " " +
		 $qualifiedIdentifier.value + " " +
		 $annotationInit.value + "}}";
}
    ;
    
annotationInit returns [String value]
    :   ^(ANNOTATION_INIT_BLOCK annotationInitializers)
{
	$value = "{{annotationInit " +
		 $ANNOTATION_INIT_BLOCK.text + " " +
		 $annotationInitializers.value + "}}";
}
    ;

annotationInitializers returns [String value]
    :   ^(ANNOTATION_INIT_KEY_LIST annotationInitializer+)
{
	$value = "{{annotationInitializers[1] " +
		 $ANNOTATION_INIT_KEY_LIST.text + " " +
		 $annotationInitializer.value + "}}";
}
    |   ^(ANNOTATION_INIT_DEFAULT_KEY annotationElementValue)
{
	$value = "{{annotationInitializers[2] " +
		 $ANNOTATION_INIT_DEFAULT_KEY.text + " " +
		 $annotationElementValue.value + "}}";
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
    :   ^(ANNOTATION_INIT_ARRAY_ELEMENT a=annotationElementValue*)
{
	$value = "{{annotationElementValue[1] " +
		 $ANNOTATION_INIT_ARRAY_ELEMENT.text + " " +
		 $a.value + "}}";
}
    |   annotation
{
	$value = "{{annotationElementValue[2] " +
		 $annotation.value + "}}";
}
    |   expression
{
	$value = "{{annotationElementValue[3] " +
		 $expression.value + "}}";
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
    :   ^(ANNOTATION_METHOD_DECL modifierList type IDENT annotationDefaultValue?)
{
	$value = "{{annotationScopeDeclarations[1] " +
		 $ANNOTATION_METHOD_DECL.text + " " +
		 $modifierList.value + " " +
		 $type.value + " " +
		 $IDENT.text + " " +
		 $annotationDefaultValue.value + "}}";
}
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
{
	$value = "{{annotationScopeDeclarations[2] " +
		 $VAR_DECLARATION.text + " " +
		 $modifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorList.value + "}}";
}
    |   typeDeclaration
{
	$value = "{{annotationScopeDeclarations[3] " +
		 $typeDeclaration.value + "}}";
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
    :	{ $value = "{{block"; }
   	^( BLOCK_SCOPE
	   ( blockStatement
	     { $value += " " + $blockStatement.value; } )* )
	{ $value += "}}"; }
    ;
    
blockStatement returns [String value]
    :   localVariableDeclaration
{
	$value = "{{blockStatement[1] " +
		 $localVariableDeclaration.value + "}}";
}
    |   typeDeclaration
{
	$value = "{{blockStatement[2] " +
		 $typeDeclaration.value + "}}";
}
    |   statement
{
	$value = "{{blockStatement[3] " +
		 $statement.value + "}}";
}
    ;
    
localVariableDeclaration returns [String value]
    :   ^(VAR_DECLARATION localModifierList type variableDeclaratorList)
{
	$value = "{{localVariableDeclaration " +
		 $VAR_DECLARATION.text + " " +
		 $localModifierList.value + " " +
		 $type.value + " " +
		 $variableDeclaratorList.value + "}}";
}
    ;
    
        
statement returns [String value]
    :   block
{
	$value = "{{statement[1] " +
		 $block.value + "}}";
}
    |   ^(ASSERT a=expression b=expression?)
{
	$value = "{{statement[2] " +
		 $a.value + " " +
		 $b.value + "}}";
}
    |   ^(IF parenthesizedExpression a=statement b=statement?)
{
	$value = "{{statement[3] " +
		 $IF.text + " " +
		 $a.value + " " +
		 $b.value + "}}";
}
    |   ^(FOR forInit forCondition forUpdater a=statement)
{
	$value = "{{statement[4] " +
		 $FOR.text + " " +
		 $forInit.value + " " +
		 $forCondition.value + " " +
		 $forUpdater.value + " " +
		 $a.value + "}}";
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
	$value = "{{statement[6] " +
		 $WHILE.text + " " +
		 $parenthesizedExpression.value + " " +
		 $a.value + "}}";
}
    |   ^(DO a=statement parenthesizedExpression)
{
	$value = "{{statement[7] " +
		 $DO.text + " " +
		 $a.value + " " +
		 $parenthesizedExpression.value + "}}";
}
    |   ^(TRY a=block catches? b=block?)  // The second optional block is the optional finally block.
{
	$value = "{{statement[8] " +
		 $TRY.text + " " +
		 $a.value + " " +
		 $catches.value + " " +
		 $b.value + "}}";
}
    |   ^(SWITCH parenthesizedExpression switchBlockLabels)
{
	$value = "{{statement[9] " +
		 $SWITCH.text + " " +
		 $parenthesizedExpression.value + " " +
		 $switchBlockLabels.value + "}}";
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
	$value = "{{statement[11] " +
		 $RETURN.text + " " +
		 $expression.value + "}}";
}
    |   ^(THROW expression)
{
	$value = "{{statement[12] " +
		 $THROW.text + " " +
		 $expression.value + "}}";
}
    |   ^(BREAK IDENT?)
{
	$value = "{{statement[13] " +
		 $BREAK.text + " " +
		 $IDENT.text + "}}";
}
    |   ^(CONTINUE IDENT?)
{
	$value = "{{statement[14] " +
		 $CONTINUE.text + " " +
		 $IDENT.text + "}}";
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
	$value = "{{statement[16] " +
		 $expression.value + "}}";
}
    |   SEMI // Empty statement.
{
	$value = "{{statement[17] " +
		 $SEMI.text + "}}";
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
    :   ^(SWITCH_BLOCK_LABEL_LIST a=switchCaseLabel*
				  switchDefaultLabel?
				  b=switchCaseLabel*)
{
	$value = $SWITCH_BLOCK_LABEL_LIST.text + " " +
		 $a.value + " " +
		 $switchDefaultLabel.value + " " +
		 $b.value + "{{switchBlockLabels}}";
}
    ;
        
switchCaseLabel returns [String value]
    :	{ $value = "{{switchCaseLabel"; }
   	^( CASE
	   expression { $value += " " + $expression.value; }
	   ( blockStatement
	     { $value += " " + $blockStatement.value; } )* )
	{ $value += "}}"; }
    ;
    
switchDefaultLabel returns [String value]
    :	{ $value = "{{switchDefaultLabel"; }
   	^( DEFAULT
	   ( blockStatement
	     { $value += " " + $blockStatement.value; } )* )
	{ $value += "}}"; }
    ;
    
forInit returns [String value]
    :   ^(FOR_INIT (localVariableDeclaration | expression*)?)
{
	$value = $FOR_INIT.text + " " +
		 $localVariableDeclaration.value + " " +
		 $expression.value + "{{forInit}}";
}
    ;
    
forCondition returns [String value]
    :   ^(FOR_CONDITION expression?)
{
	$value = "{{forCondition " +
		 $FOR_CONDITION.text + " " +
		 $expression.value + "}}";
}
    ;
    
forUpdater returns [String value]
    :	{ $value = "{{forUpdater"; }
   	^( FOR_UPDATE
	   ( expression
	     { $value += " " + $expression.value; } )* )
	{ $value += "}}"; }
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
			$value = $lhs.value + " " + ">" + " " + $rhs.value;
		}
	|	^(SHIFT_LEFT lhs=expr rhs=expr)
		{
			$value = $lhs.value + " " +
				 $SHIFT_LEFT.text + " " +
				 $rhs.value;
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
			$value = $lhs.value + " " + "=" + " " + $rhs.value;
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
			$value = $lhs.value + " " +
				 $MOD.text + " " +
				 $rhs.value;
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
			$value = $NOT.text + $a.value;
		}
	|	^(LOGICAL_NOT a=expr)
		{
			$value = $LOGICAL_NOT.text + $a.value;
		}
	|	^(CAST_EXPR type a=expr)
{
	$value = "(" + $type.value + ") {{cast}}" + $a.value;
}
	|	primaryExpression
	 	{
			$value = $primaryExpression.value;
		}
	;
    
primaryExpression returns [String value]
    :   ^(  DOT
            (   a=primaryExpression
                (   IDENT
                |   THIS
                |   SUPER
                |   innerNewExpression
                |   A=CLASS
                )
            |   primitiveType B=CLASS
            |   VOID C=CLASS
            )
        )
{
	$value = "{{primaryExpression[1] " +
		 $DOT.text + " " +
		 $a.value + " " +
		 $IDENT.text + " " +
		 $THIS.text + " " +
		 $SUPER.text + " " +
		 $innerNewExpression.value + " " +
		 $A.text + " " +
		 $primitiveType.value + " " +
		 $B.text + " " +
		 $VOID.text + " " +
		 $C.text + " " + "}}";
}
    |   parenthesizedExpression
{
	$value = "{{primaryExpression[2] " +
		 $parenthesizedExpression.value + "}}";
}
    |   IDENT
{
	$value = "{{primaryExpression[3] " +
		 $IDENT.text + "}}";
}
    |   ^(METHOD_CALL a=primaryExpression genericTypeArgumentList? arguments)
{
	$value = "{{primaryExpression[4] " +
		 $METHOD_CALL.text + " " +
		 $a.value + " " +
		 $genericTypeArgumentList.value + " " +
		 $arguments.value + " " + "}}";
}
    |   explicitConstructorCall
{
	$value = "{{primaryExpression[5] " +
		 $explicitConstructorCall.value + " " + "}}";
}
    |   ^(ARRAY_ELEMENT_ACCESS a=primaryExpression expression)
{
	$value = "{{primaryExpression[6] " +
		 $ARRAY_ELEMENT_ACCESS.text + " " +
		 $a.value + " " +
		 $expression.value + " " + "}}";
}
    |   literal
{
	$value = "{{primaryExpression[7] " +
		 $literal.value + " " + "}}";
}
    |   newExpression
{
	$value = "{{primaryExpression[8] " +
		 $newExpression.value + " " + "}}";
}
    |   THIS
{
	$value = "{{primaryExpression[9] " +
		 $THIS.text + " " + "}}";
}
    |   arrayTypeDeclarator
{
	$value = "{{primaryExpression[10] " +
		 $arrayTypeDeclarator.value + " " + "}}";
}
    |   SUPER
{
	$value = "{{primaryExpression[11] " +
		 $SUPER.text + " " + "}}";
}
    ;
    
explicitConstructorCall returns [String value]
    :   ^(THIS_CONSTRUCTOR_CALL genericTypeArgumentList? arguments)
{
	$value = $THIS_CONSTRUCTOR_CALL.text + " " +
		 $genericTypeArgumentList.value + " " +
		 $arguments.value + " " + "{{explicitConstructorCall 1}}";
}
    |   ^(SUPER_CONSTRUCTOR_CALL primaryExpression? genericTypeArgumentList? arguments)
{
	$value = $SUPER_CONSTRUCTOR_CALL.text + " " +
		 $primaryExpression.value + " " +
		 $genericTypeArgumentList.value + " " +
		 $arguments.value + " " + "{{explicitConstructorCall 2}}";
}
    ;

arrayTypeDeclarator returns [String value]
    :   ^(ARRAY_DECLARATOR (a=arrayTypeDeclarator | qualifiedIdentifier | primitiveType))
{
	$value = $ARRAY_DECLARATOR.text + " " +
		 $a.value + " " +
		 $qualifiedIdentifier.value + " " +
		 $primitiveType.value + " " + "{{arrayTypeDeclarator}}}";
}
    ;

newExpression returns [String value]
    :   ^(  STATIC_ARRAY_CREATOR
            (   primitiveType a=newArrayConstruction
            |   genericTypeArgumentList? qualifiedTypeIdent b=newArrayConstruction
            )
        )
// Uncomment this and you get a stacktrace.
//{
//	$value = $STATIC_ARRAY_CREATOR.text + " " +
//		 $primitiveType.value + " " +
//		 $a.text + " " +
//		 $genericTypeArgumentList.value + " " +
//		 $qualifiedTypeIdent.value + " " +
//		 $b.value + " " + "{{newExpression 1}}}";
//}
    |   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList?
				 qualifiedTypeIdent
				 arguments
				 classTopLevelScope?)
// Uncomment this and you get a stacktrace.
//{
//	$value = $CLASS_CONSTRUCTOR_CALL.text + " " +
//		 $genericTypeArgumentList.value + " " +
//		 $qualifiedTypeIdent.text + " " +
//		 $arguments.value + " " +
//		 $classTopLevelScope.value + " " + "{{newExpression 2}}}";
//}
    ;

innerNewExpression returns [String value] // something like 'InnerType innerType = outer.new InnerType();'
    :   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList?
			   IDENT arguments
				 classTopLevelScope?)
{
	$value = $CLASS_CONSTRUCTOR_CALL.text + " " +
		 $genericTypeArgumentList.value + " " +
		 $IDENT.text + " " +
		 $arguments.value + " " +
		 $classTopLevelScope.value + " " + "{{innerNewExpression}}}";
}
    ;
    
newArrayConstruction returns [String value]
    :   arrayDeclaratorList arrayInitializer
{
	$value = $arrayDeclaratorList.value + " " +
		 $arrayInitializer.value + " " + "{{newArrayConstruction 1}}}";
}
    |   expression+ arrayDeclaratorList?
{
	$value = $expression.value + " " +
		 $arrayDeclaratorList.value + " " + "{{newArrayConstruction 2}}}";
}
    ;

arguments returns [String value]
    :	{ $value = "{{arguments"; }
   	^( ARGUMENT_LIST
	   ( expression
	     { $value += " " + $expression.value; } )* )
	{ $value += "}}"; }
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
