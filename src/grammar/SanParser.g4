parser grammar SanParser;

options {
	tokenVocab = SanLexer;
}

instructions: statement* eos;

body: '{' statement* '}';

statement:
	function
	| namespaceStatement
	| expression InstructionsSeparator
	| body
	| variableDeclaration InstructionsSeparator
	| returnStatement InstructionsSeparator
	| ifStatement
	| whileStatement
	| forStatement
	| breakStatement InstructionsSeparator
	| specialClassStatement
	| classStatement
	| importStatement
	| alias InstructionsSeparator;

expression:
	'(' expression ')'										# InParenExpression
	| 'sizeof' (expression | type)							# SizeofExpression
	| classTypeName '{' classInstantiationProperties? '}'	# ClassInstantiationExpression
	| expression '.' name									# PropertyExpression
	| expression '(' functionCallArguments? ')'				# FunctionCallExpression
	| expression '[' expression ']'							# Index
	| expression multiplicativeOperatorStatement expression	# BinaryMultiplicativeOperation
	| expression operatorStatement expression				# BinaryOperation
	| expression bitwiseOperatorStatement expression		# BinaryBitwiseOperation
	| expression comparisonOperatorStatement expression		# BinaryComparisonOperation
	| expression conditionalOperatorStatement expression	# BinaryConditionalOperation
	| expression equalityOperatorStatement expression		# EqualityOperation
	| expression 'as' type									# TypeCast
	| 'this'												# ThisExpression
	| scopedName											# NameExpression
	| literal												# LiteralDeclaration;

scopedName: scopeResolver? name;

name: VariableName classTypeNameGenerics?;

scopedNameNoGeneric: scopeResolver? nameNoGeneric;

nameNoGeneric: VariableName;

scopeResolver: name '::' scopeResolver?;

multiplicativeOperatorStatement: Mul | Div | Mod;

operatorStatement: Add | Sub;

bitwiseOperatorStatement: Xor | BitwiseOr | BitwiseAnd;

conditionalOperatorStatement: ConditionalOr | ConditionalAnd;

comparisonOperatorStatement:
	EqualTo
	| NotEqualTo
	| LessThanOrEqualTo
	| GreaterThanOrEqualTo
	| LessThan
	| GreaterThan;

equalityOperatorStatement: Equal;

literal:
	booleanLiteral
	| integerLiteral
	| floatingLiteral
	| StringLiteral
	| CharLiteral;

booleanLiteral: True | False;

integerLiteral:
	Sub? (
		DecimalLiteral
		| ZeroLiteral
		| HexadecimalLiteral
		| BinaryLiteral
	);

floatingLiteral: Sub? FloatingLiteral;

variableDeclaration:
	VariableDeclarator VariableName (
		':' type ('=' expression)?
		| '=' expression
	);

functionCallArguments:
	functionCallArgument (',' functionCallArgument)*;

functionCallArgument: expression;

overloadableOperator:
	'+'
	| '-'
	| '*'
	| '/'
	| '%'
	| '^'
	| '|'
	| '&'
	| '=='
	| '!='
	| '<'
	| '<='
	| '>'
	| '>=';

function:
	attributes Extern? functionDeclaration (
		body
		| InstructionsSeparator
	);

functionDeclaration:
	Function (
		(
			((Operator overloadableOperator) | VariableName) classGenerics? '(' (
				functionArguments (',' functionVariadicArgument)?
				| functionVariadicArgument?
			) ')' (':' type)?
		)
		| (Destructor '(' ')')
	);

functionVariadicArgument: '...';

functionArguments: functionArgument (',' functionArgument)*;

functionArgument: (VariableName ':')? type;

returnStatement: 'return' expression?;

ifStatement:
	'if' (expression | variableDeclaration) statement elseStatement?;

elseStatement: 'else' statement;

whileStatement: 'while' expression statement;

forStatement: 'for' VariableName 'in' expression statement;

breakStatement: 'break';

specialClassStatement:
	attributes Special 'class' scopedNameNoGeneric classTypeNameGenerics (
		Extends classExtends
	)? classBody;

classStatement:
	attributes 'class' VariableName classGenerics? (
		Extends classExtends
	)? classBody;

classGenerics: '<' VariableName (',' VariableName)* '>';

classExtends: classTypeName (',' classTypeName)*;

classBody: '{' (classProperty | classMethod)* '}';

classProperty:
	Static? VariableName ':' type ('=' expression)? InstructionsSeparator;

classMethod: Static? function;

classInstantiationProperties:
	classInstantiationProperty (',' classInstantiationProperty)* ','?;

classInstantiationProperty: VariableName ('=' expression)?;

type:
	typeQualifier* typeName typeDimensions* typePointer* typeReference?;

typeQualifier: Const;

typeDimensions: '[' expression ']';

typePointer: '*';

typeReference: '&';

typeName: scopedName | functionType;

functionType: 'fn' '(' functionArguments? ')' (':' type)?;

classTypeName: scopedName;

classTypeNameGenerics: '<' type (',' type)* '>';

namespaceStatement:
	attributes Namespace VariableName '{' statement* '}';

importStatement: Import StringLiteral;

attributes: attribute*;
attribute: '#[' VariableName '=' StringLiteral ']';

alias: 'alias' VariableName classGenerics? '=' scopedName;

eos: (EOF | LineTerminator);
