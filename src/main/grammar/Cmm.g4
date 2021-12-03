grammar Cmm;

@header{
     import main.ast.nodes.*;
     import main.ast.nodes.declaration.*;
     import main.ast.nodes.declaration.struct.*;
     import main.ast.nodes.expression.*;
     import main.ast.nodes.expression.operators.*;
     import main.ast.nodes.expression.values.*;
     import main.ast.nodes.expression.values.primitive.*;
     import main.ast.nodes.statement.*;
     import main.ast.types.*;
     import main.ast.types.primitives.*;
     import java.util.*;
 }

cmm returns[Program cmmProgram]:
    NEWLINE* p = program {$cmmProgram = $p.programRet;} NEWLINE* EOF;

program returns[Program programRet]:
    {$programRet = new Program();
     int line = 1;
     $programRet.setLine(line);}
    (s = structDeclaration {$programRet.addStruct($s.structDeclarationRet);})*
    (f = functionDeclaration {$programRet.addFunction($f.functionDeclarationRet);})*
    m = main {$programRet.setMain($m.mainRet);};

//todo - done!
main returns[MainDeclaration mainRet]:
    (m = MAIN
    {$mainRet = new MainDeclaration();
     int line = $m.getLine();
     $mainRet.setLine(line);})
    LPAR RPAR (b = body {$mainRet.setBody($b.bodyRet);});

//todo - done!
structDeclaration returns[StructDeclaration structDeclarationRet]:
    (s = STRUCT
    {$structDeclarationRet = new StructDeclaration();
     int line = $s.getLine();
     $structDeclarationRet.setLine(line);})
    (id = identifier {$structDeclarationRet.setStructName($id.identifierRet);})
    (
    (BEGIN (b1 = structBody {$structDeclarationRet.setBody($b1.structBodyRet);}) NEWLINE+ END)
    |
    (NEWLINE+ (b2 = singleStatementStructBody {$structDeclarationRet.setBody($b2.singleStatementStructBodyRet);}) SEMICOLON?)
    ) NEWLINE+;

//todo - done!
singleVarWithGetAndSet returns[SetGetVarDeclaration setGetVarDeclarationRet]:
    (t = type
    {$setGetVarDeclarationRet = new SetGetVarDeclaration();
     $setGetVarDeclarationRet.setVarType($t.typeRet);})
    (id = identifier
    {$setGetVarDeclarationRet.setVarName($id.identifierRet);
     int line = $id.identifierRet.getLine();
     $setGetVarDeclarationRet.setLine(line);})
    (f = functionArgsDec {$setGetVarDeclarationRet.addArg($f.variableDeclarationRet);})
    BEGIN NEWLINE+
    (s = setBody {$setGetVarDeclarationRet.setSetterBody($s.setBodyRet);})
    (g = getBody {$setGetVarDeclarationRet.setGetterBody($g.getBodyRet);}) END;

//todo - done
singleStatementStructBody returns[Statement singleStatementStructBodyRet]:
    (v = varDecStatement
    {$singleStatementStructBodyRet = $v.varDecStatementRet;})
    |
    (s = singleVarWithGetAndSet
    {$singleStatementStructBodyRet = $s.setGetVarDeclarationRet;});

//todo - done
structBody returns[BlockStmt structBodyRet]:
    {$structBodyRet = new BlockStmt();}
    (NEWLINE+
    (
    (s = singleStatementStructBody {$structBodyRet.addStatement($s.singleStatementStructBodyRet);})
    SEMICOLON
    )*
    (si = singleStatementStructBody {$structBodyRet.addStatement($si.singleStatementStructBodyRet);})
    SEMICOLON?)+;

//todo - done
getBody returns[Statement getBodyRet]:
    GET (b = body {$getBodyRet = $b.bodyRet;}) NEWLINE+;

//todo - done
setBody returns[Statement setBodyRet]:
    SET (b = body {$setBodyRet = $b.bodyRet;}) NEWLINE+;

//todo
functionDeclaration returns[FunctionDeclaration functionDeclarationRet]:
    (type | VOID ) identifier functionArgsDec body NEWLINE+;

//todo
functionArgsDec returns[VariableDeclaration variableDeclarationRet]:
    LPAR (type identifier (COMMA type identifier)*)? RPAR ;

//todo
functionArguments :
    (expression (COMMA expression)*)?;

//todo
body returns[Statement bodyRet]:
     (blockStatement | (NEWLINE+ singleStatement (SEMICOLON)?));

//todo
loopCondBody :
     (blockStatement | (NEWLINE+ singleStatement ));

//todo
blockStatement :
    BEGIN (NEWLINE+ (singleStatement SEMICOLON)* singleStatement (SEMICOLON)?)+ NEWLINE+ END;

//todo
varDecStatement returns[VarDecStmt varDecStatementRet]:
    type identifier (ASSIGN orExpression )? (COMMA identifier (ASSIGN orExpression)? )*;

//todo
functionCallStmt :
     otherExpression ((LPAR functionArguments RPAR) | (DOT identifier))* (LPAR functionArguments RPAR);

//todo
returnStatement :
    RETURN (expression)?;

//todo
ifStatement :
    IF expression (loopCondBody | body elseStatement);

//todo
elseStatement :
     NEWLINE* ELSE loopCondBody;

//todo
loopStatement :
    whileLoopStatement | doWhileLoopStatement;

//todo
whileLoopStatement :
    WHILE expression loopCondBody;

//todo
doWhileLoopStatement :
    DO body NEWLINE* WHILE expression;

//todo
displayStatement :
  DISPLAY LPAR expression RPAR;

//todo
assignmentStatement :
    orExpression ASSIGN expression;

//todo
singleStatement :
    ifStatement | displayStatement | functionCallStmt | returnStatement | assignmentStatement
    | varDecStatement | loopStatement | append | size;

//todo
expression:
    orExpression (op = ASSIGN expression )? ;

//todo
orExpression:
    andExpression (op = OR andExpression )*;

//todo
andExpression:
    equalityExpression (op = AND equalityExpression )*;

//todo
equalityExpression:
    relationalExpression (op = EQUAL relationalExpression )*;

//todo
relationalExpression:
    additiveExpression ((op = GREATER_THAN | op = LESS_THAN) additiveExpression )*;

//todo
additiveExpression:
    multiplicativeExpression ((op = PLUS | op = MINUS) multiplicativeExpression )*;

//todo
multiplicativeExpression:
    preUnaryExpression ((op = MULT | op = DIVIDE) preUnaryExpression )*;

//todo
preUnaryExpression:
    ((op = NOT | op = MINUS) preUnaryExpression ) | accessExpression;

//todo
accessExpression:
    otherExpression ((LPAR functionArguments RPAR) | (DOT identifier))*  ((LBRACK expression RBRACK) | (DOT identifier))*;

//todo
otherExpression:
    value | identifier | LPAR (functionArguments) RPAR | size | append ;

//todo
size :
    SIZE LPAR expression RPAR;

//todo
append :
    APPEND LPAR expression COMMA expression RPAR;

//todo
value :
    boolValue | INT_VALUE;

//todo
boolValue:
    TRUE | FALSE;

//todo - done!
identifier returns[Identifier identifierRet]:
    (i = IDENTIFIER
    {$identifierRet = new Identifier($i.text);
     int line = $i.getLine();
     $identifierRet.setLine(line);
    });

//todo
type returns[Type typeRet]:
    INT | BOOL | LIST SHARP type | STRUCT identifier | fptrType;

//todo
fptrType:
    FPTR LESS_THAN (VOID | (type (COMMA type)*)) ARROW (type | VOID) GREATER_THAN;

MAIN: 'main';
RETURN: 'return';
VOID: 'void';

SIZE: 'size';
DISPLAY: 'display';
APPEND: 'append';

IF: 'if';
ELSE: 'else';

PLUS: '+';
MINUS: '-';
MULT: '*';
DIVIDE: '/';


EQUAL: '==';
ARROW: '->';
GREATER_THAN: '>';
LESS_THAN: '<';


AND: '&';
OR: '|';
NOT: '~';

TRUE: 'true';
FALSE: 'false';

BEGIN: 'begin';
END: 'end';

INT: 'int';
BOOL: 'bool';
LIST: 'list';
STRUCT: 'struct';
FPTR: 'fptr';
GET: 'get';
SET: 'set';
WHILE: 'while';
DO: 'do';

ASSIGN: '=';
SHARP: '#';
LPAR: '(';
RPAR: ')';
LBRACK: '[';
RBRACK: ']';

COMMA: ',';
DOT: '.';
SEMICOLON: ';';
NEWLINE: '\n';

INT_VALUE: '0' | [1-9][0-9]*;
IDENTIFIER: [a-zA-Z_][A-Za-z0-9_]*;


COMMENT: ('/*' .*? '*/') -> skip;
WS: ([ \t\r]) -> skip;