package main.visitor.error;

import main.ast.nodes.Program;
import main.ast.nodes.declaration.FunctionDeclaration;
import main.ast.nodes.declaration.MainDeclaration;
import main.ast.nodes.declaration.VariableDeclaration;
import main.ast.nodes.declaration.struct.StructDeclaration;
import main.ast.nodes.expression.FunctionCall;
import main.ast.nodes.expression.Identifier;
import main.ast.nodes.statement.*;
import main.compileError.CompileError;
import main.compileError.nameError.*;
import main.symbolTable.SymbolTable;
import main.symbolTable.exceptions.ItemAlreadyExistsException;
import main.symbolTable.exceptions.ItemNotFoundException;
import main.symbolTable.items.FunctionSymbolTableItem;
import main.symbolTable.items.StructSymbolTableItem;
import main.symbolTable.items.VariableSymbolTableItem;
import main.visitor.Visitor;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class ErrorVisitor extends Visitor<Void> {

    public class StructInfo
    {
        public String StructParentName;
        public int Line;
        public StructInfo(int line, String name) {
            StructParentName = name;
            Line = line;
        }
    }

    public Boolean NoError = true;
    public Boolean check = false;
    public String topStruct = "";// add
    public int line = 0;// add
    public Map<String, ArrayList<StructInfo>> numDecs = new HashMap<>();// add
    public Map<String, Integer> printed = new HashMap<>();

    public void errorPrinter(CompileError error) {
        System.out.println(error.getMessage());
        NoError = false;
    }

    @Override
    public Void visit(Program program) {
        SymbolTable.root = new SymbolTable();
        SymbolTable.push(SymbolTable.root);

        check= true;
        for (StructDeclaration struct : program.getStructs()) {
            var structItem = new StructSymbolTableItem(struct);
            SymbolTable.push(new SymbolTable(SymbolTable.root));
            structItem.setStructSymbolTable(SymbolTable.top);
            topStruct = struct.getStructName().getName(); // add
            line = struct.getLine();
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
        for (var entry : printed.entrySet()) {
            errorPrinter(new CyclicDependency(entry.getValue(), entry.getKey()));
        }
        check = false;
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
        functionDeclaration.setFunctionName(new Identifier("main"));
        return visit(functionDeclaration);
    }

    @Override
    public Void visit(VarDecStmt varDecStmt) {
        for (VariableDeclaration var : varDecStmt.getVars()) {
            var.accept(this);
        }
        return super.visit(varDecStmt);
    }

    public Boolean backTrack(String name,String target){
        if(numDecs.containsKey(name)){
            for (StructInfo s : numDecs.get(name)) {
                String parent = s.StructParentName;
                if (target.equals(parent)) {
                    printed.put(parent,s.Line);
                    return true;
                } else {
                    if (backTrack(parent, target)) {
                        printed.put(parent,s.Line);
                        return true;
                    }
                }
            }
        }
        return false;
    }
    @Override
    public Void visit(VariableDeclaration variableDeclaration) {
        if(check) {//added
            if (variableDeclaration.getVarType().toString().matches("StructType_.*")) {
                String name = variableDeclaration.getVarType().toString().split("_",2)[1];
                if (topStruct.equals(name)) {
                    //errorPrinter(new CyclicDependency(line, topStruct));
                    printed.put(topStruct,line);
                } else {
                    if (numDecs.containsKey(name)) {
                        ArrayList<StructInfo> temp = numDecs.get(name);
                        temp.add(new StructInfo(line, topStruct));
                    } else {
                        ArrayList<StructInfo> temp = new ArrayList<>();
                        temp.add(new StructInfo(line, topStruct));
                        numDecs.put(name, temp);
                    }
                    backTrack(name,name);
                }
            }
        }

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
            SymbolTable.top.getItem(varItem.getKey());
            errorPrinter(new DuplicateVar(variableDeclaration.getLine(), varItem.getName()));
        } catch (ItemNotFoundException ignored) {
        }

        try {
            SymbolTable.top.put(varItem);
        } catch (ItemAlreadyExistsException ignored) {
        }

        return super.visit(variableDeclaration);
    }

    @Override
    public Void visit(StructDeclaration structDeclaration) {
        structDeclaration.getBody().accept(this);
        //loop
        return super.visit(structDeclaration);
    }

    @Override
    public Void visit(SetGetVarDeclaration setGetVarDeclaration) {
        var item = new VariableSymbolTableItem(setGetVarDeclaration.getVarName());
        item.setType(setGetVarDeclaration.getVarType());
        try {
            SymbolTable.root.getItem(StructSymbolTableItem.START_KEY + setGetVarDeclaration.getVarName().getName());
            errorPrinter(new VarStructConflict(setGetVarDeclaration.getLine(), setGetVarDeclaration.getVarName().getName()));
        } catch (ItemNotFoundException ignored) {}

        try {
            SymbolTable.top.put(item);
        } catch (ItemAlreadyExistsException ex) {
            errorPrinter(new DuplicateVar(setGetVarDeclaration.getLine(), setGetVarDeclaration.getVarName().getName()));
        }
        for(VariableDeclaration var: setGetVarDeclaration.getArgs())
            var.accept(this);
        setGetVarDeclaration.getSetterBody().accept(this);
        setGetVarDeclaration.getGetterBody().accept(this);
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
