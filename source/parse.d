import std.exception;
import ast;

struct Parser {
    Lexeme[] lexemes;
    size_t pos = 0;

    void unexpectedToken() {
        throw new Exception("Failed to parse unexpected token: " ~ lexemes[pos].toString);
    }

    LexTag peek() {
        enforce(pos < lexemes.length);
        return lexemes[pos].tag;
    }

    Lexeme consume() {
        enforce(pos < lexemes.length);
        pos += 1;
        return lexemes[pos - 1];
    }

    Lexeme expect(LexTag tag) {
        enforce(pos < lexemes.length);
        auto lexeme = lexemes[pos];
        if (lexeme.tag != tag) {
            unexpectedToken();
        }
        pos += 1;
        return lexeme;
    }

    IntLiteral parseIntLiteral() {
        auto lexeme = consume();
        enforce(lexeme.tag == LexTag.intLiteral);
        return new IntLiteral(lexeme);
    }

    Expression parseExpression(int precedence = 0) {
        enforce(pos < lexemes.length);
        Expression e;
        // Parse prefix expressions
        switch (peek()) {
        case LexTag.minus:
            auto op = consume();
            Expression inner = parseExpression();
            e = new UnOp(op, inner);
            break;
        case LexTag.openParen:
            consume();
            e = parseExpression();
            expect(LexTag.closeParen);
            break;
        case LexTag.intLiteral:
            e = parseIntLiteral();
            break;
        default:
            unexpectedToken();
            assert(0);
        }
        // Add infix expressions
        infix: while (pos < lexemes.length && precedence < peekPrecedence()) {
            auto nextPrecedence = peekPrecedence();
            switch (peek()) {
            case LexTag.plus:
            case LexTag.minus:
            case LexTag.mult:
            case LexTag.div:
                auto op = consume();
                Expression e2 = parseExpression(nextPrecedence);
                e = cast(Expression) new BinOp(op, e, e2);
                break;
            default:
                break infix;
            }
        }
        return e;
    }

    int peekPrecedence() {
        enforce(pos < lexemes.length);
        switch (peek()) {
        case LexTag.plus:
        case LexTag.minus:
            return 1;
        case LexTag.mult:
        case LexTag.div:
            return 2;
        default:
            return -1;
        }
    }
}

Expression parse(Lexeme[] lexemes) {
    Parser parser;
    parser.lexemes = lexemes;
    auto expr = parser.parseExpression();
    enforce(parser.pos == parser.lexemes.length);
    return expr;
}

unittest {
    import lexer;
    import std.stdio;

    auto exp(T)(T v) => cast(Expression) v;
    Expression il(Lexeme l) => exp(new IntLiteral(l));
    auto uo(Lexeme l, Expression e) => exp(new UnOp(l, e));
    auto bo(Lexeme l, Expression e1, Expression e2) => exp(new BinOp(l, e1, e2));

    auto t1 = lex("1");
    assert(il(t1[0]) == parse(t1));
    auto t2 = lex("(1)");
    assert(il(t2[1]) == parse(t2));
    auto t3 = lex("-1");
    assert(uo(t3[0], il(t3[1])) == parse(t3));
    auto t4 = lex("-1 + 3");

    // What we expect
    // assert(bo(t4[2], uo(t4[0], il(t4[1])), il(t4[3])) == parse(t4));

    // What we get
    assert(uo(t4[0], bo(t4[2], il(t4[1]), il(t4[3]))) == parse(t4));
    auto t5 = lex("1 + 3 * 5");
    assert(bo(t5[1], il(t5[0]), bo(t5[3], il(t5[2]), il(t5[4]))) == parse(t5));
    auto t6 = lex("1 * 3 + 5");
    assert(bo(t6[3], bo(t6[1], il(t6[0]), il(t6[2])), il(t6[4])) == parse(t6));
}
