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
import main.compileError.nameError.FunctionStructConflict;
import main.symbolTable.SymbolTable;
import main.symbolTable.exceptions.ItemAlreadyExistsException;
import main.symbolTable.exceptions.ItemNotFoundException;
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
            var funcItem = new FunctionSymbolTableItem(function);
            SymbolTable.push(new SymbolTable(SymbolTable.root));
            funcItem.setFunctionSymbolTable(SymbolTable.top);

            try {
                SymbolTable.root.getItem(StructSymbolTableItem.START_KEY + funcItem.getName());
                errorPrinter(new FunctionStructConflict(function.getLine(), funcItem.getName()));
            } catch (ItemNotFoundException ignored) {}

            try {
                SymbolTable.root.put(funcItem);
            } catch (ItemAlreadyExistsException e) {
                errorPrinter(new DuplicateFunction(function.getLine(), funcItem.getName()));
                funcItem.setName(UUID.randomUUID().toString());
                try {
                    SymbolTable.root.put(funcItem);
                } catch (ItemAlreadyExistsException ex) {
                    ex.printStackTrace();
                }
            }
            function.accept(this);
            SymbolTable.pop();
        }

        var main = new FunctionDeclaration();
        main.setBody(program.getMain().getBody());
        var funcItem = new FunctionSymbolTableItem(main);
        SymbolTable.push(new SymbolTable(SymbolTable.root));
        funcItem.setFunctionSymbolTable(SymbolTable.top);

        try {
            SymbolTable.root.put(funcItem);
        } catch (ItemAlreadyExistsException ignored) {
        }

        program.getMain().accept(this);
        SymbolTable.pop();
        return super.visit(program);
    }

    @Override
    public Void visit(FunctionDeclaration functionDeclaration) {
        for (VariableDeclaration arg : functionDeclaration.getArgs())
            arg.accept(this);
        functionDeclaration.getBody().accept(this);
        return super.visit(functionDeclaration);
    }

    @Override
    public Void visit(MainDeclaration mainDeclaration) {
        mainDeclaration.getBody().accept(this);
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
    public Void visit(BlockStmt blockStmt) {
        return super.visit(blockStmt);
    }

    @Override
    public Void visit(ConditionalStmt conditionalStmt) {
        return super.visit(conditionalStmt);
    }

    @Override
    public Void visit(LoopStmt loopStmt) {
        return super.visit(loopStmt);
    }
}
