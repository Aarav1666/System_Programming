%{

void yyerror (const char* msg);
int yylex();

#include <iostream> 
#include <iomanip>    
#include <cstdlib>
#include <cctype>
#include <cstring>
#include <sstream>
#include <string>
#include <cmath>

/* :Mysql Database C support library */
#include "/usr/local/mysql/include/mysql.h"
using namespace std;





// :: Fields (data)

/* :structure for containing identifier and it's value */
struct idFormula{
    string name;
    string dbColName;
};


MYSQL *conn;                        // database connection
int FID = 0;                        // formula id field in db
string selected_formula = "";      // selected formula string
string selected_table =  "";       // selected table string

struct idFormula *idTable = NULL;   // array of struct containing values of identifier in selected formula
int numID = 0;                      // number of identifiers in formula

bool isIIFEEval = 0;                // current iife evaluation state
string evaluationIIFE = "";        // stores the result of iife evaluation


// :: Fields (funtions)

void showTBdata (MYSQL *conn, string tbNameDB);
void selectFID (string id);


string getValue (string ID);
void evaluate ();
void get ();

%}












%union
{
    int         cur_token;   
    double		cur_num;
    char*       cur_string;
}


%token <cur_token>	PLUS MINUS STAR SLASH EQUAL LPAREN RPAREN SEMICOLON SHOW SELECT EXIT EVALUATE GET  
%token <cur_string>	IDENTIFIER
%token <cur_num>	NUMBER

%type <cur_string> expr;
%type <cur_string> term;
%type <cur_string> factor;


%start lines






%%


lines:		lines line | line;

line:       SHOW IDENTIFIER SEMICOLON       {showTBdata(conn,$2);}
            | SELECT NUMBER SEMICOLON       {
                                                string id = "";
                                                //id += $2;

                                                std::stringstream stream;
                                                stream << std::fixed << std::setprecision(2) << $2;
                                                id += stream.str();

                                                selectFID(id);
                                            }
            | EXIT SEMICOLON                {exit(EXIT_SUCCESS);}
		    | expr SEMICOLON	            {
                                                string pFexpr = "";
                                                pFexpr += $1;
                                                evaluationIIFE += pFexpr;
                                            }
		    | EVALUATE SEMICOLON	    {evaluate();}
		    | GET SEMICOLON	            {get();};





expr:       expr PLUS term	                {
                                                string pTempOP = "";
                                                pTempOP += $1;
                                                pTempOP += " + "; 
                                                pTempOP += $3; 
                                                

                                                $$ = new char [pTempOP.length() + 1];
                                                strcpy($$,pTempOP.c_str());
                                            }
		    | expr MINUS term		        {
                                                string pTempOP = "";
                                                pTempOP += $1 ; 
                                                pTempOP += " - " ; 
                                                pTempOP += $3; 
                                                
                                                $$ = new char [pTempOP.length() + 1];
                                                strcpy($$,pTempOP.c_str());
                                            }
		    | term				            {$$ = $1;};


term:       term STAR factor			    {
                                                string pTempOP = "";
                                                pTempOP += $1 ; 
                                                pTempOP +=  " * " ; 
                                                pTempOP +=  $3; 
                                                
                                                $$ = new char [pTempOP.length() + 1];
                                                strcpy($$,pTempOP.c_str());
                                            }
		    | term SLASH factor			    {
                                                string pTempOP = "";
                                                pTempOP += $1 ; 
                                                pTempOP += " / "; 
                                                pTempOP += $3; 
                                                
                                                $$ = new char [pTempOP.length() + 1];
                                                strcpy($$,pTempOP.c_str());
                                            }
		    | factor				        {$$ = $1;};


factor:     IDENTIFIER				        {
                                                string curStrABID = getValue($1);

                                                $$ = new char [curStrABID.length() + 1];
                                                strcpy($$,curStrABID.c_str());
                                            }
		    | NUMBER				        {
                                                string tempNum  = "";
                                                //tempNum += std::to_string($1);
                                                
                                                std::stringstream stream;
                                                stream << std::fixed << std::setprecision(2) << $1;
                                                tempNum += stream.str();

                                                $$ = new char [tempNum.length() + 1];
                                                strcpy($$,tempNum.c_str());
                                            }
		    | LPAREN expr RPAREN	        {
                                                string pSubExpr = "(";
                                                pSubExpr += $2;
                                                pSubExpr += ")";

                                                $$ = new char [pSubExpr.length() + 1];
                                                strcpy($$,pSubExpr.c_str());

                                            };
%%












void yyerror(const char* msg) {
      cerr << msg << "\n";
}




int main () {


    // MYSQL *conn;

    string server = "localhost";
    string user = "root";
    string password = "";
    string database = "SP";

    conn = mysql_init(NULL);

    /* Connect to database */
    if (!mysql_real_connect(conn, &server[0], &user[0], &password[0], &database[0], 0, NULL, 0)){
        cerr << mysql_error(conn) << "\n";
        exit(1);
    }





    return yyparse();
}

















/* 
    showTBdata

    @params     conn:- reference to mysql connnection
                tbNameDB:- reference to table name

    @return     void

    @description

    `SHOW <tbNameDB>` would print the whole table tbNameDB if found.

    @err

    if tbNameDB is not found in the data base errorneous message 
    is printed in the console
    i.e. `Table 'sp.tbNameDB' doesn't exist`


*/

void showTBdata (MYSQL *conn, string tbNameDB){



    // making query

    string query = "select * from ";
    tbNameDB.replace(0,1," ");
    tbNameDB.replace(tbNameDB.length()-1,1," ");
    query += tbNameDB;

    
    MYSQL_RES *res;
    /* send SQL query */
    if (mysql_query(conn, &query[00])){
        cerr << mysql_error(conn) << "\n";
        //exit(1);
        return ;
    }

    res = mysql_store_result(conn);





    /* output table name */
    cout << tbNameDB << " Table:\n\n";


    // column name

    MYSQL_FIELD* column = mysql_fetch_field(res);
    while (column) {
            cout << column->name << "\t";
            column = mysql_fetch_field(res);
    }
    cout << "\n";



    // values
    MYSQL_ROW record = mysql_fetch_row(res);
    int cols = mysql_num_fields(res);
    while (record){
        for(int i=0; i<cols; i++){
            cout << record[i] << "\t";
        }
        cout << "\n";
        record = mysql_fetch_row(res);
    }
    cout << "\n";

    
}

















/* 
    selectFID

    @params     id:- id of formula in `FORMULAE` table

    @return     void

    @description

    `SELECT number` would select the formula choosen.

    ++ it will also look into the formula fields table 
    and load the identifier values.


    @err

    in case id is not found or the table for finding the 
    variable is missing the user is informed as such.


    @does
    four of the following global fields are manipulated in this function
    FID                 :-      choosen formula id
    selected_formula     :-      choosen foumula in string
    idTable           :-      identifiers && their value table
    numID               :-      number of identifiers


*/
void selectFID (string id){

    // init fields
    isIIFEEval = 0;
    evaluationIIFE = "";
    idTable = NULL;
    selected_formula = "";
    selected_table = "";
    FID = 0;
    numID = 0;

    MYSQL_RES *res;
    /* send SQL query */
    if (mysql_query(conn, "select * from FORMULAE"))
    {
        cerr << mysql_error(conn) << "\n";
        exit(1);
    }

    res = mysql_store_result(conn);

    int rows = mysql_num_rows(res);

    bool setIdentifier = 0;



    // validating id
    int id_Num = std::stoi(id);
    if (id_Num>0 && id_Num<=rows){
        // setting FID & selected_formula
        FID = id_Num;

        MYSQL_ROW record;
        for (int i=0; i<id_Num; i++){
            record = mysql_fetch_row(res);
        }
        selected_formula += record[1];

        setIdentifier = 1;

    }else{
        cout << "ERROR:   Selected Positive number must be less than equal to " << rows << "\n\n";
    }




    
    if(setIdentifier){
        //filling identifier table


        // making query
        string q1= "select * from FORMULAFIELDS where FID = ";
        q1 += std::to_string(FID);
        
        
        /* send SQL query */
        if (mysql_query(conn, &q1[0]))
        {
            cerr << mysql_error(conn) << "\n";
            exit(1);
        }

        MYSQL_RES *resid;
        resid = mysql_store_result(conn);

        int rowsid = mysql_num_rows(resid);

        if (rowsid == 0){
            cout << "Warning:        no identifier found\n";
        }

        // setting numID
        numID = rowsid;


        // initialise pointers
        struct idFormula *tempTestTable = new idFormula[rowsid];
               
        
        // temp pointer
        string strValueId[rowsid];
        for (int i=0; i<rowsid; i++){
            strValueId[i] = "";
        }

        

        MYSQL_ROW recordid;
        // identifier tokens fillup
        for (int i=0; i<rowsid; i++){
            recordid = mysql_fetch_row(resid);
            strValueId[i] += recordid[3];
            tempTestTable[i].name = "";
            tempTestTable[i].name += recordid[2];
        }


        if (rowsid > 0){
            string curr_valuer = strValueId[0];
            char *tokenr = strtok(&curr_valuer[0], ".");
            int charlim = strlen(tokenr);

            selected_table += tokenr;
            
        }

        
        
        
        // identifier value fillup
        for (int i=0; i<rowsid; i++){

            // producing query
            string curr_value = strValueId[i];

            char *token = strtok(&curr_value[0], ".");

            string cur_table = "";
            cur_table += token;

            token = strtok(NULL, ".");

            string cur_col = "";
            cur_col += token;

            tempTestTable[i].dbColName = "";
            tempTestTable[i].dbColName += cur_col;
                        
        }
        
        // manipulating idTable
        idTable = tempTestTable;

        //printf("Address of idTable = %p %p %p\n", idTable, *idTable, &idTable );

        //for (int i=0; i<numID; i++){
        //    printf("%s %s\n",idTable[i].name,idTable[i].dbColName);
        //}

        cout << "msg:    Formula \'"<< FID <<"\' selection completed.\n";
    }
    
}






































/* 
    getValue

    @params     ID:- name of the identifier

    @return     string  (returns the value linked with the identifier)

    @description

    the function is mainly for intra-mural assistance,
    the built parse tree || the shift reduce instructions
    are able to deduce the value of any identifier correctly.


    @err

    ID not found :- program abortion with errorneous message

*/
string getValue (string ID){

    //printf("Address of idTable = %p %p %p\n", idTable, *idTable, &idTable );
    //
    //for (int i=0; i<numID; i++){ 
    //    printf("%s %lf\n",idTable[i].name,idTable[i].value);
    //}

    
    int indexID = -1;

    string tempID = ID;

    for(int i=0; i<numID; i++){

        string tempToken = "";
        tempToken += idTable[i].name;
        if(tempToken.compare(tempID) == 0){
            indexID = i;
            break;
        }
    }

    

    if(indexID == -1){
        cout << "ERROR:      "<< ID <<" not found\n";
        exit(0);
    }

    //printf("%s",idTable[indexID].dbColName);

    return idTable[indexID].dbColName;
}




















/* 
    evaluate

    @params     

    @return     void

    @description

    the fuction streams selected formula 
    as input for lex


*/
void evaluate () {

    //init fields
    isIIFEEval = 1;
    if(selected_formula.compare("") == 0){
        cout << "ERROR:      FORMULA NOT SELECTED\n";
        return ;
    }

    int feedLimit = selected_formula.length();
    string tempFormula = "";
    tempFormula += selected_formula;

    
    
    ungetc('\n',stdin);
    ungetc(';',stdin);

    for(int i=feedLimit-1; i>=0; i--){
        ungetc(tempFormula.at(i),stdin);
    }

    //string checkOut = "";
    //cin>>checkOut;
    //cout<<checkOut<<"\n";

    cout << "msg:    Evaluation Succeeded.\n";
}














/* 
    get

    @params     

    @return     void

    @description

    the fuction prints the resulting query


*/
void get () {

    if(isIIFEEval == 0){
        cout << "ERROR:      Undone Evaluation.\n";
        return ;
    }

    if(FID == 0){
        cout << "ERROR:      Formula not selected.\n";
        return ;
    }

    string query = "select (";

    query += evaluationIIFE;
    query += ") as Result from ";


    cout << "CHANGE DEFAULT RESULT TABLE AS: " << selected_table <<"?(0/1)";
    int flag_change = 0;
    cin >> flag_change;

    if (flag_change){
        cout << "Enter the new Result Table name: ";
        
        string newTable;
        cin>>newTable;

        query += newTable;
    }else{
        query += selected_table;
    }


 
    cout << "GENERATED QUERY:\n";
    cout << "\n`"<<query<<"`\n";



    MYSQL_RES *res;
    /* send SQL query */
    if (mysql_query(conn, &query[0])){
        cerr << mysql_error(conn) << "\n";
        //exit(1);
        return ;
    }

    res = mysql_store_result(conn);





    /* output table name */
    cout << "Result Table:\n\n";


    // column name

    MYSQL_FIELD* column = mysql_fetch_field(res);
    while (column) {
            cout << column->name << "\t";
            column = mysql_fetch_field(res);
    }
    cout << "\n";



    // values
    MYSQL_ROW record = mysql_fetch_row(res);
    int cols = mysql_num_fields(res);
    while (record){
        for(int i=0; i<cols; i++){
            cout << record[i] << "\t";
        }
        cout << "\n";
        record = mysql_fetch_row(res);
    }
    cout << "\n";

}



