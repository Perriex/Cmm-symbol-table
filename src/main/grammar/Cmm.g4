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
    (f = functionArgsDec {$setGetVarDeclarationRet.setArgs($f.variableDeclarationRet);})
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
    (f = functionArgsDec {$functionDeclarationRet.setArgs($f.variableDeclarationRet);}) //change to array
    (b = body {$functionDeclarationRet.setBody($b.bodyRet);})
    NEWLINE+;

//todo - done
functionArgsDec returns[ArrayList<VariableDeclaration> variableDeclarationRet]:
    {$variableDeclarationRet = new ArrayList<VariableDeclaration>();}
    LPAR (
    (t = type )
    (id = identifier )
    {VariableDeclaration arg1 = new VariableDeclaration($id.identifierRet,$t.typeRet);
    $variableDeclarationRet.add(arg1);}
    (COMMA
    (t = type )
    (id = identifier )
    {VariableDeclaration arg = new VariableDeclaration($id.identifierRet,$t.typeRet);
    $variableDeclarationRet.add(arg);}
    )*
    )? RPAR ;

//todo - done
functionArguments returns[ArrayList<Expression> functionArgumentsRet]:
    {$functionArgumentsRet = new ArrayList<Expression>();}
    (e = expression {$functionArgumentsRet.add($e.expressionRet);}(COMMA ep = expression {$functionArgumentsRet.add($ep.expressionRet);})*)?;

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

//todo ?
functionCallStmt returns [FunctionCallStmt functionCallStmtRet] :
    e = otherExpression (( LPAR  functionArguments RPAR) | (DOT identifier))* (l = LPAR fa = functionArguments RPAR);

//todo - done
returnStatement returns [ReturnStmt returnStatementRet]:
    r = RETURN
    {$returnStatementRet = new ReturnStmt();
     int line = $r.getLine();
     $returnStatementRet.setLine(line);}
    (e = expression {$returnStatementRet.setReturnedExpr($e.expressionRet);})?;

//todo - done
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

//todo - done
elseStatement returns [Statement elseStatementRet]:
     NEWLINE* ELSE l = loopCondBody {$elseStatementRet = $l.loopCondBodyRet; };

//todo - done
loopStatement returns [LoopStmt loopStatementRet]:
    w = whileLoopStatement {$loopStatementRet = $w.whileLoopStatementRet; }
    |
    d = doWhileLoopStatement{$loopStatementRet = $d.doWhileLoopStatementRet;};

//todo - done
whileLoopStatement returns [LoopStmt whileLoopStatementRet] :
   ( w = WHILE)
   {$whileLoopStatementRet = new LoopStmt();
   int line = $w.getLine();
   $whileLoopStatementRet.setLine(line);
   }
   (e = expression) {$whileLoopStatementRet.setCondition($e.expressionRet);}
   (l = loopCondBody) {$whileLoopStatementRet.setBody($l.loopCondBodyRet);};

//todo - done
doWhileLoopStatement  returns [LoopStmt doWhileLoopStatementRet] :
    (d = DO)
    {$doWhileLoopStatementRet = new LoopStmt();
    int line = $d.getLine();
    $doWhileLoopStatementRet.setLine(line);
    }
    (b = body) {$doWhileLoopStatementRet.setBody($b.bodyRet);}
    NEWLINE* WHILE
    (e = expression) {$doWhileLoopStatementRet.setCondition($e.expressionRet);};

//todo - done
displayStatement returns [DisplayStmt displayStatementRet]:
    (d = DISPLAY)
    LPAR
    (e = expression)
    {$displayStatementRet = new DisplayStmt($e.expressionRet);
    int line = $d.getLine();
    $displayStatementRet.setLine(line);}
    RPAR;

//todo - done
assignmentStatement returns [AssignmentStmt assignmentStatementRet]:
    (e1 = orExpression)
    (a = ASSIGN)
    (e2 = expression)
    {$assignmentStatementRet = new AssignmentStmt($e1.orExpressionRet, $e2.expressionRet);
    int line = $a.getLine();
    $assignmentStatementRet.setLine(line);};

//todo - done
singleStatement returns [Statement singleStatementRet]:
    e1 = ifStatement {$singleStatementRet = $e1.ifStatementRet;}|
    e2 = displayStatement {$singleStatementRet = $e2.displayStatementRet;}|
    e3 = functionCallStmt {$singleStatementRet = $e3.functionCallStmtRet;}|
    e4 = returnStatement {$singleStatementRet = $e4.returnStatementRet;}|
    e5 = assignmentStatement {$singleStatementRet = $e5.assignmentStatementRet;}|
    e6 = varDecStatement {$singleStatementRet = $e6.varDecStatementRet;}|
    e7 = loopStatement {$singleStatementRet = $e7.loopStatementRet;} |
    e8 = append {$singleStatementRet = new ListAppendStmt($e8.appendRet);
                 $singleStatementRet.setLine($e8.appendRet.getLine());}|
    e9 = size {$singleStatementRet = new ListSizeStmt($e9.sizeRet);
                $singleStatementRet.setLine($e9.sizeRet.getLine());};

//todo - done ?
expression returns [Expression expressionRet]:
    oe = orExpression
    {$expressionRet = $oe.orExpressionRet; }
    (op = ASSIGN e2 = expression
    {$expressionRet = new BinaryExpression($oe.orExpressionRet,$e2.expressionRet,BinaryOperator.assign);
    int line = $op.getLine();
    $expressionRet.setLine(line);})? ;

//todo - done?
orExpression returns [Expression orExpressionRet]:
    ae = andExpression
    {$orExpressionRet = $ae.andExpressionRet;}
    (op = OR ae = andExpression {$orExpressionRet = new BinaryExpression($orExpressionRet, $ae.andExpressionRet, BinaryOperator.or);})*;

//todo - done?
andExpression returns [Expression andExpressionRet]:
    ee = equalityExpression
    {$andExpressionRet = $ee.equalityExpressionRet;}
    (op = AND ee = equalityExpression {$andExpressionRet = new BinaryExpression($andExpressionRet, $ee.equalityExpressionRet, BinaryOperator.and);})*;

//todo - done?
equalityExpression returns [Expression equalityExpressionRet]:
    re = relationalExpression
    {$equalityExpressionRet = $re.relationalExpressionRet;}
    (op = EQUAL re = relationalExpression {$equalityExpressionRet = new BinaryExpression($equalityExpressionRet, $re.relationalExpressionRet, BinaryOperator.eq);})*;

//todo - done?
relationalExpression returns [Expression relationalExpressionRet]:
    ae = additiveExpression
    {$relationalExpressionRet = $ae.additiveExpressionRet;}
    ((op = GREATER_THAN | op = LESS_THAN) ae = additiveExpression {$relationalExpressionRet = new BinaryExpression($relationalExpressionRet, $ae.additiveExpressionRet, $op.text == "<" ? BinaryOperator.lt : BinaryOperator.gt);})*;

//todo - done?
additiveExpression returns [Expression additiveExpressionRet]:
    me = multiplicativeExpression
    {$additiveExpressionRet = $me.multiplicativeExpressionRet;}
    ((op = PLUS | op = MINUS) me = multiplicativeExpression {$additiveExpressionRet = new BinaryExpression($additiveExpressionRet, $me.multiplicativeExpressionRet, $op.text == "+" ? BinaryOperator.add : BinaryOperator.sub);})*;

//todo - done?
multiplicativeExpression returns [Expression multiplicativeExpressionRet]:
    pu = preUnaryExpression
    {$multiplicativeExpressionRet = $pu.preUnaryExpressionRet;}
    ((op = MULT | op = DIVIDE) pu = preUnaryExpression {$multiplicativeExpressionRet = new BinaryExpression($multiplicativeExpressionRet, $pu.preUnaryExpressionRet, $op.text == "*" ? BinaryOperator.mult : BinaryOperator.div);})*;

//todo - done?
preUnaryExpression returns [Expression preUnaryExpressionRet]:
    ((op = NOT | op = MINUS) pe = preUnaryExpression )
    {$preUnaryExpressionRet = new UnaryExpression($pe.preUnaryExpressionRet, $op.text == "-" ? UnaryOperator.minus : UnaryOperator.not);}
    | ae = accessExpression {$preUnaryExpressionRet = $ae.accessExpressionRet;};

//todo ?
accessExpression returns [Expression accessExpressionRet]:
    otherExpression ((LPAR functionArguments RPAR) | (DOT identifier))*  ((LBRACK expression RBRACK) | (DOT identifier))*;

//todo - done
otherExpression returns[Expression otherExpressionRet]:
    e1 = value {$otherExpressionRet = $e1.valueRet;}|
    e2 = identifier {$otherExpressionRet = $e2.identifierRet;}|
    LPAR (e3 = functionArguments) {$otherExpressionRet = new ExprInPar($e3.functionArgumentsRet);} RPAR  |
    e4 = size  {$otherExpressionRet = $e4.sizeRet;}|
    e5 = append  {$otherExpressionRet = $e5.appendRet;} ;

//todo - done
size returns [ListSize sizeRet]:
    s = SIZE LPAR (e = expression)
    {$sizeRet = new  ListSize($e.expressionRet);
    int line = $s.getLine();
    $sizeRet.setLine(line);
    }
    RPAR;

//todo - done
append returns [ListAppend appendRet]:
    a = APPEND LPAR e1 = expression COMMA e2 = expression
    {$appendRet = new ListAppend($e1.expressionRet, $e2.expressionRet);
    int line = $a.getLine();
    $appendRet.setLine(line);
    }
    RPAR;

//todo - done
value returns [Value valueRet]:
    b = boolValue {$valueRet = $b.boolValueRet;}|
    i = INT_VALUE
    {$valueRet = new IntValue(Integer.parseInt($i.text));
    int line = $i.getLine();
    $valueRet.setLine(line);};

//todo - done
boolValue returns [BoolValue boolValueRet]:
    t = TRUE
    {$boolValueRet = new BoolValue(true);
    int line = $t.getLine();
    $boolValueRet.setLine(line);}|
    f = FALSE
    {$boolValueRet = new BoolValue(false);
    int line = $f.getLine();
    $boolValueRet.setLine(line);};

//todo - done
identifier returns[Identifier identifierRet]:
    (i = IDENTIFIER
    {$identifierRet = new Identifier($i.text);
     int line = $i.getLine();
     $identifierRet.setLine(line);
    });

//todo - done
type returns[Type typeRet]:
    INT {$typeRet = new IntType();} | BOOL {$typeRet = new BoolType();}|
    LIST SHARP t = type {$typeRet = new ListType($t.typeRet);} |
    STRUCT id = identifier {$typeRet = new StructType($id.identifierRet);}|
    f = fptrType {$typeRet = $f.fptrTypeRet;};

//todo - done
fptrType returns [FptrType fptrTypeRet]:
    FPTR LESS_THAN (t = VOID
    {$fptrTypeRet = new FptrType(new ArrayList<Type>(),new VoidType());
     $fptrTypeRet.addArgType(new VoidType());}
    |
    ( (e = type)
    {$fptrTypeRet = new FptrType(new ArrayList<Type>(),new VoidType());
     $fptrTypeRet.addArgType($e.typeRet);}
    (COMMA t2 = type { $fptrTypeRet.addArgType($t2.typeRet);})*)) ARROW ( t3 = type { $fptrTypeRet.setReturnType($t3.typeRet);} | VOID)
    {}
    GREATER_THAN;

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