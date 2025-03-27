       IDENTIFICATION DIVISION.
       PROGRAM-ID. REN1200.
       DATA DIVISION.

       WORKING-STORAGE SECTION.
      ******** (1)ホスト変数の定義 ********
OCESQL*EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 TID       PIC 9(6).
       01 TNAME     PIC X(10).

       01 DBNAME    PIC X(32) VALUE "test_conn@localhost".
       01 USERNAME  PIC X(32) VALUE "test_conn".
       01 PASSWORD  PIC X(32) VALUE "test_conn".
       
OCESQL*EXEC SQL END DECLARE SECTION END-EXEC.
      *************************************
      ******** (2)共通領域の定義 **********
OCESQL*EXEC SQL INCLUDE SQLCA END-EXEC.
OCESQL     copy "sqlca.cbl".
      *************************************
OCESQL*
OCESQL 01  SQ0001.
OCESQL     02  FILLER PIC X(040) VALUE "SELECT id, name FROM test WHER"
OCESQL  &  "E id = '1'".
OCESQL     02  FILLER PIC X(1) VALUE X"00".
OCESQL*
       PROCEDURE DIVISION.
           DISPLAY "CONNECTING DATABASE ..."
OCESQL*    EXEC SQL
OCESQL*    CONNECT :USERNAME
OCESQL*        IDENTIFIED BY :PASSWORD
OCESQL*        USING :DBNAME
OCESQL*    END-EXEC.
OCESQL     CALL "OCESQLConnect" USING
OCESQL          BY REFERENCE SQLCA
OCESQL          BY REFERENCE USERNAME
OCESQL          BY VALUE 32
OCESQL          BY REFERENCE PASSWORD
OCESQL          BY VALUE 32
OCESQL          BY REFERENCE DBNAME
OCESQL          BY VALUE 32
OCESQL     END-CALL.
           PERFORM SQLCA-DISP-RTN
           IF SQLCODE NOT = 0
               GO TO EXT
           END-IF.

           DISPLAY "SELECTING DATA FROM TABLE ..."
OCESQL*    EXEC SQL
OCESQL*      SELECT id, name
OCESQL*      INTO :TID, :TNAME
OCESQL*      FROM test
OCESQL*      WHERE id='1'
OCESQL*    END-EXEC.
OCESQL     CALL "OCESQLStartSQL"
OCESQL     END-CALL
OCESQL     CALL "OCESQLSetResultParams" USING
OCESQL          BY VALUE 1
OCESQL          BY VALUE 6
OCESQL          BY VALUE 0
OCESQL          BY REFERENCE TID
OCESQL     END-CALL
OCESQL     CALL "OCESQLSetResultParams" USING
OCESQL          BY VALUE 16
OCESQL          BY VALUE 10
OCESQL          BY VALUE 0
OCESQL          BY REFERENCE TNAME
OCESQL     END-CALL
OCESQL     CALL "OCESQLExecSelectIntoOne" USING
OCESQL          BY REFERENCE SQLCA
OCESQL          BY REFERENCE SQ0001
OCESQL          BY VALUE 0
OCESQL          BY VALUE 2
OCESQL     END-CALL
OCESQL     CALL "OCESQLEndSQL"
OCESQL     END-CALL.
           DISPLAY TID TNAME.
           PERFORM SQLCA-DISP-RTN.
       EXT.
           STOP RUN.

       SQLCA-DISP-RTN  SECTION.
           DISPLAY "SQLCODE: "   SQLCODE
                   " SQLSTATE: " SQLSTATE
                   " SQLERRM: "  SQLERRM.
           EXIT.
                        