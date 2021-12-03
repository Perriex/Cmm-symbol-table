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
    (
    (b = BEGIN
    (b1 = structBody // maybe??? with line
    {$structDeclarationRet.setBody($b1.structBodyRet);
    int line = $b.getLine();
    $b1.structBodyRet.setLine(line);}
    )
    )
     NEWLINE+ END)
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
    (f = functionArgsDec {$setGetVarDeclarationRet.setArgs($f.variableDeclarationRet.getVars());}) // here
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

//todo - done
functionDeclaration returns[FunctionDeclaration functionDeclarationRet]:
    {$functionDeclarationRet = new FunctionDeclaration();}
    (
    (t = type {$functionDeclarationRet.setReturnType($t.typeRet);})
    |
    VOID
    )
    (id = identifier
    {$functionDeclarationRet.setFunctionName($id.identifierRet);
    int line = $id.identifierRet.getLine();
    $functionDeclarationRet.setLine(line);
    })
    (f = functionArgsDec {$functionDeclarationRet.setArgs($f.variableDeclarationRet.getVars());}) //change to array
    (b = body {$functionDeclarationRet.setBody($b.bodyRet);})
    NEWLINE+;

//todo - not sure -> must change to array
functionArgsDec returns[VarDecStmt variableDeclarationRet]:
    {$variableDeclarationRet = new VarDecStmt();}
    LPAR (
    (t = type )
    (id = identifier )
    {VariableDeclaration arg1 = new VariableDeclaration($id.identifierRet,$t.typeRet);
    $variableDeclarationRet.addVar(arg1);}
    (COMMA
    (t = type )
    (id = identifier )
    {VariableDeclaration arg = new VariableDeclaration($id.identifierRet,$t.typeRet);
    $variableDeclarationRet.addVar(arg);}
    )*
    )? RPAR ;

//todo - ?? challenge AND return is not corrent -> array
functionArguments returns[ArrayList<Expression> functionArgumentsRet]:
    (expression (COMMA expression)*)?;

//todo - done
body returns[Statement bodyRet]:
     (
     (b = blockStatement {$bodyRet = $b.blockStatementRet;})
     |
     (NEWLINE+ (s = singleStatement {$bodyRet = $s.singleStatementRet;})
     (SEMICOLON)?));

//todo - done
loopCondBody returns[Statement loopCondBodyRet]:
     ((b = blockStatement {$loopCondBodyRet = $b.blockStatementRet;})
     |
     (NEWLINE+ (s = singleStatement {$loopCondBodyRet = $s.singleStatementRet;}) ));

//todo - done
blockStatement returns[BlockStmt blockStatementRet] :
    {$blockStatementRet = new BlockStmt();}
    (b = BEGIN
    {int line = $b.getLine();
    $blockStatementRet.setLine(line);} )
    (NEWLINE+
    ((s = singleStatement {$blockStatementRet.addStatement($s.singleStatementRet);}) SEMICOLON)*
    (s1 = singleStatement {$blockStatementRet.addStatement($s1.singleStatementRet);}) (SEMICOLON)?)+
    NEWLINE+ END;

//todo - done
varDecStatement returns[VarDecStmt varDecStatementRet]:
    {$varDecStatementRet = new VarDecStmt();}
    t = type id = identifier
    {VariableDeclaration var = new VariableDeclaration($id.identifierRet,$t.typeRet);
    int line = $id.identifierRet.getLine();
    $varDecStatementRet.setLine(line);}
    (ASSIGN e = orExpression )?
    {var.setDefaultValue($e.orExpressionRet);
    $varDecStatementRet.addVar(var);}
    (COMMA
    id2 = identifier  {VariableDeclaration var2 = new VariableDeclaration($id2.identifierRet,$t.typeRet);}
    (ASSIGN e2 = orExpression)?
    {var2.setDefaultValue($e2.orExpressionRet);
    $varDecStatementRet.addVar(var2);}
    )*;

//todo - just funtion that called?or this is wrong????- done
functionCallStmt returns [FunctionCallStmt functionCallStmtRet] :
    e = otherExpression {FunctionCall funcCall = new FunctionCall($e.otherExpressionRet);}
    (( LPAR  functionArguments RPAR) | (DOT identifier))* //??
    (l = LPAR fa = functionArguments
    {funcCall.setArgs($fa.functionArgumentsRet);
    int line =$l.getLine();
    funcCall.setLine(line);}
    RPAR)
    {$functionCallStmtRet = new FunctionCallStmt(funcCall);
    int line =$l.getLine();
    $functionCallStmtRet.setLine(line);};

//todo - done
returnStatement returns [ReturnStmt returnStatementRet]:
    r = RETURN
    {$returnStatementRet = new ReturnStmt();
     int line = $r.getLine();
     $returnStatementRet.setLine(line);}
    (e = expression {$returnStatementRet.setReturnedExpr($e.expressionRet);})?;

//todo
ifStatement returns [ConditionalStmt ifStatementRet]:
    i = IF e = expression
    {$ifStatementRet = new ConditionalStmt($e.expressionRet);
    int line = $i.getLine();
    $ifStatementRet.setLine(line);}
    (
    (l = loopCondBody
    {$ifStatementRet.setThenBody($l.loopCondBodyRet);})
    |
    ((b = body) (el = elseStatement)
    {$ifStatementRet.setThenBody($b.bodyRet);
    $ifStatementRet.setElseBody($el.elseStatementRet);})
    );

//todo
elseStatement returns [Statement elseStatementRet]:
     NEWLINE* ELSE l = loopCondBody {$elseStatementRet = $l.loopCondBodyRet; };

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
singleStatement returns [Statement singleStatementRet]:
    ifStatement | displayStatement | functionCallStmt | returnStatement | assignmentStatement
    | varDecStatement | loopStatement | append | size;

//todo
expression returns [Expression expressionRet]:
    orExpression (op = ASSIGN expression )? ;

//todo
orExpression returns [Expression orExpressionRet]:
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
otherExpression returns[Expression otherExpressionRet]:
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