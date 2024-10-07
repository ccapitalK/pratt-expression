import std.conv;
import std.sumtype;
import std.traits : FieldNameTuple;

import autohash;

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

alias Expression = SumType!(BinOp, UnOp, IntLiteral);

class BinOp {
    Lexeme operator;
    Expression left;
    Expression right;

    this() {
    }

    this(Lexeme operator, Expression left, Expression right) {
        this.operator = operator;
        this.left = left;
        this.right = right;
    }

    override string toString() const pure => "BinOp(" ~ left.toString ~ ", " ~ operator
        .toString ~ ", " ~ right.toString ~ ")";

    mixin AutoHashEquals;
}

class UnOp {
    Lexeme operator;
    Expression exp;

    this() {
    }

    this(Lexeme operator, Expression exp) {
        this.operator = operator;
        this.exp = exp;
    }

    override string toString() const pure => "UnOp(" ~ operator.toString ~ ", " ~ exp
        .toString ~ ")";

    mixin AutoHashEquals;
}

class IntLiteral {
    Lexeme literal;

    this() {
    }

    this(Lexeme literal) {
        this.literal = literal;
    }

    override string toString() const pure => "IntLiteral(" ~ literal.span ~ ")";

    mixin AutoHashEquals;
}

string printExpr(Expression e) {
    import std.array;
    Appender!string data;
    void visit(Expression e) {
        e.match!(
            (BinOp op) {
                data.put("(");
                visit(op.left);
                data.put(" ");
                data.put(op.operator.span);
                data.put(" ");
                visit(op.right);
                data.put(")");
            },
            (UnOp op) {
                data.put("(");
                data.put(op.operator.span);
                visit(op.exp);
                data.put(")");
            },
            (IntLiteral il) {
                data.put("(");
                data.put(il.literal.span);
                data.put(")");
            },
        );
    }
    visit(e);
    return data.data();
}

unittest {
    auto str = "++";
    auto l1 = Lexeme(LexTag.plus, str[0 .. 1]);
    auto l2 = Lexeme(LexTag.plus, str[1 .. 2]);
    assert(l1 == l2);
    auto i1 = new IntLiteral(l1);
    auto i2 = new IntLiteral(l2);
    assert(i1 == i2);
    assert(i1.toHash == i2.toHash);
    Expression e1 = i1;
    Expression e2 = i2;
    assert(e1 == e2);

}
