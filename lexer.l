%{
#include "parser.h"
#include <stdlib.h>
unsigned int lineno=1;

bool error_lexical=false;
%}
/*=========================================================================
TOKEN Definitions
=========================================================================*/
DIGIT [0-9]
ID [a-z][a-z0-9]*
commentaire ((\/\/|#).*)

%x  commentaire_1
%x  commentaire_2
%%
"/*"    {
            /* un marqueur de debut de commentaire trouve -> on lui dit que le lexeme commentaire_1 commence */
            BEGIN(commentaire_1);
        if (error_lexical==true) {    printf("Comment detected online %i\n",lineno);}
        }
 
<commentaire_1>"\n"     {
                            /* si on trouve des retours chariots et que la condition de demarrage est commentaire_1, alors on incremente la variable lineno. sans cela, on serait en decalage pour la suite de l'analyse */
                            lineno++;
                        }
 
<commentaire_1>"*"+"/"      {
                                /* si on au moins une fois "*" suivi de "/" et que la condition de demarrage est commentaire_1, alors on lui dit que le lexeme commentaire_1 est fini */
                                BEGIN(INITIAL);
                              if (error_lexical==true) {  printf("End of online commentary %i\n",lineno);}
                            }
 
<commentaire_1>.    {/* les autres caracteres suivants la conditions de demarrage sont absorbes par l'analyse est donc ingores */}
 
"<!--"      {
                BEGIN(commentaire_2);
               if (error_lexical==true) { printf("Comment detected online %i\n",lineno);}
            }
<commentaire_2>"\n"         {lineno++;}
<commentaire_2>"-"+"-"+">"  {
                                BEGIN(INITIAL);
                               if (error_lexical==true) { printf("End of online commentary %i\n",lineno);}
                            }
<commentaire_2>.            {}
":=" { return(ASSGNOP); }
{DIGIT}+ { yylval.intval = atoi( yytext );
return(NUMBER); }
do { return(DO); }
else { return(ELSE); }
end { return(END); }
fi { return(FI); }
if { return(IF); }
"start" { return(STAR); }
integer { return(INTEGER); }
"declarations:" { return(DECL); }
read { return(READ); }
for {return(FOR);}
then { return(THEN); }
while { return(WHILE); }
write { return(WRITE); }
"++" { return(INCR); }
"--" { return(DECR); }
[-+/*=;<>,] { return *yytext; }
"(" {return TOK_PARG;}
"{" {return GUILLIMETG;}
"}" {return GUILLIMETD;}
")" {return TOK_PARD;}
{ID} { yylval.id = (char *) strdup(yytext);
return(IDENTIFIER); }
[ \t]+ /* eat up whitespace */
"\n" {lineno++;}
{commentaire}   {
    if (error_lexical==true) {printf("Comment detected on line %i\n",lineno);
    printf("Fin du commentaire en ligne %i\n",lineno);}
}
. { fprintf(stderr,"\e[1;34m \tERROR: Unknown lexeme at line %d. It is %s and includes  %d letter(s) \e[0m \n",lineno,yytext,yyleng);
        error_lexical=true;
        return yytext[0];}

%%
int yywrap(void){}
/************************** End Scanner File *****************************/
