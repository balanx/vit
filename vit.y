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
//#define yyparse prog_parse
#define YYERROR_VERBOSE
#define YYDEBUG 2


#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

//typedef char* string;
extern int yyleng;

//sl: string length
int  max_port_sl;
int  max_pp_sl;
int  port_1995;

typedef struct _NODE
{
    char  direction;  // I: input, O: output, T: inout
    char *ranges;
    int   type;       // 0: port, 1: parameter
    char  name[256];
    char *pval;

    struct _NODE *next;
} node_t;

node_t *h_port = NULL;
node_t *h_para = NULL;
int   type;
char *ranges;
char  direction;
char *name;
char *pval;

void alloc_node (node_t** head, int type);
void print_port (node_t*  head);
void print_para (node_t*  head);
void print_wire (node_t*  head);

%}

%union {
    int   i;
    char *s;
    char  c;
};


%token  <s>  MODULE
%token  <s>  IDENTIFIER
%token  <s>  ENDMODULE
%token  <s>  REG
%token  <s>  WIRE
%token  <s>  OUTPUT
%token  <s>  INOUT
%token  <s>  INTEGER
%token  <s>  PARAMETER
%token  <s>  INPUT
%token  <s>  RANGE
%token  <s>  RVAL
%token  <s>  EOF_

%type   <s>  multi_modules
%type   <s>  module module_diff
%type   <s>  param_decl_2001 list_of_param_2001  param_2001
%type   <s>  param_decls param_decl list_of_param  param
%type   <s>  list_of_ports list_of_port
%type   <s>  module_items port_decl
%type   <s>  list_of_port_declarations list_of_port_array
%type   <s>  port_direction port_attribute list_of_delimit
%type   <s>  port_identifiers port_ident
%type   <s>  xrange

%type   <c>  rp
%type   <c>  sc

%type   <s>  error

%%

multi_modules
    : module
    | multi_modules module
    ;

module
    : MODULE
      { max_port_sl = 0;
        max_pp_sl = 0;
        port_1995 = 0;
      }
      IDENTIFIER
      module_diff
      ENDMODULE
      { printf("//========================================\n");
        printf("//\n");
        printf("// Instantiation: %s\n", $3);
        printf("//\n");
        printf("//========================================\n");

        print_wire(h_port);
        printf("\n%s  ", $3);
        if (h_para) {
        printf("#(\n");
        print_para(h_para);
        }
        printf("%s_inst (\n", $3);

        print_port(h_port);
        printf("); // instantiation of %s\n", $3);
        h_port = NULL;
        h_para = NULL;
      }
    ;

module_diff
    : param_decl_2001
      list_of_port_declarations sc
      param_decls
    | list_of_ports sc
      { port_1995 = 1; }
      module_items
    ;


list_of_ports
    : '(' list_of_port rp
      { $$ = $2; }
    | // empty
      { $$ = NULL; }
    ;

list_of_port
    : IDENTIFIER
      { if (port_1995) {
        name = $1;
        alloc_node(&h_port, 0);
        }
      }
    | list_of_port ',' IDENTIFIER
      { if (port_1995) {
        name = $3;
        alloc_node(&h_port, 0);
        }
      }
    | // empty
      { $$ = NULL; }
    ;

module_items
    : module_items port_decl
    | module_items param_decl
    | // empty
      { $$ = NULL; }
    ;

port_decl
    : port_attribute list_of_port sc
    ;

param_decls
    : param_decls param_decl
    | // empty
      { $$ = NULL; }
    ;

param_decl
    : PARAMETER xrange list_of_param sc
    ;

list_of_param
    : param
    | list_of_param ',' param
    ;

param
    : IDENTIFIER '=' RVAL
      { name = $1;
        pval = $3;
        alloc_node(&h_para, 1);
      }
    ;


/* verilog-2001 */

param_decl_2001
    : '('
      { $$ = NULL; }
    | '#' '(' list_of_param_2001 rp '('
      {  }
    ;

list_of_param_2001
    : param_2001
    | list_of_param_2001 ',' param_2001
    ;

param_2001
    : PARAMETER xrange IDENTIFIER '=' RVAL
      { name = $3;
        pval = $5;
        alloc_node(&h_para, 1);
      }
    | IDENTIFIER '=' RVAL
      { name = $1;
        pval = $3;
        alloc_node(&h_para, 1);
      }
    ;


list_of_port_declarations
    : list_of_port_array
    | list_of_port_declarations list_of_port_array
    | list_of_port_declarations ',' error
    ;

list_of_port_array
    : port_attribute port_identifiers
    ;

port_direction
    : INPUT
        { direction = 'I'; }
    | OUTPUT
        { direction = 'O'; }
    | INOUT
        { direction = 'T'; }
    ;

port_attribute
    : port_direction xrange
        {
        }
    | port_direction WIRE xrange
        {
        }
    | OUTPUT REG xrange
        { direction = 'O';
        }
    ;

port_identifiers
    : port_ident
    | port_identifiers port_ident
    ;

port_ident
    : IDENTIFIER list_of_delimit
      { name = $1;
        alloc_node(&h_port, 0);
      }
    | IDENTIFIER '=' RVAL list_of_delimit
      { name = $1;
        alloc_node(&h_port, 0);
      }
    | error
    ;

list_of_delimit
    : ','
      { yyerrok; }
    | rp
      { $$ = NULL; }
    | error
    ;


/*
Common terminals
*/

xrange
    : /* empty */
      { ranges = NULL;
      }
    | RANGE
      { ranges = $1;
//printf("Range : %s\n", $1);
      }
    ;


/*
net_spec
    : // empty
    | WIRE
      { $$ = NULL; }
    ;
*/

/*
Important terminals
*/

rp
    : ')'
      { yyerrok; }
    ;

sc
    : ';'
      { yyerrok; }
    ;


%%

void alloc_node (node_t** head, int type)
{
    node_t *p, *tail;
    int len;

    p = (node_t*)malloc(sizeof(node_t));

    if(p==NULL) {
        printf("fail in alloc_node()");
    }
    strcpy(p->name, name);
    p->ranges = ranges;
    p->pval = pval;

    p->direction = direction;
    p->next = NULL;

    len = strlen(name);
    if (max_pp_sl < len) max_pp_sl = len;
    if (type == 0 && max_port_sl < len) max_port_sl = len;
//printf("alloc %s : %d, %d\n", p->name, max_pp_sl, max_port_sl);

    if(*head==NULL) {
        *head = p;
    } else {
        tail = *head;
        while (tail->next) {
            tail = tail->next;
        }
        tail->next = p;
    }

}

char *addspace(char *s, int expect)
{
    int len = strlen(s);
    int i;

    for (i = len; i < expect; i++) {
        s[i] = ' ';
    }
    s[i] = '\0';

    return s;
}

char *delspace(char *s)
{
    int i, j=0;

    for ( i= 0; s[i] != '\0'; i++ ) {
    if (s[i] != ' '  &&
        s[i] != '\t' &&
        s[i] != '\r' &&
        s[i] != '\n' )
    s[j++] = s[i];
    }
    s[j] = '\0';

    return s;
}

void print_space (int n)
{
    int i;

    for (i=0; i<n; i++) printf("%c", ' ');
}

void print_wire (node_t* p)
{
    node_t* n;
    int  len;

    while (p) {
        n = p->next;

        if (p->ranges) {
            len = strlen(p->ranges);
            if (len > 5)
                printf("wire %s %s;\n", p->ranges, p->name);
            else {
                printf("wire  %s", p->ranges);
                print_space(5-len);
                printf(" %s;\n", p->name);
            }
        }
        else
            printf("wire        %s;\n", p->name);

        p = n;
    }
}

void print_para (node_t* p)
{
    node_t* n;

    while (p) {
        n = p->next;
        addspace(p->name, max_pp_sl);

        printf("    .%s ( %s )", p->name, delspace(p->pval));
        if (n)
            printf(",\n");
        else // the last port
            printf("\n) ");

        free(p);
        p = n;
    }
}

void print_port (node_t* p)
{
    node_t* n;

    while (p) {
        n = p->next;
        addspace(p->name, max_port_sl);

        printf("    .%s ( %s )", p->name, p->name);
        if (n)
            printf(",");
        else // the last port
            printf(" ");

        printf(" // %c", p->direction);
        if (p->ranges == NULL)
            printf("\n");
        else
            printf(" %s\n", p->ranges);

        free(p);
        p = n;
    }
}


void ver ()
{
    printf("vit 1.0.0, see 'https://github.com/balanx/vit'\n");
}

void help ()
{
    printf("Usage : vit [options] file\n\n");
    printf("Options :\n");
    printf("\t-q\tquiet\n\n");
}

char *filein = NULL;

int main ( int argc, char *argv[] )
{
    extern FILE *yyin;
    FILE* fp = NULL;
    int  i;
    int  quiet = 0;

    for (i=1; i < argc; ++i) {
        if ( !strcmp(argv[i], "-q") )
            quiet = 1;
        if ( argv[i][0] != '-' )
            filein = argv[i];
    }

    printf("\n");
    if (!quiet)  ver();

    if (!filein) {
        help();
        return -1;
    }

    fp = fopen(filein,"r");
    yyin = fp;

    yyparse();

    if (!quiet) {
        printf("\npress <RETURN> to continue ...\n");
        //fflush(stdin);
        getchar();
    }
    return 0;
}

yyerror ( char *s )
{
    extern int yylineno;
    fprintf( stderr ,"%s:%d: %s\n" , filein, yylineno, s );
}
