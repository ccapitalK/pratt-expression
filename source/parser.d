import std.exception;
import ast;
import lexer;

struct Parser {
    Lexeme[] lexemes;
    size_t pos = 0;

    void unexpectedEnd() {
        throw new Exception("Failed to parse unexpected end of input");
    }

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
            if (pos >= lexemes.length) {
                unexpectedEnd();
            }
            auto next = peek();
            Expression inner;
            if (next == LexTag.intLiteral) {
                inner = parseIntLiteral();
            } else if (next == LexTag.openParen) {
                inner = parseExpression();
            }
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

Expression parse(string source) {
    auto lexemes = lex(source);
    return parse(lexemes);
}

unittest {
    import std.stdio;

    assert(printExpr(parse("1")) == "(1)");
    assert(printExpr(parse("(1)")) == "(1)");
    assert(printExpr(parse("-1")) == "(-(1))");
    assert(printExpr(parse("1 + -3")) == "((1) + (-(3)))");
    assert(printExpr(parse("-1 + 3")) == "((-(1)) + (3))");

    assert(printExpr(parse("1 + 3 * 5")) == "((1) + ((3) * (5)))");
    assert(printExpr(parse("(1 + 3) * 5")) == "(((1) + (3)) * (5))");
    assert(printExpr(parse("1 * 3 + 5")) == "(((1) * (3)) + (5))");
    assert(printExpr(parse("1 - 3 - 5")) == "(((1) - (3)) - (5))");
    assert(printExpr(parse("1 / 3 / 5")) == "(((1) / (3)) / (5))");
}
