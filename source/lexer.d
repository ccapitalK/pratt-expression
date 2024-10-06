import std.ascii;
import std.conv;
import std.exception;

import ast;

struct Lexer {
    string data;
    size_t pos = 0;
    Lexeme[] lexemes;

    Lexeme[] parse(string data) {
        this.data = data;
        while (pos < data.length) {
            switch (data[pos]) {
            case ' ':
            case '\n':
            case '\t':
                ++pos;
                break;
            case '+':
                lexemes ~= this.consumeLiteral(LexTag.plus, 1);
                break;
            case '-':
                lexemes ~= this.consumeLiteral(LexTag.minus, 1);
                break;
            case '*':
                lexemes ~= this.consumeLiteral(LexTag.mult, 1);
                break;
            case '/':
                lexemes ~= this.consumeLiteral(LexTag.div, 1);
                break;
            case '(':
                lexemes ~= this.consumeLiteral(LexTag.openParen, 1);
                break;
            case ')':
                lexemes ~= this.consumeLiteral(LexTag.closeParen, 1);
                break;
            case '0': .. case '9':
                auto start = pos;
                ++pos;
                while (pos < data.length && data[pos].isDigit) {
                    ++pos;
                }
                lexemes ~= Lexeme(LexTag.intLiteral, data[start .. pos]);
                break;
            default:
                enforce(false, "Unexpected token at position " ~ to!string(pos) ~ ": " ~ data[pos]);
                break;
            }
        }
        return lexemes;
    }
}

Lexeme consumeLiteral(ref Lexer lexer, LexTag tag, size_t len) {
    auto lex = Lexeme(tag, lexer.data[lexer.pos .. lexer.pos + len]);
    lexer.pos += len;
    return lex;
}

Lexeme[] lex(string data) {
    Lexer lexer;
    return lexer.parse(data);
}

unittest {
    assert(lex("1 + 1").length == 3);
    assert(lex("  1 +1").length == 3);
    assert(lex(" 21 1 +1").length == 4);
}
