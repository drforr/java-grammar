/* ---
annotation:
  AT: 1
  annotationInit: 1
  qualifiedIdentifier: 1
annotationDefaultValue:
  annotationElementValue: 1
annotationElementValue:
  aAnnotationElementValue: 1
  annotation: 1
  expression: 1
annotationInit:
  annotationInitializers: 1
annotationInitializer:
  IDENT: 1
  annotationElementValue: 1
annotationInitializers:
  annotationElementValue: 1
  annotationInitializer: 1
annotationList:
  annotation: 1
annotationScopeDeclarations:
  IDENT: 1
  annotationDefaultValue: 1
  modifierList: 1
  type: 1
  typeDeclaration: 1
  variableDeclaratorList: 1
annotationTopLevelScope:
  annotationScopeDeclarations: 1
arguments:
  expression: 1
arrayDeclarator:
  LBRACK: 1
  RBRACK: 1
arrayDeclaratorList:
  arrayDeclarator: 1
arrayInitializer:
  variableInitializer: 1
arrayTypeDeclarator:
  aArrayTypeDeclarator: 1
  primitiveType: 1
  qualifiedIdentifier: 1
block:
  blockStatement: 1
blockStatement:
  localVariableDeclaration: 1
  statement: 1
  typeDeclaration: 1
bound:
  type: 1
catchClause:
  CATCH: 1
  block: 1
  formalParameterStandardDecl: 1
catches:
  catchClause: 1
classScopeDeclarations:
  IDENT: 1
  arrayDeclaratorList: 1
  block: 1
  formalParameterList: 1
  genericTypeParameterList: 1
  modifierList: 1
  throwsClause: 1
  type: 1
  typeDeclaration: 1
  variableDeclaratorList: 1
enumConstant:
  IDENT: 1
  annotationList: 1
  arguments: 1
  classTopLevelScope: 1
enumTopLevelScope:
  classTopLevelScope: 1
  enumConstant: 1
explicitConstructorCall:
  arguments: 1
  genericTypeArgumentList: 1
  primaryExpression: 1
expression:
  expr: 1
extendsClause:
  type: 1
forCondition:
  expression: 1
forInit:
  expression: 1
  localVariableDeclaration: 1
forUpdater:
  expression: 1
formalParameterList:
  formalParameterStandardDecl: 1
  formalParameterVarargDecl: 1
formalParameterStandardDecl:
  localModifierList: 1
  type: 1
  variableDeclaratorId: 1
formalParameterVarargDecl:
  localModifierList: 1
  type: 1
  variableDeclaratorId: 1
genericTypeArgument:
  QUESTION: 1
  genericWildcardBoundType: 1
  type: 1
genericTypeArgumentList:
  genericTypeArgument: 1
genericTypeParameter:
  IDENT: 1
  bound: 1
genericTypeParameterList:
  genericTypeParameter: 1
genericWildcardBoundType:
  EXTENDS: 1
  SUPER: 1
  type: 1
implementsClause:
  type: 1
importDeclaration:
  DOTSTAR: 1
  IMPORT: 1
  STATIC: 1
  qualifiedIdentifier: 1
innerNewExpression:
  IDENT: 1
  arguments: 1
  classTopLevelScope: 1
  genericTypeArgumentList: 1
interfaceScopeDeclarations:
  IDENT: 1
  arrayDeclaratorList: 1
  formalParameterList: 1
  genericTypeParameterList: 1
  modifierList: 1
  throwsClause: 1
  type: 1
  typeDeclaration: 1
  variableDeclaratorList: 1
interfaceTopLevelScope:
  interfaceScopeDeclarations: 1
javaSource:
  annotationList: 1
  importDeclaration: 1
  packageDeclaration: 1
  typeDeclaration: 1
literal:
  CHARACTER_LITERAL: 1
  DECIMAL_LITERAL: 1
  FALSE: 1
  FLOATING_POINT_LITERAL: 1
  HEX_LITERAL: 1
  NULL: 1
  OCTAL_LITERAL: 1
  STRING_LITERAL: 1
  TRUE: 1
localModifier:
  annotation: 1
localModifierList:
  localModifier: 1
localVariableDeclaration:
  localModifierList: 1
  type: 1
  variableDeclaratorList: 1
modifier:
  localModifier: 1
modifierList:
  modifier: 1
newArrayConstruction:
  arrayDeclaratorList: 1
  arrayInitializer: 1
  expression: 1
newExpression:
  aNewArrayConstruction: 1
  arguemnts: 1
  bNewArrayConstruction: 1
  classTopLevelScope: 1
  genericTypeArgumentList: 1
  primitiveType: 1
  qualifiedTypeIdent: 1
packageDeclaration:
  PACKAGE: 1
  qualifiedIdentifier: 1
parenthesizedExpression:
  expression: 1
primaryExpression:
  DOT: 1
  IDENT: 1
  SUPER: 1
  THIS: 1
  VOID: 1
  aPrimaryExpression: 1
  arguments: 1
  arrayTypeDeclarator: 1
  bCLASS: 1
  cCLASS: 1
  dCLASS: 1
  ePrimaryExpression: 1
  explicitConstructorCall: 1
  expression: 1
  fPrimaryExpression: 1
  genericTypeArgumentList: 1
  innerNewExpression: 1
  literal: 1
  newExpression: 1
  parenthesizedExpression: 1
  primitiveType: 1
primitiveType:
qualifiedIdentifier:
  DOT: 1
  IDENT: 1
  aQualifiedIdentifier: 1
qualifiedTypeIdent:
  typeIdent: 1
statement:
  ASSERT: 1
  BREAK: 1
  CONTINUE: 1
  DO: 1
  FOR: 1
  FOR_EACH: 1
  IF: 1
  LABELED_STATEMENT: 1
  RETURN: 1
  SEMI: 1
  SWITCH: 1
  SYNCHRONIZED: 1
  THROW: 1
  TRY: 1
  WHILE: 1
  block: 1
  expression: 1
switchBlockLabels:
  SwitchDefaultLabel: 1
  aSwitchCaseLabel: 1
  bSwitchCaseLabel: 1
switchCaseLabel:
  CASE: 1
  blockStatement: 1
  expression: 1
switchDefaultLabel:
  blockStatement: 1
throwsClause:
  qualifiedIdentifier: 1
type:
  arrayDeclaratorList: 1
  primitiveType: 1
  qualifiedTypeIdent: 1
typeDeclaration:
  AT: 1
  ENUM: 1
  IDENT: 1
  INTERFACE: 1
  annotationTopLevelScope: 1
  classTopLevelScope: 1
  enumTopLevelScope: 1
  extendsClause: 1
  genericTpeParameterList: 1
  genericTypeParameterList: 1
  implementsClause: 1
  interfaceTopLevelScope: 1
  modifierList: 1
typeIdent:
  IDENT: 1
  genericTypeArgumentList: 1
variableDeclarator:
  variableDeclaratorId: 1
  variableInitializer: 1
variableDeclaratorId:
  arrayDeclaratorList: 1
variableDeclaratorList:
  variableDeclarator: 1
variableInitializer:
  arrayInitializer: 1
  expression: 1
*/
class ChristmasTree {
  public int i; // classTopLevelScope
                // modifier.PUBLIC
                // primitiveType.INT
		// variableDeclaratorId.IDENT
  private int j;	// modifier.PRIVATE
  protected float k;	// modifier.PROTECTED
			// primitiveType.FLOAT
  static char l;	// modifier.STATIC
			// primitiveType.CHAR
  synchronized long m;	// modifier.SYNCHRONIZED
			// primitiveType.LONG
  transient short n;	// modifier.TRANSIENT
			// primitiveType.SHORT
  abstract boolean o;	// modifier.ABSTRACT
			// primitiveType.BOOLEAN
  native byte p;	// modifier.NATIVE
			// primitiveType.BYTE
  strictfp double q;	// modifier.STRICTFT
			// primitiveType.DOUBLE
  volatile double r;	// modifier.VOLATILE
			// primitiveType.DOUBLE
  static final int s;	// localModifier.FINAL
}
