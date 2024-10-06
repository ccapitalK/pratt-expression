import ast;

auto exp(T)(T v) => cast(Expression) v;

struct Parser {
}

Expression parse(Lexeme[] lexemes) {
    Parser parser;
    auto op = lexemes[1];
    Expression e1 = new IntLiteral(lexemes[0]);
    Expression e2 = new IntLiteral(lexemes[2]);
    return cast(Expression) new BinOp(op, e1, e2);
}

unittest {
    import lexer;

    IntLiteral il(Lexeme l) => new IntLiteral(l);
    auto t1 = lex("1 + 1");
    assert(t1[0] == t1[2]);
    auto v1 = il(t1[0]);
    auto v2 = il(t1[2]);
    assert(v1 == v2);
    Expression expr1 = parse(t1);
    Expression expected1 = exp(new BinOp(t1[1], exp(il(t1[0])), exp(il(t1[2]))));
    assert(expr1 == expected1);
}
