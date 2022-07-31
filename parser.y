%define parse.error verbose /* instruct bison to generate verbose error messages*/
%{
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"

bool error_syntaxical=false;
bool error_variable=false;
extern unsigned int lineno;
extern bool error_lexical;

int yylex(void); 
void yyerror(const char *s);
/* enable debugging of the parser: when yydebug is set to 1 before the
 * yyparse call the parser prints a lot of messages about what it does */
#define YYDEBUG 1
%}

%union {
    int intval;
    char* id;
}

/*=========================================================================
TOKENS
=========================================================================*/
%token<intval> NUMBER /* Simple integer */
%token  <id>  IDENTIFIER  /* Simple identifier */
%token  WHILE /* For backpatching labels */
%token THEN ELSE FI DO END GUILLIMETG FOR INCR DECR
%token INTEGER READ DECL STAR GUILLIMETD
%token ASSGNOP 
%token<id> TOK_PARG  TOK_PARD IF WRITE 
%type<id> variable 
%type<id> affichage
%type<id> exp affectation iftok
/*=========================================================================
OPERATOR PRECEDENCE
=========================================================================*/
%left '-' '+' 
%left '*' '/' 
%right '^'
%right TOK_PARG  TOK_PARD 
/*=========================================================================
GRAMMAR RULES for the Simple language
=========================================================================*/

%%
program :%empty{}
        | DECL declarations STAR commands END
        ;

declarations:%empty{}
        |declarations declaration
        ;
variable:IDENTIFIER 
        |error{if (error_lexical==false && error_variable==false ) {fprintf(stderr,"%s\tERROR: Invalid Variable: line %d.\n %s", KRED,lineno,KNRM);
        error_syntaxical=true;error_variable=true;}};

declaration :INTEGER id_seq variable';';

id_seq : %empty{}
        | id_seq variable ','
        ;
commands : %empty{}
        | commands command ';'
        ;
command :%empty{}
        | READ variable
        | affichage
        | affectation
        |whilestmnt
        |ifstmnt
        |forstmnt
        ;

affichage:WRITE exp
                ;

affectation:variable ASSGNOP exp
            | variable INCR
            | variable DECR ;

ifstmnt:iftok TOK_PARG exp TOK_PARD THEN commands fitok ;
iftok:  %empty {if (error_lexical==false  ) {fprintf(stderr,"%s \tERROR: Line %d : MISSING 'IF' \e[0m \n",KMAG,lineno);error_syntaxical=true;}}
        |IF
       ;
 fitok: FI
        |error{if (error_lexical==false  ) {fprintf(stderr,"%s \tERROR: Line %d : 'FI' INVALID or MISSING \e[0m \n",KMAG,lineno);error_syntaxical=true;}};       
whilestmnt:WHILE TOK_PARG exp TOK_PARD DO commands END;
forstmnt: FOR TOK_PARG affectation';'boucle';'affectation TOK_PARD GUILLIMETG commands GUILLIMETD ;
boucle:%empty {if (error_lexical==false ) {fprintf(stderr,"%s \tERROR: Line %d : INFINITE LOOP \e[0m \n",KMAG,lineno);error_syntaxical=true;}}
        |exp
        ;
exp :
NUMBER {int length=snprintf(NULL,0,"%d",$1); char* str=malloc(length+1);snprintf(str,length+1,"%d",$1);$$=strdup(str); free(str); }
| variable 
| exp '<' exp
| exp '=' exp 
| exp '>' exp 
| NUMBER '+'NUMBER {if (error_lexical==false && error_syntaxical== false ) {printf("Addition of '%d' and '%d' is equal to: %d \n\n",$1,$3,$1+$3);}}
| NUMBER '-'NUMBER {if (error_lexical==false && error_syntaxical== false ) {printf("The Subtraction of '%d' and '%d' is equal to : %d \n\n",$1,$3,$1 -$3);}}
| NUMBER '*'NUMBER {if (error_lexical==false && error_syntaxical== false ) {printf("The product of '%d' and '%d' is equal to : %d \n\n",$1,$3,$1 *$3);}}
| NUMBER '/'NUMBER {if (error_lexical==false && error_syntaxical== false ) {printf("The Division of '%d' and '%d' is equal to : %d \n\n",$1,$3,$1 /$3);}}
| exp '^' exp
;
%%

#include <stdlib.h>
#include "lexer.c"
void yyerror(const char *s) 
{ 
fprintf(stderr, "Syntax error at line %d: %s\n", lineno, s);error_syntaxical=true;
}

int main()
{
yyin = fopen("example.rani","r");
    yydebug = 0;
        printf("\nStart of syntactic analysis :\n \n");
        yyparse();
        printf("End of analysis !\n");
         printf("%sResults :\n %s", KRED,KNRM);
        if(error_lexical==true){
                printf("\t-- %sEchec : Some lexemes are not part of the language lexicon! --\n%s",KRED,KNRM);
                printf("\t--%s Lexical analysis failure --\n%s",KRED,KNRM);
        }
        else{
                printf("\t%s-- Success in lexical analysis ! --\n%s",KGRN,KNRM);
        }
        if(error_syntaxical == true  || error_lexical==true ){
                printf("\t%s-- Failure: Some sentences are syntactically incorrect!--\n%s",KRED,KNRM);
                printf("\t%s-- Parse failure --\n%s",KRED,KNRM);
        }
        else{
                printf("\t%s-- Parse success! --\n%s",KGRN,KNRM);
        }
        return 0;
}