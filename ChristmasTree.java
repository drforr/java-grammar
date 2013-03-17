/* {{{ Full nested list
javaSource {
  annotationList {
    annotation* {
      AT
      qualifiedIdentifier {
        IDENT
      | DOT
	qualifiedIdentifier // Recursive
	IDENT
      }
      annotationInit? {
	annotationInitializers {
          ANNOTATION_INIT_KEY_LIST
	  annotationInitializer+ {
            IDENT
	    annotationElementValue {
              annotationElementValue* // Recursive
            | annotation // Previously defined
            | expression {
                expr {
                  ASSIGN expr expr
                | PLUS_ASSIGN expr expr
                | MINUS_ASSIGN expr expr
                | STAR_ASSIGN expr expr
                | DIV_ASSIGN expr expr
                | AND_ASSIGN expr expr
                | OR_ASSIGN expr expr
                | XOR_ASSIGN expr expr
                | MOD_ASSIGN expr expr
                | BIT_SHIFT_RIGHT_ASSIGN expr expr
                | SHIFT_RIGHT_ASSIGN expr expr
                | SHIFT_LEFT_ASSIGN expr expr
                | QUESTION expr expr expr
                | LOGICAL_OR expr expr
                | LOGICAL_AND expr expr
                | OR expr expr
                | XOR expr expr
                | AND expr expr
                | EQUAL expr expr
                | NOT_EQUAL expr expr
                | INSTANCEOF
                  expr
                  type {
	            ( primitiveType {
                        BOOLEAN
                      | CHAR
                      | BYTE
                      | SHORT
                      | INT
                      | LONG
                      | FLOAT
                      | DOUBLE
                      }
	            | qualifiedTypeIdent { )
	                typeIdent+ {
                          IDENT
	                  genericTypeArgumentList? {
 	                    genericTypeArgument+ {
                              type // Previously defined
                            | QUESTION
                              genericWildcardBoundType? {
                                EXTENDS
                                type // Previously defined
                              | SUPER
                                type // Previously defined
                              }
                            }
                          }
                        }
                      }
	            arrayDeclaratorList? {
                      ARRAY_DECLARATOR* {
                        LBRACK RBRACK
                      }
                    }
                  }
                | LESS_OR_EQUAL expr expr
                | GREATER_OR_EQUAL expr expr
                | BIT_SHIFT_RIGHT expr expr
                | SHIFT_RIGHT expr expr
                | GREATER_THAN expr expr
                | SHIFT_LEFT expr expr
                | LESS_THAN expr expr
                | PLUS expr expr
                | MINUS expr expr
                | STAR expr expr
                | DIV expr expr
                | MOD expr expr
                | UNARY_PLUS expr
                | UNARY_MINUS expr
                | PRE_INC expr
                | PRE_DEC expr
                | POST_INC expr
                | POST_DEC expr
                | NOT expr
                | LOGICAL_NOT expr
                | CAST_EXPR
                  type // Previously defined
                  expr
                | primaryExpression {
                    DOT
                    ( primaryExpression // Recursive
                      ( IDENT
                        | THIS
                        | SUPER
                        | innerNewExpression {
                            CLASS_CONSTRUCTOR_CALL
                            genericTypeArgumentList? // Previously defined
                            IDENT
                            arguments {
                              expression* // Previously defined
                            }
                            classTopLevelScope? {
	                      classScopeDeclarations* {
                                CLASS_INSTANCE_INITIALIZER
                                block {
	                          blockStatement* {
                                    localVariableDeclaration {
                                      localModifierList {
                                        localModifier* {
                                            FINAL
                                        |   annotation // Previously defined
                                        }
                                      }
                                      type // Previously defined
                                      variableDeclaratorList {
	                                variableDeclarator+ {
	                                  variableDeclaratorId {
                                            IDENT
                                            arrayDeclaratorList? // Previously
                                          }
	                                  variableInitializer? {
                                            arrayInitializer {
	                                      variableInitializer* // Recursive
                                            }
                                          | expression // Previously declared
                                          }
                                        }
                                      }
                                    }
                                  | typeDeclaration {
                                    : CLASS
                                      modifierList {
                                        modifier* {
                                          PUBLIC
                                        | PROTECTED
                                        | PRIVATE
                                        | STATIC
                                        | ABSTRACT
                                        | NATIVE
                                        | SYNCHRONIZED
                                        | TRANSIENT
                                        | VOLATILE
                                        | STRICTFP
                                        | localModifier // Previously declared
                                        }
                                      }
                                      IDENT
                                      genericTypeParameterList? {
	                                genericTypeParameter+ {
                                          IDENT
	                                  bound? {
                                            type+ // Previously declared
                                          }
                                        }
                                      }
                                      extendsClause? {
                                        type+ // Previously defined
                                      }
                                      implementsClause? {
                                        type+ // Previously defined
                                      }
                                      classTopLevelScope // Previously defined
                                    | INTERFACE
                                      modifierList // Previously defined
                                      IDENT
                                      genericTypeParameterList? // Previously defined
                                      extendsClause? // Previously defined
                                      interfaceTopLevelScope {
      	                                interfaceScopeDeclarations* {
                                        : modifierList // Previously defined
                                          genericTypeParameterList? // Previously defined
                                          type // Previously defined
                                          IDENT
                                          formalParameterList {
					    formalParameterStandardDecl* {
					      localModifierList // Previously
					      type // Previously
					      variableDeclaratorId // Previously
                                            }
					    formalParameterVarargDecl? {
					      localModifierList // Previously
					      type // Previously
					      variableDeclaratorId // Previously
                                            }
                                          }
                                          arrayDeclaratorList? // Previously
                                          throwsClause? {
					    qualifiedIdentifier+ // Previously
                                          }
                                        | modifierList // Previously
                                          genericTypeParameterList? // Previously
                                          IDENT
                                          formalParameterList // Previously
                                          throwsClause? // Previously
                                        | VAR_DECLARATION
                                          modifierList // Previously
                                          type // Previously
                                          variableDeclaratorList // Previously
                                        | typeDeclaration
                                        }
                                      }
                                    | ENUM
                                      modifierList // Previously
                                      IDENT
                                      implementsClause? // Previously
                                      enumTopLevelScope {
				        enumConstant+ {
					  IDENT
					  annotationList // Previously
					  arguments? // Previously
					  classTopLevelScope? // Previously
				        }
				        classTopLevelScope? // Previously
                                      }
                                    | AT
                                      modifierList // Previously
                                      IDENT
                                      annotationTopLevelScope {
					annotationScopeDeclarations* {
				    	  modifierList // Previously
					  type // Previously
					  IDENT
					  annotationDefaultValue? {
					    DEFAULT
					    annotationElementValue
					  }
				        | modifierList // Previously
					  type // Previously
					  variableDeclaratorList // Previously
				        | typeDeclaration // Previously
					}
                                      }
                                    }
                                  | statement {
				    : block // Previously
				    | ASSERT
				      expression // Previously
				      expression?) // Previously
				    | IF
				      parenthesizedExpression
				      statement
				      statement?)
				    | FOR
				      forInit {
				        localVariableDeclaration
				      | expression*
				      }
				      forCondition {
	                                expression?
				      }
				      forUpdater {
				        expression*
				      }
				      statement
				    | FOR_EACH
				      localModifierList
				      type
				      IDENT
				      expression
				      statement
				    | WHILE
				      parenthesizedExpression
				      statement
				    | DO
				      statement
				      parenthesizedExpression)
				    | TRY
				      block
				      catches? {
	                                catchClause+ {
                                          CATCH
                                          formalParameterStandardDecl
                                          block
                                        }
				      }
				      block?
				    | SWITCH
				      parenthesizedExpression
				      switchBlockLabels {
					switchCaseLabel* {
				          CASE
					  expression
					  blockStatement*
					}
					switchDefaultLabel? {
					  DEFAULT
					  blockStatement*
					}
					switchCaseLabel*
				      }
				    | SYNCHRONIZED
				      parenthesizedExpression
				      block
				    | RETURN
				      expression?
				    | THROW
				      expression
				    | BREAK
				      IDENT?
				    | CONTINUE
				      IDENT?
				    | LABELED_STATEMENT
				      IDENT
				      statement
				    | expression
				    | SEMI
                                    }
                                  }
                                }
                              | CLASS_STATIC_INITIALIZER
                                block
                              | FUNCTION_METHOD_DECL
                                modifierList
                                genericTypeParameterList?
                                type
                                IDENT
                                formalParameterList
                                arrayDeclaratorList?
                                throwsClause?
                                block?
                              | VOID_METHOD_DECL
                                modifierList
                                genericTypeParameterList?
                                IDENT
                                formalParameterList
                                throwsClause?
                                block?
                              | VAR_DECLARATION
                                modifierList
                                type
                                variableDeclaratorList
                              | CONSTRUCTOR_DECL
                                modifierList
                                genericTypeParameterList?
                                formalParameterList
                                throwsClause?
                                block
                              | typeDeclaration
                              }
                            }
                          }
                        | CLASS
                        )
                      | primitiveType
                        CLASS
                      | VOID
                        CLASS
                      )
                    )
                  | parenthesizedExpression {
                      expression
                    }
                  | IDENT
                  | METHOD_CALL
                    primaryExpression
                    genericTypeArgumentList?
                    arguments
                  | explicitConstructorCall {
                      genericTypeArgumentList?
                      arguments
                    | primaryExpression?
                      genericTypeArgumentList?
                      arguments
                    }
                  | ARRAY_ELEMENT_ACCESS
                    primaryExpression
                    expression
                  | literal {
                      HEX_LITERAL
                    | OCTAL_LITERAL
                    | DECIMAL_LITERAL
                    | FLOATING_POINT_LITERAL
                    | CHARACTER_LITERAL
                    | STRING_LITERAL
                    | TRUE
                    | FALSE
                    | NULL
                    }
                  | newExpression {
                      primitiveType
                      newArrayConstruction {
                        arrayDeclaratorList
                  	arrayInitializer
                      | expression+
                   	arrayDeclaratorList?
                      }
                    | genericTypeArgumentList?
                      qualifiedTypeIdent
                      newArrayConstruction
                    | genericTypeArgumentList?
               	      qualifiedTypeIdent
                      arguments
                      classTopLevelScope?
                    }
                  | THIS
                  | arrayTypeDeclarator {
	              arrayTypeDeclarator
	            | qualifiedIdentifier
	            | primitiveType
                    }
                  | SUPER
                  }
                }
              }
            }
          }
        | ANNOTATION_INIT_DEFAULT_KEY
	  annotationElementValue
        }
      }
    }
  }
  packageDeclaration? {
    PACKAGE
    qualifiedIdentifier
  }
  importDeclaration* {
    IMPORT
    STATIC?
    qualifiedIdentifier
    DOTSTAR?
  }
  typeDeclaration* // Previously
}
}}}*/

/* {{{ javaSource {
  annotationList {
    annotation* {
      AT
      qualifiedIdentifier {
        IDENT
*/
@qualifiedIdentifier
/*
      | DOT
	qualifiedIdentifier // Recursive
	IDENT
*/
@qualifiedIdentifier.qualifiedIdentifierA
@qualifiedIdentifier.qualifiedIdentifierA.qualifiedIdentifierB
/*
      }
      annotationInit? {
	annotationInitializers {
	  annotationInitializer+ {
            IDENT
	    annotationElementValue {
              annotationElementValue* // Recursive
            | annotation // Previously defined
            | expression {
                expr {
                  ASSIGN expr expr
                | PLUS_ASSIGN expr expr
                | MINUS_ASSIGN expr expr
                | STAR_ASSIGN expr expr
                | DIV_ASSIGN expr expr
                | AND_ASSIGN expr expr
                | OR_ASSIGN expr expr
                | XOR_ASSIGN expr expr
                | MOD_ASSIGN expr expr
                | BIT_SHIFT_RIGHT_ASSIGN expr expr
                | SHIFT_RIGHT_ASSIGN expr expr
                | SHIFT_LEFT_ASSIGN expr expr
                | QUESTION expr expr expr
                | LOGICAL_OR expr expr
                | LOGICAL_AND expr expr
                | OR expr expr
                | XOR expr expr
                | AND expr expr
                | EQUAL expr expr
                | NOT_EQUAL expr expr
                | INSTANCEOF
                  expr
                  type {
	            ( primitiveType {
                        BOOLEAN
                      | CHAR
                      | BYTE
                      | SHORT
                      | INT
                      | LONG
                      | FLOAT
                      | DOUBLE
                      }
	            | qualifiedTypeIdent { )
	                typeIdent+ {
                          IDENT
	                  genericTypeArgumentList? {
 	                    genericTypeArgument+ {
                              type // Previously defined
                            | QUESTION
                              genericWildcardBoundType? {
                                EXTENDS
                                type // Previously defined
                              | SUPER
                                type // Previously defined
                              }
                            }
                          }
                        }
                      }
	            arrayDeclaratorList? {
                      ARRAY_DECLARATOR* {
                        LBRACK RBRACK
                      }
                    }
                  }
                | LESS_OR_EQUAL expr expr
                | GREATER_OR_EQUAL expr expr
                | BIT_SHIFT_RIGHT expr expr
                | SHIFT_RIGHT expr expr
                | GREATER_THAN expr expr
                | SHIFT_LEFT expr expr
                | LESS_THAN expr expr
                | PLUS expr expr
                | MINUS expr expr
                | STAR expr expr
                | DIV expr expr
                | MOD expr expr
                | UNARY_PLUS expr
                | UNARY_MINUS expr
                | PRE_INC expr
                | PRE_DEC expr
                | POST_INC expr
                | POST_DEC expr
                | NOT expr
                | LOGICAL_NOT expr
                | CAST_EXPR
                  type // Previously defined
                  expr
                | primaryExpression {
                    DOT
                    ( primaryExpression // Recursive
                      ( IDENT
                        | THIS
                        | SUPER
                        | innerNewExpression {
                            CLASS_CONSTRUCTOR_CALL
                            genericTypeArgumentList? // Previously defined
                            IDENT
                            arguments {
                              expression* // Previously defined
                            }
                            classTopLevelScope? {
	                      classScopeDeclarations* {
                                CLASS_INSTANCE_INITIALIZER
                                block {
	                          blockStatement* {
                                    localVariableDeclaration {
                                      localModifierList {
                                        localModifier* {
                                            FINAL
                                        |   annotation // Previously defined
                                        }
                                      }
                                      type // Previously defined
                                      variableDeclaratorList {
	                                variableDeclarator+ {
	                                  variableDeclaratorId {
                                            IDENT
                                            arrayDeclaratorList? // Previously
                                          }
	                                  variableInitializer? {
                                            arrayInitializer {
	                                      variableInitializer* // Recursive
                                            }
                                          | expression // Previously declared
                                          }
                                        }
                                      }
                                    }
                                  | typeDeclaration {
                                    : CLASS
                                      modifierList {
                                        modifier* {
                                          PUBLIC
                                        | PROTECTED
                                        | PRIVATE
                                        | STATIC
                                        | ABSTRACT
                                        | NATIVE
                                        | SYNCHRONIZED
                                        | TRANSIENT
                                        | VOLATILE
                                        | STRICTFP
                                        | localModifier // Previously declared
                                        }
                                      }
                                      IDENT
                                      genericTypeParameterList? {
	                                genericTypeParameter+ {
                                          IDENT
	                                  bound? {
                                            type+ // Previously declared
                                          }
                                        }
                                      }
                                      extendsClause? {
                                        type+ // Previously defined
                                      }
                                      implementsClause? {
                                        type+ // Previously defined
                                      }
                                      classTopLevelScope // Previously defined
                                    | INTERFACE
                                      modifierList // Previously defined
                                      IDENT
                                      genericTypeParameterList? // Previously defined
                                      extendsClause? // Previously defined
                                      interfaceTopLevelScope {
      	                                interfaceScopeDeclarations* {
                                        : modifierList // Previously defined
                                          genericTypeParameterList? // Previously defined
                                          type // Previously defined
                                          IDENT
                                          formalParameterList {
					    formalParameterStandardDecl* {
					      localModifierList // Previously
					      type // Previously
					      variableDeclaratorId // Previously
                                            }
					    formalParameterVarargDecl? {
					      localModifierList // Previously
					      type // Previously
					      variableDeclaratorId // Previously
                                            }
                                          }
                                          arrayDeclaratorList? // Previously
                                          throwsClause? {
					    qualifiedIdentifier+ // Previously
                                          }
                                        | modifierList // Previously
                                          genericTypeParameterList? // Previously
                                          IDENT
                                          formalParameterList // Previously
                                          throwsClause? // Previously
                                        | VAR_DECLARATION
                                          modifierList // Previously
                                          type // Previously
                                          variableDeclaratorList // Previously
                                        | typeDeclaration
                                        }
                                      }
                                    | ENUM
                                      modifierList // Previously
                                      IDENT
                                      implementsClause? // Previously
                                      enumTopLevelScope {
				        enumConstant+ {
					  IDENT
					  annotationList // Previously
					  arguments? // Previously
					  classTopLevelScope? // Previously
				        }
				        classTopLevelScope? // Previously
                                      }
                                    | AT
                                      modifierList // Previously
                                      IDENT
                                      annotationTopLevelScope {
					annotationScopeDeclarations* {
				    	  modifierList // Previously
					  type // Previously
					  IDENT
					  annotationDefaultValue? {
					    DEFAULT
					    annotationElementValue
					  }
				        | modifierList // Previously
					  type // Previously
					  variableDeclaratorList // Previously
				        | typeDeclaration // Previously
					}
                                      }
                                    }
                                  | statement {
				    : block // Previously
				    | ASSERT
				      expression // Previously
				      expression?) // Previously
				    | IF
				      parenthesizedExpression
				      statement
				      statement?)
				    | FOR
				      forInit {
				        localVariableDeclaration
				      | expression*
				      }
				      forCondition {
	                                expression?
				      }
				      forUpdater {
				        expression*
				      }
				      statement
				    | FOR_EACH
				      localModifierList
				      type
				      IDENT
				      expression
				      statement
				    | WHILE
				      parenthesizedExpression
				      statement
				    | DO
				      statement
				      parenthesizedExpression)
				    | TRY
				      block
				      catches? {
	                                catchClause+ {
                                          CATCH
                                          formalParameterStandardDecl
                                          block
                                        }
				      }
				      block?
				    | SWITCH
				      parenthesizedExpression
				      switchBlockLabels {
					switchCaseLabel* {
				          CASE
					  expression
					  blockStatement*
					}
					switchDefaultLabel? {
					  DEFAULT
					  blockStatement*
					}
					switchCaseLabel*
				      }
				    | SYNCHRONIZED
				      parenthesizedExpression
				      block
				    | RETURN
				      expression?
				    | THROW
				      expression
				    | BREAK
				      IDENT?
				    | CONTINUE
				      IDENT?
				    | LABELED_STATEMENT
				      IDENT
				      statement
				    | expression
				    | SEMI
                                    }
                                  }
                                }
                              | CLASS_STATIC_INITIALIZER
                                block
                              | FUNCTION_METHOD_DECL
                                modifierList
                                genericTypeParameterList?
                                type
                                IDENT
                                formalParameterList
                                arrayDeclaratorList?
                                throwsClause?
                                block?
                              | VOID_METHOD_DECL
                                modifierList
                                genericTypeParameterList?
                                IDENT
                                formalParameterList
                                throwsClause?
                                block?
                              | VAR_DECLARATION
                                modifierList
                                type
                                variableDeclaratorList
                              | CONSTRUCTOR_DECL
                                modifierList
                                genericTypeParameterList?
                                formalParameterList
                                throwsClause?
                                block
                              | typeDeclaration
                              }
                            }
                          }
                        | CLASS
                        )
                      | primitiveType
                        CLASS
                      | VOID
                        CLASS
                      )
                    )
                  | parenthesizedExpression {
                      expression
                    }
                  | IDENT
                  | METHOD_CALL
                    primaryExpression
                    genericTypeArgumentList?
                    arguments
                  | explicitConstructorCall {
                      genericTypeArgumentList?
                      arguments
                    | primaryExpression?
                      genericTypeArgumentList?
                      arguments
                    }
                  | ARRAY_ELEMENT_ACCESS
                    primaryExpression
                    expression
                  | literal {
                      HEX_LITERAL
                    | OCTAL_LITERAL
                    | DECIMAL_LITERAL
                    | FLOATING_POINT_LITERAL
                    | CHARACTER_LITERAL
                    | STRING_LITERAL
                    | TRUE
                    | FALSE
                    | NULL
                    }
                  | newExpression {
                      primitiveType
                      newArrayConstruction {
                        arrayDeclaratorList
                  	arrayInitializer
                      | expression+
                   	arrayDeclaratorList?
                      }
                    | genericTypeArgumentList?
                      qualifiedTypeIdent
                      newArrayConstruction
                    | genericTypeArgumentList?
               	      qualifiedTypeIdent
                      arguments
                      classTopLevelScope?
                    }
                  | THIS
                  | arrayTypeDeclarator {
	              arrayTypeDeclarator
	            | qualifiedIdentifier
	            | primitiveType
                    }
                  | SUPER
                  }
                }
              }
            }
          }
        | ANNOTATION_INIT_DEFAULT_KEY
	  annotationElementValue
        }
      }
    }
  }
  packageDeclaration? {
    PACKAGE
    qualifiedIdentifier
  }
  importDeclaration* {
    IMPORT
    STATIC?
    qualifiedIdentifier
    DOTSTAR?
  }
  typeDeclaration* // Previously
}
}}}*/
