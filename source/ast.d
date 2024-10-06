import std.conv;

enum LexTag {
    plus = 0,
    minus,
    mult,
    div,
    intLiteral,
    openParen,
    closeParen,
}

struct Lexeme {
    LexTag tag;
    string span;

    this(LexTag tag, string span) {
        this.tag = tag;
        this.span = span;
    }

    string toString() const pure => "Lexeme(LexTag." ~ tag.to!string ~ ", \"" ~ span ~ "\")";
}
