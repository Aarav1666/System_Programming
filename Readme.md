# **SYSTEM PROGRAMMING**

<br/><br/>


Consider a simple SQL query that retrieves a character string from a column of the Table

“Formulae” as below:

Select “Formula” from “Formulae” where “ID”=5; The returned value may be like:

`‘(<A1>+<A2>)*0.5 - <A3>’`

where `<A1>`, `<A2>`, `<A3>` etc. Are to be substituted by the fieldnames stored in a Table `“FormulaFields”`. An example schema can be:


`(“TupleID”, “VariableName”,”ColumnName”)`

`(1,’<A1>’,’Salary.Basic’)`

`(2,’<A2>’,’Salary.TA’)`

`(3,’<A3>’,’Salary.PF’)`

`...`

(i.e, tablename.columnname is stored in the third column of the table)

Having obtained the formula from the table by a query such as above, you need to convert it to a corresponding SQL query. For the example above, the resulting query should be

`Select ((Basic + TA) * 0.5 – PF) as “Result” from “Salary” where ... (some condition here)`



<br/><br/>

## Table of contents


* [OVERVIEW](#overview)
* [ASSUMPTIONS](#assumptions)
* [USAGE](#usage)
* [DATABASE STRUCTURES](#database-structures)
* [SYSTEM INFORMATION](#system-information)
* [TERMINAL command-lines](#terminal-command-lines)
* [CHECKLIST](#checklist)




<br/><br/>

## OVERVIEW



<br/>

The program is built using lex & yacc tools.

Database connectivity is performed using C library ```<mysql.h>```

For more on database functions visit [C API Developer Guide](https://dev.mysql.com/doc/c-api/8.0/en/c-api-function-reference.html)

<br/>

> Features:
> - Parser allows variable to be captured in data structure from other tables in database. However, the RESULT driving table is either the one linked to the first identifier or user's entered choice.
> - The above flexibility comes at the cost of linear SQL query.
> - User can directly view db tables from the parser.
> - Effort is made to cover exceptions and errors.
> - The parser is robust enough for small scale usage. For large scale use one must see to the usecases.


<br/><br/>

## ASSUMPTIONS



<br/>

* All decimal values are rounded to 2 decimal places.

<br/><br/>

## USAGE



<br/>

```bash
SHOW <TABLE_NAME>;
```

Upon the execution of command specified table is printed.

For ex:- `SHOW <FORMULAE>;`

<br/>

```bash
SELECT FORMULA_NUMBER;
```

Allows user to select the formula from the `'FORMULAE'` table.

For ex:- `SELECT 2;`

<br/>

```bash
EVALUATE;
```

Streams the formula to the parser.

<br/>

```bash
GET;
```
Prints the resulting query and the table obtained upon it's execution.

<br/>

```bash
EXIT;
```
Terminates the program.



<br/><br/>

## DATABASE STRUCTURES



<br/><br/>


>* TABLE **FORMULAE**

<br/>

| Field   | Type        | Null | Key | Default | Extra          |
| -----   | ----        | ---- | --- | ------- | -----          |
| ID      | int         | NO   | PRI | NULL    | auto_increment |
| FORMULA | varchar(50) | YES  |     | NULL    |                |


| ID | FORMULA              |
| -- | -------              |
|  1 | `(<A1>+<A2>)*0.5-<A3>`                           |
|  2 | `<A1>+<A2>+<A3>+<A4>+<A5>+<A6>`                  |
|  3 | `<A1>+<A2>+<A3>`                                 |
|  4 | `<A1>+<A2>+<A3>+<A4>+<A5>+<A6>-(<A7>+<A8>+<A9>)` |
|  5 | `<A1>+<A2>-<A3>-<A4>+<A5>`                       |

<br/><br/><br/>

>* TABLE **FORMULAFIELDS**

<br/>

| Field   | Type        | Null | Key | Default | Extra          |
| -----   | ----        | ---- | --- | ------- | -----          |
| ID            | int         | NO   | PRI | NULL    | auto_increment |
| FID           | int         | YES  | MUL | NULL    |                |
| VARIABLE_NAME | varchar(50) | YES  |     | NULL    |                |
| COLUMN_NAME   | varchar(50) | YES  |     | NULL    |                |


| ID | FID  | VARIABLE_NAME | COLUMN_NAME    |
| -- | ---  | ------------- | -----------    |
|  1 |    1 | `<A1>`          | `SALARY.BASIC` |
|  2 |    1 | `<A2>`          | `SALARY.TA`    |
|  3 |    1 | `<A3>`          | `SALARY.PF`    |
|  4 |    2 | `<A1>`          | `SALARY.BASIC` |
|  5 |    2 | `<A2>`          | `SALARY.DA`    |
|  6 |    2 | `<A3>`          | `SALARY.HRA`   |
|  7 |    2 | `<A4>`          | `SALARY.CA`    |
|  8 |    2 | `<A5>`          | `SALARY.MA`    |
|  9 |    2 | `<A6>`          | `SALARY.TA`    |
| 10 |    3 | `<A1>`          | `SALARY.PT`    |
| 11 |    3 | `<A2>`          | `SALARY.TS`    |
| 12 |    3 | `<A3>`          | `SALARY.PF`    |
| 13 |    4 | `<A1>`          | `SALARY.BASIC` |
| 14 |    4 | `<A2>`          | `SALARY.DA`    |
| 15 |    4 | `<A3>`          | `SALARY.HRA`   |
| 16 |    4 | `<A4>`          | `SALARY.CA`    |
| 17 |    4 | `<A5>`          | `SALARY.MA`    |
| 18 |    4 | `<A6>`          | `SALARY.TA`    |
| 19 |    4 | `<A7>`          | `SALARY.PT`    |
| 20 |    4 | `<A8>`          | `SALARY.TS`    |
| 21 |    4 | `<A9>`          | `SALARY.PF`    |
| 22 |    5 | `<A1>`          | `SALARY.BASIC` |
| 23 |    5 | `<A2>`          | `SALARY.HRA`   |
| 24 |    5 | `<A3>`          | `SALARY.MA`    |
| 25 |    5 | `<A4>`          | `SALARY.TA`    |
| 26 |    5 | `<A5>`          | `SALARY.PF`    |

<br/><br/><br/>

>* Table **SALARY**

<br/>

| Field   | Type        | Null | Key | Default | Extra          |
| -----   | ----        | ---- | --- | ------- | -----          |
| ID      | int         | NO   | PRI | NULL    | auto_increment |
| NAME    | varchar(50) | YES  |     | NULL    |                |
| JOBDESC | varchar(50) | YES  |     | NULL    |                |
| BASIC   | int         | YES  |     | NULL    |                |
| DA      | int         | YES  |     | NULL    |                |
| HRA     | int         | YES  |     | NULL    |                |
| CA      | int         | YES  |     | NULL    |                |
| MA      | int         | YES  |     | NULL    |                |
| TA      | int         | YES  |     | NULL    |                |
| PT      | int         | YES  |     | NULL    |                |
| TS      | int         | YES  |     | NULL    |                |
| PF      | int         | YES  |     | NULL    |                |


| ID | NAME     | JOBDESC  | BASIC | DA   | HRA   | CA   | MA   | TA    | PT   | TS    | PF   |
| -- | ----     | -------  | ----- | --   | ---   | --   | --   | --    | --   | --    | --   |
|  1 | PERSONN1 | PROFILE1 | 40000 | 4000 | 20000 | 1600 | 4500 | 28000 |  200 | 10000 | 4800 |
|  2 | PERSONN2 | PROFILE2 | 80000 | 8000 | 40000 | 3200 | 9000 | 56000 |  400 | 20000 | 9600 |


<br/><br/><br/>

## SYSTEM INFORMATION



<br/>

>### macOS Big Sur

>### Intel i5 family of processors

<br/><br/>

## TERMINAL `command-lines`



<br/><br/>


```bash
yacc -d index.y
```

* Generates y.tab.h & y.tab.c

```bash
lex index.l
```

* Generates lex.yy.c

```bash
g++ -g -c -I/usr/local/Cellar/mysql/8.0.26/include/mysql lex.yy.c y.tab.c 
```

* Generates y.tab.o & lex.yy.o

```bash
g++ -g -o output lex.yy.o y.tab.o -L/usr/local/Cellar/mysql/8.0.26/lib -lmysqlclient -lz -lzstd -lssl -lcrypto -lresolv
```
* Generates output

```bash
./output
```

* Execute output

<br/><br/>

## CHECKLIST



<br/>

- [x] Use `lex (flex)` to scan and interpret formula that is always constructed from symbols of the form `<A1>, <A2>` etc., and numeric literals, and arithmetic operators `+, -, *, / and ()`

- [x] Use `yacc (bison)` to generate parser for checking if formula is correctly formed according to standard grammer of arithmetic expressions involving tokens from 1 above  

- [x] Generate code equivalent to the example SQL code given above by specifiying appropriate instructions in parser using `C/C++`.  

- [x] Make the tables `“Formulae”` and `“Salary”` in some `DBMS`, say `MySQL`, and test run the successful execution of the generated query.  

- [x] Include documentation for your design, standard comments in source code, and any special.

<br/><br/><br/><br/>

## My warmest regards To `P.D.Sharma` sir
