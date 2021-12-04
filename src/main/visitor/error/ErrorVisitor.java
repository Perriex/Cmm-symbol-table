package main.visitor.error;

import main.ast.nodes.Program;
import main.ast.nodes.declaration.FunctionDeclaration;
import main.ast.nodes.declaration.MainDeclaration;
import main.ast.nodes.declaration.VariableDeclaration;
import main.ast.nodes.declaration.struct.StructDeclaration;
import main.ast.nodes.expression.FunctionCall;
import main.ast.nodes.statement.*;
import main.compileError.CompileError;
import main.compileError.nameError.*;
import main.symbolTable.SymbolTable;
import main.symbolTable.exceptions.ItemAlreadyExistsException;
import main.symbolTable.exceptions.ItemNotFoundException;
import main.symbolTable.items.FunctionSymbolTableItem;
import main.symbolTable.items.StructSymbolTableItem;
import main.symbolTable.items.VariableSymbolTableItem;
import main.symbolTable.utils.Stack;
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
        SymbolTable.push(SymbolTable.root);

        for (StructDeclaration struct : program.getStructs()) {
            var structItem = new StructSymbolTableItem(struct);
            SymbolTable.push(new SymbolTable(SymbolTable.root));
            structItem.setStructSymbolTable(SymbolTable.top);

            try {
                SymbolTable.root.put(structItem);
            } catch (ItemAlreadyExistsException e) {
                errorPrinter(new DuplicateStruct(struct.getLine(), struct.getStructName().getName()));
                structItem.setName(UUID.randomUUID().toString());
                try {
                    SymbolTable.root.put(structItem);
                } catch (ItemAlreadyExistsException ex) {
                    ex.printStackTrace();
                }
            }
            struct.accept(this);
            SymbolTable.pop();
        }

        for (FunctionDeclaration function : program.getFunctions()) {
            function.accept(this);
        }
        program.getMain().accept(this);
        return super.visit(program);
    }

    @Override
    public Void visit(FunctionDeclaration functionDeclaration) {
        var funcItem = new FunctionSymbolTableItem(functionDeclaration);
        SymbolTable.push(new SymbolTable(SymbolTable.top));
        funcItem.setFunctionSymbolTable(SymbolTable.top);

        try {
            SymbolTable.top.pre.getItem(StructSymbolTableItem.START_KEY + funcItem.getName());
            errorPrinter(new FunctionStructConflict(functionDeclaration.getLine(), funcItem.getName()));
        } catch (ItemNotFoundException ignored) {}

        try {
            SymbolTable.top.pre.put(funcItem);
        } catch (ItemAlreadyExistsException e) {
            errorPrinter(new DuplicateFunction(functionDeclaration.getLine(), funcItem.getName()));
            funcItem.setName(UUID.randomUUID().toString());
            try {
                SymbolTable.top.pre.put(funcItem);
            } catch (ItemAlreadyExistsException ex) {
                ex.printStackTrace();
            }
        }

        for (VariableDeclaration arg : functionDeclaration.getArgs())
            arg.accept(this);
        functionDeclaration.getBody().accept(this);

        SymbolTable.pop();
        return super.visit(functionDeclaration);
    }

    @Override
    public Void visit(MainDeclaration mainDeclaration) {
        var functionDeclaration = new FunctionDeclaration();
        functionDeclaration.setBody(mainDeclaration.getBody());
        return super.visit(functionDeclaration);
    }

    @Override
    public Void visit(VariableDeclaration variableDeclaration) {
        var varItem = new VariableSymbolTableItem(variableDeclaration.getVarName());
        try {
            SymbolTable.top.getItem(StructSymbolTableItem.START_KEY+varItem.getName());
            errorPrinter(new VarStructConflict(variableDeclaration.getLine(), varItem.getName()));
        } catch (ItemNotFoundException ignored) {
        }
        try {
            SymbolTable.top.getItem(FunctionSymbolTableItem.START_KEY+varItem.getName());
            errorPrinter(new VarFunctionConflict(variableDeclaration.getLine(), varItem.getName()));
        } catch (ItemNotFoundException ignored) {
        }

        try {
            SymbolTable.top.put(varItem);
        } catch (ItemAlreadyExistsException ignored) {
            errorPrinter(new DuplicateVar(variableDeclaration.getLine(), varItem.getName()));
        }

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
    public Void visit(BlockStmt blockStmt) {
        for (Statement statement : blockStmt.getStatements()) {
            statement.accept(this);
        }
        return super.visit(blockStmt);
    }

    @Override
    public Void visit(ConditionalStmt conditionalStmt) {

        SymbolTable.push(new SymbolTable(SymbolTable.top));
        conditionalStmt.getThenBody().accept(this);
        SymbolTable.pop();
        SymbolTable.push(new SymbolTable(SymbolTable.top));
        conditionalStmt.getElseBody().accept(this);
        SymbolTable.pop();

        return super.visit(conditionalStmt);
    }

    @Override
    public Void visit(LoopStmt loopStmt) {
        SymbolTable.push(new SymbolTable(SymbolTable.top));
        loopStmt.getBody().accept(this);
        SymbolTable.pop();
        return super.visit(loopStmt);
    }
}
