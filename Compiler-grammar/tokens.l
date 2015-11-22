%top{
	#include <stdio.h>
	#include "tree.h"
	#include "parser.h"

	#define YY_DECL int yylex(yy::parser::semantic_type *yylval, yy::parser::location_type *yylloc)
	#define YY_USER_ACTION yylloc->columns(yyleng);
}

%%
%{
	yylloc->step();
%}

"function"		return yy::parser::token::FUNC;
"class"			return yy::parser::token::CLASS;

"if"			return yy::parser::token::IF;
"else"			return yy::parser::token::ELSE;
"elif"			return yy::parser::token::ELIF;

"while"			return yy::parser::token::WHILE;
"for"			return yy::parser::token::FOR;
"foreach"		return yy::parser::token::FOREACH;
"in"			return yy::parser::token::IN;

"return"		return yy::parser::token::RETURN;
"break"			return yy::parser::token::BREAK;
"continue"		return yy::parser::token::CONTINUE;
"print"			return yy::parser::token::PRINT;

"pass"			return yy::parser::token::PASS;

"="				return yy::parser::token::ASSIGN;
"or"			return yy::parser::token::OR;
"and"			return yy::parser::token::AND;
"not"			return yy::parser::token::NOT;
"xor"			return yy::parser::token::XOR;
"=="			return yy::parser::token::EQ;
"!="			return yy::parser::token::NE;
">"				return yy::parser::token::GT;
"<"				return yy::parser::token::LT;
">="			return yy::parser::token::GE;
"<="			return yy::parser::token::LE;
"<<"			return yy::parser::token::SL;
">>"			return yy::parser::token::SR;

"int"			{yylval->build(new Node(yytext));return yy::parser::token::TYPE_INT;}
"float"			{yylval->build(new Node(yytext));return yy::parser::token::TYPE_FLOAT;}
"char"			{yylval->build(new Node(yytext));return yy::parser::token::TYPE_CHAR;}
"string"		{yylval->build(new Node(yytext));return yy::parser::token::TYPE_STRING;}

([0-9])+ 					{yylval->build(new Node(yytext));return yy::parser::token::INTEGER;}
([0-9])+\.([0-9])+ 			{yylval->build(new Node(yytext));return yy::parser::token::FLOAT;}
\'([^'\\]|\\.)\'			{
	stringstream ss;
	for (int i = 1; i < yyleng - 1; i++)
		ss << *(yytext + i);
	yylval->build(new Node(ss.str()));
	return yy::parser::token::CHAR;
}
\"([^"\\]|\\.)*\"			{
	stringstream ss;
	for (int i = 1; i < yyleng - 1; i++)
		ss << *(yytext + i);
	yylval->build(new Node(ss.str()));
	return yy::parser::token::STRING;
}

[a-zA-Z][a-zA-Z0-9]* 		{yylval->build(new Node(yytext));return yy::parser::token::NAME;}
\$[a-zA-Z][a-zA-Z0-9]* 		{yylval->build(new Node(yytext));return yy::parser::token::VAR;}

"+" 			return yy::parser::token::PLUS;
"-" 			return yy::parser::token::MINUS;
"*" 			return yy::parser::token::TIMES;
"/" 			return yy::parser::token::DIVIDE;
"%" 			return yy::parser::token::MOD;

"~" 			return yy::parser::token::BITNOT;
"&" 			return yy::parser::token::BITAND;
"|" 			return yy::parser::token::BITOR;
"^" 			return yy::parser::token::BITXOR;

"(" 			return yy::parser::token::LP;
")" 			return yy::parser::token::RP;
"[" 			return yy::parser::token::LMP;
"]" 			return yy::parser::token::RMP;
"{" 			return yy::parser::token::LLP;
"}" 			return yy::parser::token::RLP;

"."				{yylval->build(new Node(yytext));return yy::parser::token::DOT;}
":"				{yylval->build(new Node(yytext));return yy::parser::token::COLON;}
","				{yylval->build(new Node(yytext));return yy::parser::token::COMMA;}
";"				{yylval->build(new Node(yytext));return yy::parser::token::BRANCH;}

"//".*$			/* ignore comment */
[ \t]+			{yylloc->step();}
[\n]+			{yylloc->lines(yyleng);yylloc->step();}
. 				{return *yytext;}
%%

int yywrap()
{
	return 1;
}
