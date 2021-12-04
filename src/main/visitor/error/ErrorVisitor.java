package main.visitor.error;

import main.ast.nodes.Program;
import main.ast.nodes.declaration.FunctionDeclaration;
import main.ast.nodes.declaration.MainDeclaration;
import main.ast.nodes.declaration.VariableDeclaration;
import main.ast.nodes.declaration.struct.StructDeclaration;
import main.ast.nodes.expression.*;
import main.ast.nodes.expression.values.primitive.BoolValue;
import main.ast.nodes.expression.values.primitive.IntValue;
import main.ast.nodes.statement.*;
import main.compileError.CompileError;
import main.compileError.nameError.DuplicateFunction;
import main.compileError.nameError.DuplicateStruct;
import main.symbolTable.SymbolTable;
import main.symbolTable.exceptions.ItemAlreadyExistsException;
import main.symbolTable.items.FunctionSymbolTableItem;
import main.symbolTable.items.StructSymbolTableItem;
import main.visitor.Visitor;

import java.util.UUID;

public class ErrorVisitor extends Visitor<Void> {
    public Boolean NoError = true;
    public void errorPrinter(CompileError error) {
        System.out.println(error.getMessage());
        NoError = false;
    }

    @Override
    public Void visit(Program program) {

        SymbolTable.root = new SymbolTable();

        for (StructDeclaration struct : program.getStructs()) {
            try {
                SymbolTable.root.put(new StructSymbolTableItem(struct));
            } catch (ItemAlreadyExistsException e) {
                errorPrinter(new DuplicateStruct(struct.getLine(), struct.getStructName().getName()));
                struct.getStructName().setName(UUID.randomUUID().toString());
                try {
                    SymbolTable.root.put(new StructSymbolTableItem(struct));
                } catch (ItemAlreadyExistsException ex) {
                    ex.printStackTrace();
                }
            }
            struct.accept(this);
        }

        for (FunctionDeclaration function : program.getFunctions()) {
            try {
                SymbolTable.root.put(new FunctionSymbolTableItem(function));
            } catch (ItemAlreadyExistsException e) {
                errorPrinter(new DuplicateFunction(function.getLine(), function.getFunctionName().getName()));
                function.getFunctionName().setName(UUID.randomUUID().toString());
                try {
                    SymbolTable.root.put(new FunctionSymbolTableItem(function));
                } catch (ItemAlreadyExistsException ex) {
                    ex.printStackTrace();
                }
            }
            function.accept(this);
        }

        program.getMain().accept(this);
        return super.visit(program);
    }

    @Override
    public Void visit(FunctionDeclaration functionDeclaration) {
        return super.visit(functionDeclaration);
    }

    @Override
    public Void visit(MainDeclaration mainDeclaration) {
        return super.visit(mainDeclaration);
    }

    @Override
    public Void visit(VariableDeclaration variableDeclaration) {
        return super.visit(variableDeclaration);
    }

    @Override
    public Void visit(StructDeclaration structDeclaration) {
        return super.visit(structDeclaration);
    }

    @Override
    public Void visit(SetGetVarDeclaration setGetVarDeclaration) {
        return super.visit(setGetVarDeclaration);
    }

    @Override
    public Void visit(AssignmentStmt assignmentStmt) {
        return super.visit(assignmentStmt);
    }

    @Override
    public Void visit(BlockStmt blockStmt) {
        return super.visit(blockStmt);
    }

    @Override
    public Void visit(ConditionalStmt conditionalStmt) {
        return super.visit(conditionalStmt);
    }

    @Override
    public Void visit(FunctionCallStmt functionCallStmt) {
        return super.visit(functionCallStmt);
    }

    @Override
    public Void visit(DisplayStmt displayStmt) {
        return super.visit(displayStmt);
    }

    @Override
    public Void visit(ReturnStmt returnStmt) {
        return super.visit(returnStmt);
    }

    @Override
    public Void visit(LoopStmt loopStmt) {
        return super.visit(loopStmt);
    }

    @Override
    public Void visit(VarDecStmt varDecStmt) {
        return super.visit(varDecStmt);
    }

    @Override
    public Void visit(ListAppendStmt listAppendStmt) {
        return super.visit(listAppendStmt);
    }

    @Override
    public Void visit(ListSizeStmt listSizeStmt) {
        return super.visit(listSizeStmt);
    }

    @Override
    public Void visit(BinaryExpression binaryExpression) {
        return super.visit(binaryExpression);
    }

    @Override
    public Void visit(UnaryExpression unaryExpression) {
        return super.visit(unaryExpression);
    }

    @Override
    public Void visit(Identifier identifier) {
        return super.visit(identifier);
    }

    @Override
    public Void visit(ListAccessByIndex listAccessByIndex) {
        return super.visit(listAccessByIndex);
    }

    @Override
    public Void visit(StructAccess structAccess) {
        return super.visit(structAccess);
    }

    @Override
    public Void visit(FunctionCall functionCall) {
        return super.visit(functionCall);
    }

    @Override
    public Void visit(IntValue intValue) {
        return super.visit(intValue);
    }

    @Override
    public Void visit(BoolValue boolValue) {
        return super.visit(boolValue);
    }

    @Override
    public Void visit(ListSize listSize) {
        return super.visit(listSize);
    }

    @Override
    public Void visit(ListAppend listAppend) {
        return super.visit(listAppend);
    }

    @Override
    public Void visit(ExprInPar exprInPar) {
        return super.visit(exprInPar);
    }


}
