*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 22.09.2021 at 10:14:55
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZTON_DB_WH......................................*
DATA:  BEGIN OF STATUS_ZTON_DB_WH                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTON_DB_WH                    .
CONTROLS: TCTRL_ZTON_DB_WH
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZTON_DB_WH_UB...................................*
DATA:  BEGIN OF STATUS_ZTON_DB_WH_UB                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTON_DB_WH_UB                 .
CONTROLS: TCTRL_ZTON_DB_WH_UB
            TYPE TABLEVIEW USING SCREEN '0003'.
*.........table declarations:.................................*
TABLES: *ZTON_DB_WH                    .
TABLES: *ZTON_DB_WH_UB                 .
TABLES: ZTON_DB_WH                     .
TABLES: ZTON_DB_WH_UB                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
