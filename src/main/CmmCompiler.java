package main;

import main.visitor.error.ErrorVisitor;
import main.visitor.name.ASTTreePrinter;
import main.grammar.*;
import main.ast.nodes.Program;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CommonTokenStream;

public class CmmCompiler {
    public void compile(CharStream textStream) {
        CmmLexer cmmLexer = new CmmLexer(textStream);
        CommonTokenStream tokenStream = new CommonTokenStream(cmmLexer);
        CmmParser cmmParser = new CmmParser(tokenStream);

        Program program = cmmParser.cmm().cmmProgram;

        ErrorVisitor errorVisitor = new ErrorVisitor();
        program.accept(errorVisitor);

        if (errorVisitor.NoError) {
            ASTTreePrinter printer = new ASTTreePrinter();
            program.accept(printer);
        }
    }
}
