       IDENTIFICATION DIVISION.
       PROGRAM-ID. REN1201.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
      **********************************************************************
      *******                EMBEDDED SQL VARIABLES                  *******
       77 OCSQL     PIC X(8) VALUE "OCSQL".
       77 OCSQLDIS  PIC X(8) VALUE "OCSQLDIS".
       77 OCSQLPRE  PIC X(8) VALUE "OCSQLPRE".
       77 OCSQLEXE  PIC X(8) VALUE "OCSQLEXE".
       77 OCSQLRBK  PIC X(8) VALUE "OCSQLRBK".
       77 OCSQLCMT  PIC X(8) VALUE "OCSQLCMT".
       77 OCSQLIMM  PIC X(8) VALUE "OCSQLIMM".
       77 OCSQLOCU  PIC X(8) VALUE "OCSQLOCU".
       77 OCSQLCCU  PIC X(8) VALUE "OCSQLCCU".
       77 OCSQLFTC  PIC X(8) VALUE "OCSQLFTC".
       77 OCSQLCAL  PIC X(8) VALUE "OCSQLCAL".
       01 SQLV.
           05 SQL-ARRSZ  PIC S9(9) COMP-5 VALUE 2.
           05 SQL-COUNT  PIC S9(9) COMP-5 VALUE ZERO.
           05 SQL-ADDR   POINTER OCCURS 2 TIMES VALUE NULL.
           05 SQL-LEN    PIC S9(9) COMP-5 OCCURS 2 TIMES VALUE ZERO.
           05 SQL-TYPE   PIC X OCCURS 2 TIMES.
           05 SQL-PREC   PIC X OCCURS 2 TIMES.
      **********************************************************************
       01 SQL-STMT-0.
           05 SQL-IPTR   POINTER VALUE NULL.
           05 SQL-PREP   PIC X VALUE "N".
           05 SQL-OPT    PIC X VALUE SPACE.
           05 SQL-PARMS  PIC S9(4) COMP-5 VALUE 0.
           05 SQL-STMLEN PIC S9(4) COMP-5 VALUE 37.
           05 SQL-STMT   PIC X(37) VALUE "SELECT id,name FROM test WHERE
      -    " id='1'".
      **********************************************************************
      *******          PRECOMPILER-GENERATED VARIABLES               *******
       01 SQLV-GEN-VARS.
           05 SQL-VAR-0001  PIC S9(7) COMP-3.
      *******       END OF PRECOMPILER-GENERATED VARIABLES           *******
      **********************************************************************
      *EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 DSN       PIC X(256).
       01 TID       PIC 9(6).
       01 TNAME     PIC X(10).
      *EXEC SQL END DECLARE SECTION END-EXEC.
      *EXEC SQL INCLUDE SQLCA END-EXEC.
       01 SQLCA.
           05 SQLSTATE PIC X(5).
              88  SQL-SUCCESS           VALUE '00000'.
              88  SQL-RIGHT-TRUNC       VALUE '01004'.
              88  SQL-NODATA            VALUE '02000'.
              88  SQL-DUPLICATE         VALUE '23000' THRU '23999'.
              88  SQL-MULTIPLE-ROWS     VALUE '21000'.
              88  SQL-NULL-NO-IND       VALUE '22002'.
              88  SQL-INVALID-CURSOR-STATE VALUE '24000'.
           05 FILLER   PIC X.
           05 SQLVERSN PIC 99 VALUE 03.
           05 SQLCODE  PIC S9(9) COMP-5 VALUE ZERO.
           05 SQLERRM.
               49 SQLERRML PIC S9(4) COMP-5 VALUE ZERO.
               49 SQLERRMC PIC X(486).
           05 SQLERRD OCCURS 6 TIMES PIC S9(9) COMP-5 VALUE ZERO.
           05 FILLER   PIC X(4).
           05 SQL-HCONN USAGE POINTER VALUE NULL.


       PROCEDURE DIVISION.
           STRING
             "DRIVER={Postgresql Unicode};"
             "SERVER=db;"
             "DATABASE=test_conn;"
             "UID=test_conn;"
             "PWD=test_conn;"
             "CONNSETTINGS=SET CLIENT_ENCODING to 'SJIS';"
             INTO DSN
           END-STRING.

           DISPLAY "CONNECTING DATABASE ..."
      *    EXEC SQL CONNECT TO :DSN END-EXEC.
           MOVE 256 TO SQL-LEN(1)
           CALL OCSQL    USING DSN
                               SQL-LEN(1)
                               SQLCA
           END-CALL
                                            .

           PERFORM SQLCA-DISP-RTN.

           IF SQLCODE NOT = ZERO
             GO TO EXT
           END-IF.

           DISPLAY "SELECTING DATA FROM TABLE ..."
      *    EXEC SQL
      *      SELECT id, name
      *      INTO :TID, :TNAME
      *      FROM test
      *      WHERE id='1'
      *    END-EXEC.
           IF SQL-PREP OF SQL-STMT-0 = "N"
               SET SQL-ADDR(1) TO ADDRESS OF
                 SQL-VAR-0001
               MOVE "3" TO SQL-TYPE(1)
               MOVE 4 TO SQL-LEN(1)
               MOVE X'00' TO SQL-PREC(1)
               SET SQL-ADDR(2) TO ADDRESS OF
                 TNAME
               MOVE "X" TO SQL-TYPE(2)
               MOVE 10 TO SQL-LEN(2)
               MOVE 2 TO SQL-COUNT
               CALL OCSQLPRE USING SQLV
                                   SQL-STMT-0
                                   SQLCA
               SET SQL-HCONN OF SQLCA TO NULL
           END-IF
           CALL OCSQLEXE USING SQL-STMT-0
                               SQLCA
           MOVE SQL-VAR-0001 TO TID
                   .
           DISPLAY TID TNAME.

           PERFORM SQLCA-DISP-RTN.
       EXT.
           STOP RUN.

       SQLCA-DISP-RTN  SECTION.
           DISPLAY "SQLCODE: "   SQLCODE
                   " SQLSTATE: " SQLSTATE
                   " SQLERRM: "  SQLERRM.
           EXIT.

      **********************************************************************
      *  : ESQL for GnuCOBOL/OpenCOBOL Version 3 (2022.01.15) Build Oct  3 2023

      *******               EMBEDDED SQL VARIABLES USAGE             *******
      *  DSN                      IN USE CHAR(256)
      *  TID                      IN USE THROUGH TEMP VAR SQL-VAR-0001 DECIMAL(7,0)
      *  TNAME                    IN USE CHAR(10)
      **********************************************************************
