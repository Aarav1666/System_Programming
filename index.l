%{
// CREATED BY AKSHIT SHARMA (2019CSC1068);
#include "y.tab.h"
#include <iostream>
#include <string>
#include <cstring>

using namespace std;

void yyerror (char *s);
int yylex();
%}
%option nounput yylineno

%%

"SHOW"      {return SHOW;}
"SELECT"    {return SELECT;}
"EXIT"      {return EXIT;}
"EVALUATE"	{return EVALUATE;}
"GET"		{return GET;}

";"			{yylval.cur_num = 0; return SEMICOLON;}
"="			{return EQUAL;}
"+"			{return PLUS;}
"-"			{return MINUS;}
"*"			{return STAR;}
"/"			{return SLASH;}
"("			{return LPAREN;}
")"			{return RPAREN;}

"<"[a-zA-Z_][_a-zA-Z0-9]*">"	{
									
                                    string newStringp = yytext;
									yylval.cur_string = &newStringp[0]; 
									yylval.cur_string = new char [newStringp.length()+1]; 
									strcpy(yylval.cur_string,newStringp.c_str()); 
									return IDENTIFIER;
								}
([0-9]*[.])?[0-9]+              {
                                    yylval.cur_num = atoi(yytext);
                                    return NUMBER;
                                }

[ \t\n]				{;}
.					{;}

%%

int yywrap(void)
{
	return 1;
}

