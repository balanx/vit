/****************************************************************************
   Copyright 2015  tobalanx@qq.com

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
****************************************************************************/

%{
#include <stdio.h>
#include <string.h>

#include "vit.h"
/*
extern char* yylval;
*/

int cmnt_saved_state;

%}

%option yylineno

%x  COMMENT
%x  QUOTE
%x  VALS
%x  PORT

%%
<INITIAL,PORT,VALS>"/*"|"task"|"function"    { cmnt_saved_state = YYSTATE; BEGIN(COMMENT); }
<INITIAL,PORT>"*/"        { fprintf(stderr,"WARNING : NO `/*' ahead of `*/'\n"); }
<INITIAL,PORT>"//".*$     { }

\"          { BEGIN(QUOTE); }
module      { BEGIN(PORT); return MODULE; }
input       { BEGIN(PORT); return INPUT ; }
output      { BEGIN(PORT); return OUTPUT; }
inout       { BEGIN(PORT); return INOUT ; }
parameter   { BEGIN(PORT); return PARAMETER ; }
endmodule   { return ENDMODULE; }
[a-zA-Z_][a-zA-Z0-9_]* { }
[ \t\n\r]+  { }
.           { }

<COMMENT>"/*"   { fprintf(stderr,"WARNING : `/*' within comment\n"); }
<COMMENT>"*/"|"endtask"|"endfunction"   { BEGIN(cmnt_saved_state); }
<COMMENT>[ \t\n\r]+  { }
<COMMENT>.  { }

<QUOTE>\"   { BEGIN(INITIAL); }
<QUOTE>[ \t\n\r]+  { }
<QUOTE>.    { }

<PORT>;         { BEGIN(INITIAL); return ';'; }

<PORT>"#"         return '#';
<PORT>","         return ',';
<PORT>"("         return '(';
<PORT>")"         return ')';

<PORT>input       return INPUT ;
<PORT>output      return OUTPUT;
<PORT>inout       return INOUT ;
<PORT>reg         return REG ;
<PORT>wire        return WIRE;
<PORT>parameter   return PARAMETER;
<PORT>[a-zA-Z_][a-zA-Z0-9_]*   { yylval.s = strdup(yytext); return IDENTIFIER; }
    /* <PORT>[0-9]+      { yylval.i = atoi(yytext); return INTEGER; } */
<PORT>"["[^:]+":"[^\]]+"]"  { yylval.s = strdup(yytext); return RANGE; }

<PORT>"="       { BEGIN(VALS); return '='; }
<VALS>[^,;\)]*[,;\)]  {
        int c = yytext[yyleng -1];
        int t = 0;

        if (c == ')') {
            int i;
            for (i=0; yytext[i]; i++) {
                if (yytext[i] == '(')
                    t++;
                else if (yytext[i] == ')')
                    t--;
            }
        }

        if (t > 0 || (t == 0 && c == ')') )
            yymore();
        else {
            yyless(yyleng -1);
            yylval.s = strdup(yytext);
            BEGIN(PORT);
            return RVAL;
        }
    }

<PORT>[ \t\n\r]+  { }

%%

int yywrap()
{
    return 1;
}
