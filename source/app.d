import std.conv;
import std.exception;
import std.stdio;
import std.sumtype;

import ast;
import lexer;
import parser;

int eval(Expression e) {
    return e.match!(
        (BinOp op) {
            auto l = eval(op.left);
            auto r = eval(op.right);
            switch (op.operator.tag) {
            case LexTag.plus:
                return l + r;
            case LexTag.minus:
                return l - r;
            case LexTag.mult:
                return l * r;
            case LexTag.div:
                return l / r;
            default:
                throw new Exception("Unreachable code");
            }
        },
        (UnOp op) {
            enforce(op.operator.tag == LexTag.minus);
            return -eval(op.exp);
        },
        (IntLiteral l) => to!int(l.literal.span),
    );
    return 0;
}

void main(string[] args)
{
    string exprSource = "  2 * (33 + 4) * 1  ";
    if (args.length > 1) {
        exprSource = args[1];
    }
    auto exp = parse(exprSource);
    writeln("Eval \"", exprSource, "\": ", eval(exp));
}
