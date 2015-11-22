%code top{
	#include <cstdio>
	#include <fstream>
	#include "tree.h"
}

%require "3.0"
%language "C++"
%locations
%error-verbose
/*%define parse.trace
%debug*/

%code{
	extern int yylex(yy::parser::semantic_type *yylval, yy::parser::location_type *yylloc);
	extern FILE *yyin;
	Node* node_root;
}
%define api.value.type variant

%token FUNC CLASS

%token IF ELSE ELIF
%token WHILE
%token FOR FOREACH IN
%token RETURN BREAK CONTINUE

%token PRINT

%token BEGINN END

%token ASSIGN
%token OR AND NOT XOR
%token EQ NE GT LT GE LE
%token SL SR

%token TYPE_INT TYPE_FLOAT TYPE_CHAR TYPE_STRING

%token INTEGER FLOAT CHAR STRING
%token NAME VAR
%token PLUS MINUS TIMES DIVIDE MOD
%token BITAND BITOR BITNOT BITXOR
%token LP RP LMP RMP LLP RLP
%token DOT COLON COMMA BRANCH
%token COMMENT PASS

%type <Node*> command
%type <Node*> program

%type <Node*> block
%type <Node*> sentence_list
%type <Node*> sentence
%type <Node*> sentence_run
%type <Node*> if
%type <Node*> if_child
%type <Node*> for
%type <Node*> foreach
%type <Node*> while
%type <Node*> assign
%type <Node*> print
%type <Node*> return
%type <Node*> break
%type <Node*> continue

%type <Node*> def_list
%type <Node*> def
%type <Node*> def_func
%type <Node*> def_class_list
%type <Node*> def_class
%type <Node*> def_class_in
%type <Node*> type

%type <Node*> exper_list
%type <Node*> exper
%type <Node*> exper_or
%type <Node*> exper_xor
%type <Node*> exper_and
%type <Node*> exper_bitor
%type <Node*> exper_bitxor
%type <Node*> exper_bitand
%type <Node*> exper_eq
%type <Node*> exper_com
%type <Node*> exper_bit
%type <Node*> exper_pm
%type <Node*> exper_td
%type <Node*> exper_not

%type <Node*> quark
%type <Node*> function
%type <Node*> function_run
%type <Node*> var_list
%type <Node*> varstore

%type <Node*> INTEGER
%type <Node*> FLOAT
%type <Node*> CHAR
%type <Node*> STRING

%type <Node*> NAME
%type <Node*> VAR

%type <Node*> PASS

%type <Node*> TYPE_INT
%type <Node*> TYPE_FLOAT
%type <Node*> TYPE_CHAR
%type <Node*> TYPE_STRING

%%
command :
	program {$$ = $1;;node_root = $$;}
;

program:
	def_class_list sentence_list {$$=new Node("program", new vector<Node*>{$1,$2});}
|	sentence_list {$$=$1;}
;

block :
	LLP sentence_list RLP {$$ = new Node("{}", new vector<Node*>{$2});}
|	LLP block RLP {$$ = new Node("{}", new vector<Node*>{$2});}
;

sentence_list:
	sentence {$$ = new Node("sentencelist", new vector<Node*>{$1});}
|	sentence_list sentence {$$ = new Node("sentencelist", $1, $2);}
;

sentence:
	sentence_run {$$ = $1;}
|	def BRANCH {$$ = new Node("sentence", new vector<Node*>{$1});}
|	if {$$ = new Node("sentence", new vector<Node*>{$1});}
|	for {$$ = new Node("sentence", new vector<Node*>{$1});}
|	foreach {$$ = new Node("sentence", new vector<Node*>{$1});}
|	while {$$ = new Node("sentence", new vector<Node*>{$1});}
|	block {$$ = new Node("sentence", new vector<Node*>{$1});}
|	print BRANCH {$$ = new Node("sentence", new vector<Node*>{$1});}
|	return BRANCH {$$ = new Node("sentence", new vector<Node*>{$1});}
|	break BRANCH {$$ = new Node("sentence", new vector<Node*>{$1});}
|	continue BRANCH {$$ = new Node("sentence", new vector<Node*>{$1});}
;

print:
	PRINT LP exper_list RP {$$ = new Node("print", new vector<Node*>{$3});}
;

return:
	RETURN exper {$$ = new Node("return", new vector<Node*>{$2});}
;

break:
	BREAK {$$ = new Node("break");}
;

continue:
	CONTINUE {$$ = new Node("continue");}
;

if:
	IF if_child {$$ = $2;}
;

if_child:
	exper COLON block {$$ = new Node("if", new vector<Node*>{$1,$3});}
|	exper COLON block ELSE block {$$ = new Node("if", new vector<Node*>{$1,$3,$5});}
|	exper COLON block ELIF if_child {$$ = new Node("if", new vector<Node*>{$1,$3,$5});}
;

for:
	FOR LP sentence_run BRANCH sentence_run BRANCH sentence_run RP block {$$ = new Node("for", new vector<Node*>{$3,$5,$7,$9});}
;

foreach:
	FOREACH LP VAR IN varstore RP block {$$ = new Node("for", new vector<Node*>{$3,$5});}
;

while:
	WHILE exper COLON block {$$ = new Node("while", new vector<Node*>{$2,$4});}
;

sentence_run:
	exper BRANCH {$$ = new Node("sentence", new vector<Node*>{$1});}
|	assign BRANCH {$$ = new Node("sentence", new vector<Node*>{$1});}
|	PASS BRANCH {$$ = new Node("pass");}
;

assign:
	varstore ASSIGN assign {$$ = new Node("=", new vector<Node*>{$1,$3});}
|	varstore ASSIGN exper {$$ = new Node("=", new vector<Node*>{$1,$3});}
|	def_func {$$ = $1;}
;

def_list:
	def{$$ = new Node("deflist", new vector<Node*>{$1});}
|	def_list COMMA def {$$ = new Node("deflist", $1, $3);}
;

def:
	type var_list {$$ = new Node("def", new vector<Node*>{$1,$2});}
;

def_func:
	varstore ASSIGN function {$$ = new Node("deffunction", new vector<Node*>{$1,$3});}
;

def_class_list:
	def_class {$$ = new Node("defclasslist", new vector<Node*>{$1});}
|	def_class_list def_class {$$ = new Node("defclasslist", $1, $2);}
;

def_class:
	CLASS NAME LP RP LLP def_class_in RLP BRANCH {$$ = new Node("defclass", new vector<Node*>{$2,new Node(""),$6});}
|	CLASS NAME LP NAME RP LLP def_class_in RLP BRANCH {$$ = new Node("defclass", new vector<Node*>{$2,$4,$7});}
;

def_class_in:
	def BRANCH {$$ = new Node("defclassin", new vector<Node*>{$1});}
|	def_func BRANCH {$$ = new Node("defclassin", new vector<Node*>{$1});}
|	def_class_in def BRANCH {$$ = new Node("defclassin", $1, $2);}
|	def_class_in def_func BRANCH {$$ = new Node("defclassin", $1, $2);}
;


type:
	TYPE_INT {$$ = $1;}
|	TYPE_FLOAT {$$ = $1;}
|	TYPE_CHAR {$$ = $1;}
|	TYPE_STRING	{$$ = $1;}
|	NAME {$$ = new Node("type", new vector<Node*>{$1});}
|	type LMP RMP {$$ = new Node("type", $1, new Node("[]"));}
;

exper_list:
	exper{$$ = new Node("experlist", new vector<Node*>{$1});}
|	exper_list COMMA exper {$$ = new Node("experlist", $1, $3);}
;
exper:
	exper_or {$$ = $1;;}
;
exper_or:
	exper_or OR exper_xor {$$ = new Node("or", new vector<Node*>{$1,$3});}
|	exper_xor {$$ = $1;}
;
exper_xor:
	exper_xor XOR exper_and {$$ = new Node("xor", new vector<Node*>{$1,$3});}
|	exper_and {$$ = $1;}
;
exper_and:
	exper_and AND exper_bitor {$$ = new Node("and", new vector<Node*>{$1,$3});}
|	exper_bitor {$$ = $1;}
;
exper_bitor:
	exper_bitor BITOR exper_bitxor {$$ = new Node("|", new vector<Node*>{$1,$3});}
|	exper_bitxor {$$ = $1;}
;
exper_bitxor:
	exper_bitxor BITXOR exper_bitand {$$ = new Node("^", new vector<Node*>{$1,$3});}
|	exper_bitand {$$ = $1;}
;
exper_bitand:
	exper_bitand BITAND exper_eq {$$ = new Node("&", new vector<Node*>{$1,$3});}
|	exper_eq {$$ = $1;}
;
exper_eq:
	exper_com EQ exper_com {$$ = new Node("==", new vector<Node*>{$1,$3});}
|	exper_com NE exper_com {$$ = new Node("!=", new vector<Node*>{$1,$3});}
|	exper_com {$$ = $1;}
;
exper_com:
	exper_bit LT exper_bit {$$ = new Node("<", new vector<Node*>{$1,$3});}
|	exper_bit GT exper_bit {$$ = new Node(">", new vector<Node*>{$1,$3});}
|	exper_bit LE exper_bit {$$ = new Node("<=", new vector<Node*>{$1,$3});}
|	exper_bit GE exper_bit {$$ = new Node(">=", new vector<Node*>{$1,$3});}
|	exper_bit {$$ = $1;}
;
exper_bit:
	exper_bit SL exper_pm {$$ = new Node("<<", new vector<Node*>{$1,$3});}
|	exper_bit SR exper_pm {$$ = new Node(">>", new vector<Node*>{$1,$3});}
|	exper_pm {$$ = $1;}
;
exper_pm:
	exper_pm PLUS exper_td {$$ = new Node("+", new vector<Node*>{$1,$3});}
|	exper_pm MINUS exper_td {$$ = new Node("-", new vector<Node*>{$1,$3});}
|	exper_td {$$ = $1;}
;
exper_td:
	exper_td TIMES exper_not {$$ = new Node("*", new vector<Node*>{$1,$3});}
|	exper_td DIVIDE exper_not {$$ = new Node("/", new vector<Node*>{$1,$3});}
|	exper_td MOD exper_not {$$ = new Node("%", new vector<Node*>{$1,$3});}
|	exper_not {$$ = $1;}
;
exper_not:
	NOT exper_not {$$ = new Node("not", new vector<Node*>{$2});}
|	BITNOT exper_not {$$ = new Node("~", new vector<Node*>{$2});}
|	quark {$$ = $1;}
;

quark :
	INTEGER {$$ = new Node("int",new vector<Node*>{$1});}
| 	FLOAT {$$ = new Node("float",new vector<Node*>{$1});}
| 	CHAR {$$ = new Node("char",new vector<Node*>{$1});}
| 	STRING {$$ = new Node("string",new vector<Node*>{$1});}
| 	LP exper RP {$$ = new Node("()",new vector<Node*>{$2});}
| 	varstore {$$ = $1;}
|	function_run {$$ = $1;}
;

function:
	type FUNC LP def_list RP block {$$ = new Node("function", new vector<Node*>{$1,$4,$6});}
;

function_run:
	varstore LP exper_list RP {$$ = new Node("run", new vector<Node*>{$1,$3});}
;

var_list :
	varstore {$$ = new Node("varlist", new vector<Node*>{$1});}
|	var_list COMMA varstore {$$ = new Node("varlist", $1, $3);}
;

varstore :
 	varstore LMP exper RMP {$$ = new Node("[]",new vector<Node*>{$1,$3});}
|	varstore DOT exper {$$ = new Node(".",new vector<Node*>{$1,$3});}
| 	VAR {$$ = new Node("VAR",new vector<Node*>{$1});}


%%

void yy::parser::error(const yy::parser::location_type& L, const string& M) {
	cerr << L << ' ' << M << endl;
}

int main(int argc, char **argv) {
	if (argc > 1)
		yyin = fopen(argv[1], "r");
	streambuf *saved_cout = cout.rdbuf();
	ofstream output;
	if (argc > 2) {
		output.open(argv[2]);
		cout.rdbuf(output.rdbuf());
	}
	yy::parser parser;
	//parser.set_debug_level(1);
	parser.parse();
	if (node_root)
		cout<<node_root->pr()<<endl;
	cout.rdbuf(saved_cout);
	if (argc > 2)
		output.close();
	return 0;
}
