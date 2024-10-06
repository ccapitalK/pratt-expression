import std.stdio;

import ast;
import lexer;

void main()
{
    auto lexed = lex("  2 * (33 + 4 * 1)  ");
	writeln(lexed);
}
